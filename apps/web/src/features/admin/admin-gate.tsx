"use client";

import { useTranslations } from "next-intl";
import { useRouter } from "next/navigation";
import { useCallback, useState, type ReactNode } from "react";
import { AdminLockContext } from "./admin-gate-context";
import type { TotpStatus } from "./platform-types";
import { TwoStepSignIn } from "./two-step-sign-in";

/**
 * AUTH-7: every admin page sits behind the two-step sign-in. The server layout passes the status
 * (and leaves the page out until verified); an API `second_factor_required` locks it again.
 */
export function AdminGate({ status, children }: { status: TotpStatus; children?: ReactNode }) {
  const router = useRouter();
  const t = useTranslations("adminPlatform.list");
  // A client-side override only applies to the server status it was made for; a fresh render resets it.
  const [override, setOverride] = useState<{ for: TotpStatus; locked: boolean } | null>(null);
  const current = override && override.for === status ? override.locked : null;
  const locked = current ?? !status.verified;

  const lock = useCallback(() => setOverride({ for: status, locked: true }), [status]);
  const verified = useCallback(() => {
    setOverride({ for: status, locked: false });
    router.refresh();
  }, [router, status]);

  if (locked) return <TwoStepSignIn status={{ enrolled: status.enrolled || status.verified }} onVerified={verified} />;
  if (children === undefined || children === null)
    return (
      <p className="text-sm text-muted" role="status">
        {t("loading")}
      </p>
    );
  return <AdminLockContext.Provider value={lock}>{children}</AdminLockContext.Provider>;
}
