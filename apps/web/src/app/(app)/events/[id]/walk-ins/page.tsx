import { walkInApproverIds } from "@dcard/core";
import { getTranslations } from "next-intl/server";
import Link from "next/link";
import { notFound } from "next/navigation";
import { WalkInApprovals } from "../../../../../features/walk-ins/walk-in-approvals";
import { getDb } from "../../../../../server/db";
import { loadEventOr404, requireAccount } from "../../../../../server/events-page-data";

// CHK-8 / CHK-8a: the host and walk-in approvers decide; committee members follow along read-only.
export default async function WalkInsPage({ params }: { params: Promise<{ id: string }> }) {
  const account = await requireAccount();
  const event = await loadEventOr404(account.id, (await params).id);
  if (event.access !== "host" && event.access !== "committee" && event.access !== "walkin_approver") notFound();
  // A user may hold several roles (e.g. committee + walk-in approver): ask the approver list, not `access`.
  const canDecide = (await walkInApproverIds(getDb(), event.id)).includes(account.id);
  const t = await getTranslations("walkIns");
  return (
    <section className="space-y-6">
      <div>
        <Link href={`/events/${event.id}`} className="text-sm text-brand-600 hover:underline">
          ← {t("back")}
        </Link>
        <h1 className="mt-1 text-2xl font-semibold">
          {t("title")} · {event.title}
        </h1>
      </div>
      <WalkInApprovals eventId={event.id} canDecide={canDecide} />
    </section>
  );
}
