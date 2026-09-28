import { MESSAGE_JOBS, prepareSend, recordSendOutcome, type SendMessageJob, type WhatsAppReply } from "@dcard/core";
import { messageLog } from "@dcard/db";
import type { Database } from "@dcard/db";
import type { Job } from "bullmq";
import { PermanentSendError, ProviderNotConfiguredError, type SmsSender, type WhatsAppSender } from "./senders.js";

export const SEND_ATTEMPTS = 5;

export type SendDeps = {
  db: Database;
  sms: SmsSender;
  whatsapp: WhatsAppSender;
  appUrl?: string;
  confirmToken?: (invitationId: string) => string;
  /** Card image PNG for the WhatsApp card header (T03-02). */
  cardImage?: (linkToken: string, language: "sw" | "en") => Promise<Uint8Array>;
  log?: (msg: string) => void;
};

/** Sends one message_log row. Throws on retryable failures so BullMQ retries with backoff. */
export function createSendProcessor(deps: SendDeps) {
  const log = deps.log ?? console.log;
  return async (job: Job<SendMessageJob>): Promise<string> => {
    const payload = await prepareSend(deps.db, job.data.logId, { appUrl: deps.appUrl, confirmToken: deps.confirmToken });
    if (!payload) return "skipped";
    if (payload.kind === "held") {
      await recordSendOutcome(deps.db, payload.logId, { status: "held", error: payload.reason, final: true });
      return "held";
    }
    try {
      if (payload.kind === "sms") {
        // Our message_log id is the NextSMS `reference` (NextSMS returns no message id at send).
        const sent = await deps.sms.send(payload.to, payload.text, payload.logId);
        await recordSendOutcome(deps.db, payload.logId, {
          status: "sent",
          providerMessageId: sent.providerMessageId,
          body: payload.text,
          segments: sent.segments ?? payload.segments,
          language: payload.language,
        });
      } else {
        let headerImageId: string | undefined;
        if (payload.headerCardToken) {
          if (!deps.cardImage) throw new ProviderNotConfiguredError("card image renderer not configured");
          const png = await deps.cardImage(payload.headerCardToken, payload.language);
          headerImageId = await deps.whatsapp.uploadImage(png, "dcard-card.png");
        }
        const { providerMessageId } = await deps.whatsapp.sendTemplate({ ...payload, headerImageId });
        await recordSendOutcome(deps.db, payload.logId, {
          status: "sent",
          providerMessageId,
          category: payload.category,
          language: payload.language,
          templateId: payload.templateId,
          detail: { template: payload.templateName, language: payload.language, params: payload.bodyParams },
        });
      }
      return "sent";
    } catch (err) {
      const message = err instanceof Error ? err.message : String(err);
      if (err instanceof ProviderNotConfiguredError) {
        await recordSendOutcome(deps.db, payload.logId, { status: "held", error: message, final: true });
        return "held";
      }
      const final = err instanceof PermanentSendError || job.attemptsMade + 1 >= (job.opts.attempts ?? SEND_ATTEMPTS);
      await recordSendOutcome(deps.db, payload.logId, { status: "failed", error: message, final });
      log(`message:${final ? "failed" : "retry"} log=${payload.logId} ${message}`);
      if (final) return "failed";
      throw err;
    }
  };
}

/**
 * CNF-2 replies (acknowledgement / "already recorded"): free-form text inside the 24 h window
 * the guest's tap opened. Logged as an outbound message_log row without a message type.
 */
export function createReplyProcessor(deps: Pick<SendDeps, "db" | "whatsapp" | "log">) {
  const log = deps.log ?? console.log;
  return async (job: Job<WhatsAppReply>): Promise<string> => {
    const r = job.data;
    const row = { eventId: r.eventId, invitationId: r.invitationId, channel: "whatsapp" as const, direction: "outbound" as const, toPhone: r.to, language: r.language, body: r.text, detail: { kind: r.kind, inboundId: r.inboundId } };
    try {
      const { providerMessageId } = await deps.whatsapp.sendText(r.to, r.text);
      await deps.db.insert(messageLog).values({ ...row, status: "sent", providerMessageId, sentAt: new Date(), attempts: job.attemptsMade + 1 });
      return "sent";
    } catch (err) {
      const message = err instanceof Error ? err.message : String(err);
      if (err instanceof ProviderNotConfiguredError) {
        await deps.db.insert(messageLog).values({ ...row, status: "held", error: message });
        return "held";
      }
      const final = err instanceof PermanentSendError || job.attemptsMade + 1 >= (job.opts.attempts ?? SEND_ATTEMPTS);
      if (!final) throw err;
      await deps.db.insert(messageLog).values({ ...row, status: "failed", error: message.slice(0, 500), attempts: job.attemptsMade + 1 });
      log(`reply:failed ${r.inboundId} ${message}`);
      return "failed";
    }
  };
}

/** The whatsapp queue carries template sends (`send`) and window replies (`reply`). */
export function createWhatsAppProcessor(deps: SendDeps) {
  const send = createSendProcessor(deps);
  const reply = createReplyProcessor(deps);
  return (job: Job) => (job.name === MESSAGE_JOBS.reply ? reply(job as Job<WhatsAppReply>) : send(job as Job<SendMessageJob>));
}
