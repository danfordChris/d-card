import { registerDeviceToken } from "@dcard/core";
import { deviceToken, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { eq } from "drizzle-orm";
import type { BatchResponse, MulticastMessage } from "firebase-admin/messaging";
import { afterAll, beforeAll, beforeEach, describe, expect, it } from "vitest";
import {
  FCM_BATCH_LIMIT,
  FcmPushSender,
  pushSenderFromEnv,
  sendToUser,
  UnconfiguredPushSender,
  type PushNotification,
  type PushResult,
  type PushSender,
} from "../src/push/push.js";
import { createPushProcessor } from "../src/push/processor.js";

// No network: FCM is replaced by fakes (a fake PushSender, or a fake Messaging for FcmPushSender).

const NOTE: PushNotification = { title: "Mgeni mlangoni", body: "Asha anaomba kuingia", data: { kind: "test" } };

/** Fails the tokens listed in `failures` with the given FCM code; everything else succeeds. */
class FakePushSender implements PushSender {
  calls: { tokens: string[]; notification: PushNotification }[] = [];
  constructor(private readonly failures: Record<string, string> = {}) {}
  async send(tokens: string[], notification: PushNotification): Promise<PushResult[]> {
    this.calls.push({ tokens, notification });
    return tokens.map((token) =>
      this.failures[token] ? { token, ok: false, code: this.failures[token]! } : { token, ok: true, messageId: `m-${token}` },
    );
  }
}

describe("FcmPushSender", () => {
  it("sends a multicast per 500 tokens and maps each response to its token", async () => {
    const seen: MulticastMessage[] = [];
    const messaging = {
      sendEachForMulticast: async (message: MulticastMessage): Promise<BatchResponse> => {
        seen.push(message);
        const responses = message.tokens.map((t) =>
          t === "bad"
            ? { success: false as const, error: { code: "messaging/registration-token-not-registered" } as never }
            : { success: true as const, messageId: `projects/p/messages/${t}` },
        );
        return { responses, successCount: responses.filter((r) => r.success).length, failureCount: responses.filter((r) => !r.success).length };
      },
    };
    const tokens = [...Array.from({ length: FCM_BATCH_LIMIT }, (_, i) => `t${i}`), "bad"];
    const results = await new FcmPushSender(messaging as never).send(tokens, NOTE);

    expect(seen.map((m) => m.tokens.length)).toEqual([500, 1]);
    expect(seen[0]).toMatchObject({ notification: { title: NOTE.title, body: NOTE.body }, data: { kind: "test" } });
    expect(results).toHaveLength(501);
    expect(results[0]).toEqual({ token: "t0", ok: true, messageId: "projects/p/messages/t0" });
    expect(results[500]).toEqual({ token: "bad", ok: false, code: "messaging/registration-token-not-registered" });
  });
});

describe("pushSenderFromEnv", () => {
  it("uses the unconfigured sender while Firebase keys are placeholders", async () => {
    const sender = await pushSenderFromEnv({
      FIREBASE_PROJECT_ID: "dummy_firebase_project_id",
      FIREBASE_CLIENT_EMAIL: "dummy_x@example.com",
      FIREBASE_PRIVATE_KEY: "dummy_-----BEGIN PRIVATE KEY-----",
    });
    expect(sender).toBeInstanceOf(UnconfiguredPushSender);
    expect(await pushSenderFromEnv({})).toBeInstanceOf(UnconfiguredPushSender);
  });
});

describe("sendToUser", () => {
  let handle: Awaited<ReturnType<typeof createTestDatabase>>;
  let hostId: string;
  let otherId: string;

  const tokensOf = async (userId: string) =>
    (await handle.db.select({ token: deviceToken.token }).from(deviceToken).where(eq(deviceToken.userId, userId))).map((r) => r.token).sort();

  beforeAll(async () => {
    handle = await createTestDatabase("dcard_test_worker_push");
    const users = await handle.db
      .insert(userAccount)
      .values(["push-host", "push-other"].map((u) => ({ firebaseUid: u, email: `${u}@example.com`, authProvider: "password" as const })))
      .returning({ id: userAccount.id });
    [hostId, otherId] = users.map((u) => u.id) as [string, string];
  });

  afterAll(async () => {
    await handle?.close();
  });

  beforeEach(async () => {
    await handle.db.delete(deviceToken);
    for (const [userId, token, platform, app] of [
      [hostId, "phone", "android", "mobile"],
      [hostId, "tablet", "ios", "mobile"],
      [hostId, "gate", "android", "door"],
      [hostId, "stale", "android", "mobile"],
      [otherId, "other-phone", "android", "mobile"],
    ] as const) {
      await registerDeviceToken(handle.db, userId, { token, platform, app });
    }
  });

  it("sends to every device of the user only", async () => {
    const sender = new FakePushSender();
    const result = await sendToUser(handle.db, sender, hostId, NOTE);
    expect(result).toEqual({ status: "sent", tokens: 4, sent: 4, failed: 0, removed: 0 });
    expect(sender.calls).toHaveLength(1);
    expect(sender.calls[0]!.tokens.sort()).toEqual(["gate", "phone", "stale", "tablet"]);
    expect(sender.calls[0]!.notification).toEqual(NOTE);
  });

  it("removes tokens FCM reports as invalid and keeps the rest", async () => {
    const sender = new FakePushSender({
      stale: "messaging/registration-token-not-registered",
      tablet: "messaging/invalid-argument",
      gate: "messaging/internal-error", // transient: keep
    });
    const result = await sendToUser(handle.db, sender, hostId, NOTE);
    expect(result).toEqual({ status: "sent", tokens: 4, sent: 1, failed: 3, removed: 2 });
    expect(await tokensOf(hostId)).toEqual(["gate", "phone"]);
    expect(await tokensOf(otherId)).toEqual(["other-phone"]);
  });

  it("keeps tokens when every send fails with invalid-argument (payload problem, not tokens)", async () => {
    const all = Object.fromEntries(["phone", "tablet", "gate", "stale"].map((t) => [t, "messaging/invalid-argument"]));
    const result = await sendToUser(handle.db, new FakePushSender(all), hostId, NOTE);
    expect(result).toMatchObject({ status: "sent", failed: 4, removed: 0 });
    expect(await tokensOf(hostId)).toHaveLength(4);
  });

  it("reports not configured and keeps tokens when FCM keys are placeholders", async () => {
    const result = await sendToUser(handle.db, new UnconfiguredPushSender(), hostId, NOTE);
    expect(result).toEqual({ status: "not_configured", tokens: 4 });
    expect(await tokensOf(hostId)).toHaveLength(4);
  });

  it("does nothing for a user without devices", async () => {
    await handle.db.delete(deviceToken).where(eq(deviceToken.userId, otherId));
    const sender = new FakePushSender();
    expect(await sendToUser(handle.db, sender, otherId, NOTE)).toEqual({ status: "sent", tokens: 0, sent: 0, failed: 0, removed: 0 });
    expect(sender.calls).toHaveLength(0);
  });

  it("processes a notify job for each user (walk-in push to host + approvers), deduplicating users", async () => {
    const sender = new FakePushSender();
    const process = createPushProcessor(handle.db, sender, () => {});
    const job = { data: { userIds: [hostId, otherId, hostId], title: "Mgeni", body: "Asha · 1", data: { type: "walk_in", walkInId: "w1" } } };
    const result = await process(job as never);
    expect(result).toMatchObject({ users: 3, sent: 5, notConfigured: false });
    expect(sender.calls.map((c) => c.tokens.length).sort()).toEqual([1, 4]);
    expect(sender.calls[0]!.notification.data).toEqual({ type: "walk_in", walkInId: "w1" });
    const skipped = await createPushProcessor(handle.db, new UnconfiguredPushSender(), () => {})(job as never);
    expect(skipped.notConfigured).toBe(true);
  });
});
