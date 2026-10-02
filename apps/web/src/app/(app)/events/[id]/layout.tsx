import type { ReactNode } from "react";
import { EventNav } from "../../../../features/events/event-nav";
import { loadEventOr404, requireAccount } from "../../../../server/events-page-data";

/** Every event page shares the section navigation; the pages keep their own access checks. */
export default async function EventLayout({ children, params }: { children: ReactNode; params: Promise<{ id: string }> }) {
  const account = await requireAccount();
  const event = await loadEventOr404(account.id, (await params).id);
  return (
    <div className="space-y-6">
      <div className="print:hidden">
        <EventNav event={event} />
      </div>
      {children}
    </div>
  );
}
