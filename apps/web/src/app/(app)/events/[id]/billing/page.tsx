import { getTranslations } from "next-intl/server";
import Link from "next/link";
import { notFound } from "next/navigation";
import { BillingView } from "../../../../../features/billing/billing-view";
import type { CheckoutMode } from "../../../../../features/billing/types";
import { loadCatalogue, loadEventOr404, requireAccount } from "../../../../../server/events-page-data";

const MODES: CheckoutMode[] = ["buy", "add", "upgrade"];

// T05-02: plan, guest cards, receipts and checkout. Host only.
export default async function BillingPage({
  params,
  searchParams,
}: {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ [key: string]: string | string[] | undefined }>;
}) {
  const account = await requireAccount();
  const event = await loadEventOr404(account.id, (await params).id);
  if (event.access !== "host") notFound();
  const [{ plans }, t, query] = await Promise.all([loadCatalogue(), getTranslations("billing"), searchParams]);
  const requested = typeof query.checkout === "string" ? query.checkout : undefined;
  const initialMode = MODES.find((m) => m === requested);
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
      <BillingView
        eventId={event.id}
        plans={plans.map((p) => ({ key: p.key, name: p.name, pricePerGuest: p.pricePerGuest }))}
        initialMode={initialMode}
      />
    </section>
  );
}
