import { EMAIL_JOBS, type TeamInviteEmailJob } from "@dcard/core";
import type { Job } from "bullmq";
import type { EmailSender, SendResult } from "../email/sender.js";
import { teamInviteEmail } from "../email/templates.js";

export function createEmailProcessor(sender: EmailSender, log: (msg: string) => void = console.log) {
  return async (job: Job<TeamInviteEmailJob>): Promise<SendResult> => {
    if (job.name !== EMAIL_JOBS.teamInvite) throw new Error(`Unknown email job: ${job.name}`);
    const result = await sender.send({ to: job.data.to, ...teamInviteEmail(job.data) });
    if (!result.sent) log(`email:skipped invite=${job.data.inviteId} reason="${result.skipped}"`);
    return result;
  };
}
