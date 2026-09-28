import { DomainError, getInviteInfo } from "@dcard/core";
import { getTranslations } from "next-intl/server";
import Link from "next/link";
import { Alert } from "../../../../components/ui";
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
      <h1 className="text-xl font-semibold">{t("title")}</h1>
      <p className="text-gray-700">{t("body", { event: info.eventTitle, role: roles(info.role) })}</p>
      {account ? (
        <AcceptInviteButton token={token} />
      ) : (
        <div className="flex flex-col gap-2 sm:flex-row">
          <Link href={`/login?next=${next}`} className="rounded-lg bg-brand-600 px-4 py-2 text-center text-sm font-semibold text-white hover:bg-brand-700">
            {t("signIn")}
          </Link>
          <Link href={`/signup?next=${next}`} className="rounded-lg bg-white px-4 py-2 text-center text-sm font-semibold ring-1 ring-gray-300 hover:bg-gray-50">
            {t("signUp")}
          </Link>
        </div>
      )}
    </div>
  );
}
