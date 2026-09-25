import { notFound } from "next/navigation";
import { EditEventForm } from "../../../../../features/events/edit-event-form";
import { isoToLocal, type EventFormValues } from "../../../../../features/events/event-form";
import { localPhone } from "../../../../../features/events/format";
import { loadCatalogue, loadEventOr404, requireAccount } from "../../../../../server/events-page-data";

export default async function EditEventPage({ params }: { params: Promise<{ id: string }> }) {
  const account = await requireAccount();
  const event = await loadEventOr404(account.id, (await params).id);
  if (event.access !== "host") notFound();
  const { plans, eventTypes } = await loadCatalogue();
  const plan = plans.find((p) => p.key === event.plan.key);
  const initial: EventFormValues = {
    planKey: event.plan.key,
    eventTypeKey: event.eventType.key,
    title: event.title,
    startsAt: isoToLocal(event.startsAt.toISOString()),
    endsAt: event.endsAt ? isoToLocal(event.endsAt.toISOString()) : "",
    venueName: event.venueName ?? "",
    venueAddress: event.venueAddress ?? "",
    venueMapUrl: event.venueMapUrl ?? "",
    contactName: event.contactName,
    contactPhone: localPhone(event.contactPhone),
    contact2Name: event.contact2Name ?? "",
    contact2Phone: event.contact2Phone ? localPhone(event.contact2Phone) : "",
    confirmationEnabled: event.confirmationEnabled,
    confirmationOffsetDays: String(event.confirmationOffsetDays),
    headcountPct: String(event.headcountPct),
    autoUpgradeEnabled: event.autoUpgradeEnabled,
    singleAmount: event.singleAmount?.toString() ?? "",
    budgetAmount: event.budgetAmount?.toString() ?? "",
    doubleAmount: event.doubleAmount?.toString() ?? "",
    photoAlbumUrl: event.photoAlbumUrl ?? "",
  };
  return (
    <EditEventForm eventId={event.id} initial={initial} eventTypes={eventTypes} autoUpgradeAllowed={Boolean(plan?.autoUpgrade)} />
  );
}
