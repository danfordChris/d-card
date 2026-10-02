"use client";

import { sendPasswordResetEmail } from "firebase/auth";
import { useTranslations } from "next-intl";
import Link from "next/link";
import { useState, type FormEvent } from "react";
import { Alert, Button, Field, Input } from "../../components/ui";
import { firebaseAuth } from "../../lib/firebase-client";
import { validateEmail, type AuthErrorKey } from "./validation";

export function ResetForm() {
  const t = useTranslations("auth");
  const [email, setEmail] = useState("");
  const [error, setError] = useState<AuthErrorKey | undefined>();
  const [sent, setSent] = useState(false);

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    const found = validateEmail(email);
    setError(found);
    if (found) return;
    try {
      await sendPasswordResetEmail(firebaseAuth(), email.trim());
    } catch {
      // Same message whether or not the account exists (no account enumeration).
    }
    setSent(true);
  }

  return (
    <form onSubmit={onSubmit} noValidate className="space-y-4">
      <h1 className="font-display text-3xl font-bold">{t("resetTitle")}</h1>
      {sent && <Alert tone="success">{t("resetSent")}</Alert>}
      <Field label={t("email")} error={error && t(`errors.${error}`)}>
        <Input type="email" autoComplete="email" value={email} onChange={(e) => setEmail(e.target.value)} />
      </Field>
      <Button type="submit" className="w-full">
        {t("resetSubmit")}
      </Button>
      <Link className="block text-sm text-primary hover:underline" href="/login">
        {t("backToLogin")}
      </Link>
    </form>
  );
}
