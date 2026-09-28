"use client";

import { Logout01Icon } from "@hugeicons/core-free-icons";
import { HugeiconsIcon } from "@hugeicons/react";
import { signOut } from "firebase/auth";
import { useTranslations } from "next-intl";
import { useRouter } from "next/navigation";
import { firebaseAuth } from "../../lib/firebase-client";
import { Button } from "../ui";
import { apiFetch } from "../../lib/api-fetch";

export function SignOutButton() {
  const t = useTranslations("app");
  const router = useRouter();
  return (
    <Button
      variant="ghost"
      className="w-full justify-start px-3"
      onClick={async () => {
        await apiFetch("/api/v1/session", { method: "DELETE" });
        await signOut(firebaseAuth()).catch(() => undefined);
        router.replace("/login");
      }}
    >
      <HugeiconsIcon icon={Logout01Icon} size={20} strokeWidth={1.7} aria-hidden />
      {t("signOut")}
    </Button>
  );
}
