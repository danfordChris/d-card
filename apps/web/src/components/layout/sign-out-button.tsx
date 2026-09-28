"use client";

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
      onClick={async () => {
        await apiFetch("/api/v1/session", { method: "DELETE" });
        await signOut(firebaseAuth()).catch(() => undefined);
        router.replace("/login");
      }}
    >
      {t("signOut")}
    </Button>
  );
}
