"use client";

import { useTranslations } from "next-intl";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { Alert, Button } from "../../components/ui";

export function AcceptInviteButton({ token }: { token: string }) {
  const t = useTranslations("invitePage");
  const router = useRouter();
  const [error, setError] = useState<string>();
  const [busy, setBusy] = useState(false);
  return (
    <div className="space-y-3">
      {error && <Alert tone="error">{error}</Alert>}
      <Button
        className="w-full"
        disabled={busy}
        onClick={async () => {
          setBusy(true);
          const res = await fetch(`/api/v1/invites/${encodeURIComponent(token)}/accept`, { method: "POST" }).catch(() => null);
          setBusy(false);
          if (res?.ok) {
            const { eventId } = (await res.json()) as { eventId: string };
            router.push(`/events/${eventId}`);
            return;
          }
          setError(t("invalid"));
        }}
      >
        {t("accept")}
      </Button>
    </div>
  );
}
