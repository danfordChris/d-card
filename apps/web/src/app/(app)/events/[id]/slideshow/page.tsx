import { notFound } from "next/navigation";
import { LiveSlideshow } from "../../../../../features/media/live-slideshow";
import { loadEventOr404, requireAccount } from "../../../../../server/events-page-data";

// MED-8 (Premium): full-screen venue slideshow. The plan check (limits.slideshow) happens in the
// client from the media settings, which the API already gates.
export default async function SlideshowPage({ params }: { params: Promise<{ id: string }> }) {
  const account = await requireAccount();
  const event = await loadEventOr404(account.id, (await params).id);
  if (event.access !== "host" && event.access !== "committee") notFound();
  return <LiveSlideshow eventId={event.id} />;
}
