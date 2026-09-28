import type { PushNotifyJob } from "@dcard/core";
import type { Database } from "@dcard/db";
import type { Job } from "bullmq";
import { sendToUser, type PushSender } from "./push.js";

/** Queue `push`, job `notify`: one FCM push per user (all their devices). Missing FCM keys skip quietly. */
export function createPushProcessor(db: Database, sender: PushSender, log: (msg: string) => void = console.log) {
  return async (job: Job<PushNotifyJob>): Promise<{ users: number; sent: number; notConfigured: boolean }> => {
    const { userIds, title, body, data } = job.data;
    let sent = 0;
    let notConfigured = false;
    for (const userId of new Set(userIds)) {
      const r = await sendToUser(db, sender, userId, { title, body, data });
      if (r.status === "not_configured") notConfigured = true;
      else sent += r.sent;
    }
    if (notConfigured) log(`push:skipped ${data?.type ?? "notify"} (FCM not configured)`);
    return { users: userIds.length, sent, notConfigured };
  };
}
