import type { TeamInviteEmailJob } from "@dcard/core";
import type { EmailMessage } from "./sender.js";

const ROLE = {
  sw: { treasurer: "Mweka hazina", committee: "Mjumbe wa kamati", door_staff: "Mlinzi wa mlango", walkin_approver: "Mwidhinishaji wa wageni" },
  en: { treasurer: "Treasurer", committee: "Committee member", door_staff: "Door staff", walkin_approver: "Walk-in approver" },
} as const;

const escape = (s: string) => s.replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[c]!);

/** Bilingual plain template (docs/design/integrations/email.md). The primary language comes first. */
export function teamInviteEmail(job: TeamInviteEmailJob): Omit<EmailMessage, "to"> {
  const sw = {
    subject: `Mwaliko wa kujiunga na ${job.eventTitle} kwenye D-Card`,
    body: `Umealikwa kujiunga na timu ya "${job.eventTitle}" kama ${ROLE.sw[job.role]}. Fungua kiungo hiki ndani ya siku 7 kukubali:`,
  };
  const en = {
    subject: `Invitation to join ${job.eventTitle} on D-Card`,
    body: `You have been invited to join the team for "${job.eventTitle}" as ${ROLE.en[job.role]}. Open this link within 7 days to accept:`,
  };
  const [first, second] = job.language === "en" ? [en, sw] : [sw, en];
  const text = `${first.body}\n${job.link}\n\n—\n\n${second.body}\n${job.link}\n`;
  const html = [first, second]
    .map((l) => `<p>${escape(l.body)}</p><p><a href="${escape(job.link)}">${escape(job.link)}</a></p>`)
    .join("<hr>");
  return { subject: first.subject, text, html };
}
