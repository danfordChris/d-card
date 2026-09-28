import { listTeam } from "@dcard/core";
import { getTranslations } from "next-intl/server";
import Link from "next/link";
import { notFound } from "next/navigation";
import { TeamManager, type TeamData } from "../../../../../features/team/team-manager";
import { getDb } from "../../../../../server/db";
import { loadEventOr404, requireAccount } from "../../../../../server/events-page-data";
import { PageHeader } from "../../../../../components/ui";

export default async function TeamPage({ params }: { params: Promise<{ id: string }> }) {
  const account = await requireAccount();
  const event = await loadEventOr404(account.id, (await params).id);
  if (event.access !== "host") notFound();
  const [team, t] = await Promise.all([listTeam(getDb(), account.id, event.id), getTranslations("team")]);
  return (
    <section className="space-y-6">
      <PageHeader
        eyebrow={
          <Link href={`/events/${event.id}`} className="hover:text-primary hover:underline">
            {event.title}
          </Link>
        }
        title={t("title")}
      />
      <TeamManager eventId={event.id} initial={JSON.parse(JSON.stringify(team)) as TeamData} />
    </section>
  );
}
