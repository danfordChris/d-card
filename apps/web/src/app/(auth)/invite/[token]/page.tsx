import { DomainError, getInviteInfo } from "@dcard/core";
import { getTranslations } from "next-intl/server";
import Link from "next/link";
import { Alert, buttonClasses } from "../../../../components/ui";
import { AcceptInviteButton } from "../../../../features/team/accept-invite-button";
import { getDb } from "../../../../server/db";
import { getSessionAccount } from "../../../../server/session";

export const dynamic = "force-dynamic";

export default async function InvitePage({ params }: { params: Promise<{ token: string }> }) {
  const { token } = await params;
  const [t, roles] = await Promise.all([getTranslations("invitePage"), getTranslations("team.roles")]);
  let info: Awaited<ReturnType<typeof getInviteInfo>>;
  try {
    info = await getInviteInfo(getDb(), token);
  } catch (err) {
    if (err instanceof DomainError) {
      return <Alert tone="error">{err.code === "not_found" ? t("notFound") : t("invalid")}</Alert>;
    }
    throw err;
  }
  const account = await getSessionAccount();
  const next = encodeURIComponent(`/invite/${token}`);
  return (
    <div className="space-y-4">
      <h1 className="font-display text-3xl font-bold">{t("title")}</h1>
      <p className="text-ink">{t("body", { event: info.eventTitle, role: roles(info.role) })}</p>
      {account ? (
        <AcceptInviteButton token={token} />
      ) : (
        <div className="flex flex-col gap-2 sm:flex-row">
          <Link href={`/login?next=${next}`} className={buttonClasses("primary")}>
            {t("signIn")}
          </Link>
          <Link href={`/signup?next=${next}`} className={buttonClasses("tonal")}>
            {t("signUp")}
          </Link>
        </div>
      )}
    </div>
  );
}
