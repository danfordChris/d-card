import { useTranslations } from "next-intl";
import { cn } from "../../components/ui";

const TONES = {
  draft: "bg-gray-100 text-gray-700",
  published: "bg-green-100 text-green-800",
  completed: "bg-blue-100 text-blue-800",
  cancelled: "bg-red-100 text-red-800",
} as const;

export function StatusBadge({ status }: { status: keyof typeof TONES }) {
  const t = useTranslations("events.status");
  return <span className={cn("rounded-full px-2.5 py-0.5 text-xs font-medium", TONES[status])}>{t(status)}</span>;
}
