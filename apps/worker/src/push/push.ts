import { deleteDeviceTokens, listDeviceTokens, type DbExecutor } from "@dcard/core";
import type { Messaging, MulticastMessage } from "firebase-admin/messaging";

// Push notifications (T03-08, docs/design/integrations/firebase.md › FCM/APNs).
// FCM sits behind `PushSender` so tests and unconfigured environments never touch the network;
// no firebase-admin code outside this file.

export type PushNotification = { title: string; body: string; data?: Record<string, string> };

/** Per-token outcome, in the order of the tokens sent. */
export type PushResult = { token: string; ok: true; messageId: string } | { token: string; ok: false; code: string };

export interface PushSender {
  send(tokens: string[], notification: PushNotification): Promise<PushResult[]>;
}

/** Firebase keys are still placeholders. */
export class PushNotConfiguredError extends Error {
  constructor() {
    super("Push notifications are not configured (FIREBASE_* keys are placeholders).");
  }
}

export class UnconfiguredPushSender implements PushSender {
  async send(): Promise<PushResult[]> {
    throw new PushNotConfiguredError();
  }
}

/** FCM error codes meaning the token will never work again: delete it. */
export const INVALID_TOKEN_CODES = new Set([
  "messaging/registration-token-not-registered",
  "messaging/invalid-registration-token",
  "messaging/invalid-argument",
]);

/** FCM accepts at most 500 tokens per multicast. */
export const FCM_BATCH_LIMIT = 500;

type MulticastSender = Pick<Messaging, "sendEachForMulticast">;

export class FcmPushSender implements PushSender {
  constructor(private readonly messaging: MulticastSender) {}

  async send(tokens: string[], notification: PushNotification): Promise<PushResult[]> {
    const results: PushResult[] = [];
    for (let i = 0; i < tokens.length; i += FCM_BATCH_LIMIT) {
      const batch = tokens.slice(i, i + FCM_BATCH_LIMIT);
      const message: MulticastMessage = {
        tokens: batch,
        notification: { title: notification.title, body: notification.body },
        ...(notification.data ? { data: notification.data } : {}),
        android: { priority: "high" },
      };
      const response = await this.messaging.sendEachForMulticast(message);
      response.responses.forEach((r, j) => {
        const token = batch[j]!;
        results.push(r.success ? { token, ok: true, messageId: r.messageId ?? "" } : { token, ok: false, code: r.error?.code ?? "unknown" });
      });
    }
    return results;
  }
}

const isPlaceholder = (v: string | undefined) => !v || v.startsWith("dummy_");

/** Real FCM sender when the Firebase service account is set, the unconfigured one otherwise. */
export async function pushSenderFromEnv(env: NodeJS.ProcessEnv = process.env): Promise<PushSender> {
  const { FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY } = env;
  if (isPlaceholder(FIREBASE_PROJECT_ID) || isPlaceholder(FIREBASE_CLIENT_EMAIL) || isPlaceholder(FIREBASE_PRIVATE_KEY)) {
    return new UnconfiguredPushSender();
  }
  const { cert, getApps, initializeApp } = await import("firebase-admin/app");
  const { getMessaging } = await import("firebase-admin/messaging");
  const app =
    getApps()[0] ??
    initializeApp({
      credential: cert({ projectId: FIREBASE_PROJECT_ID, clientEmail: FIREBASE_CLIENT_EMAIL, privateKey: FIREBASE_PRIVATE_KEY!.replace(/\\n/g, "\n") }),
      projectId: FIREBASE_PROJECT_ID,
    });
  return new FcmPushSender(getMessaging(app));
}

export type SendToUserResult =
  | { status: "not_configured"; tokens: number }
  | { status: "sent"; tokens: number; sent: number; failed: number; removed: number };

/**
 * Sends `notification` to every registered device of `userId` and deletes tokens FCM reports
 * as invalid. When every token fails with `invalid-argument` the payload itself is the likely
 * cause, so nothing is deleted in that case.
 */
export async function sendToUser(
  db: DbExecutor,
  sender: PushSender,
  userId: string,
  notification: PushNotification,
): Promise<SendToUserResult> {
  const tokens = (await listDeviceTokens(db, userId)).map((d) => d.token);
  if (tokens.length === 0) return { status: "sent", tokens: 0, sent: 0, failed: 0, removed: 0 };
  let results: PushResult[];
  try {
    results = await sender.send(tokens, notification);
  } catch (err) {
    if (err instanceof PushNotConfiguredError) return { status: "not_configured", tokens: tokens.length };
    throw err;
  }
  const failures = results.filter((r): r is Extract<PushResult, { ok: false }> => !r.ok);
  const payloadRejected = failures.length === results.length && failures.every((f) => f.code === "messaging/invalid-argument");
  const invalid = payloadRejected ? [] : failures.filter((f) => INVALID_TOKEN_CODES.has(f.code)).map((f) => f.token);
  const removed = await deleteDeviceTokens(db, invalid);
  return { status: "sent", tokens: tokens.length, sent: results.length - failures.length, failed: failures.length, removed };
}
