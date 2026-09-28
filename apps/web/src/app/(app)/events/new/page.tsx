import { EventWizard } from "../../../../features/events/event-wizard";
import { loadCatalogue, requireAccount } from "../../../../server/events-page-data";

export default async function NewEventPage() {
  await requireAccount();
  const { plans, eventTypes } = await loadCatalogue();
  return <EventWizard plans={plans} eventTypes={eventTypes} />;
}
