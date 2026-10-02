import { useTranslations } from "next-intl";
import { Badge, type Tone } from "../../components/ui";

const TONES: Record<"draft" | "published" | "completed" | "cancelled", Tone> = {
  draft: "neutral",
  published: "success",
  completed: "brand",
  cancelled: "danger",
};

export function StatusBadge({ status }: { status: keyof typeof TONES }) {
  const t = useTranslations("events.status");
  return <Badge tone={TONES[status]}>{t(status)}</Badge>;
}
