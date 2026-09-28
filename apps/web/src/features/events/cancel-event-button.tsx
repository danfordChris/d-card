"use client";

import { useTranslations } from "next-intl";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { Button } from "../../components/ui";
import { sendJson } from "./api";

export function CancelEventButton({ eventId }: { eventId: string }) {
  const t = useTranslations("events");
  const router = useRouter();
  const [busy, setBusy] = useState(false);
  return (
    <Button
      variant="danger"
      disabled={busy}
      onClick={async () => {
        if (!window.confirm(t("summary.cancelConfirm"))) return;
        setBusy(true);
        await sendJson(`/api/v1/events/${eventId}/cancel`, "POST");
        setBusy(false);
        router.refresh();
      }}
    >
      {t("summary.cancel")}
    </Button>
  );
}
