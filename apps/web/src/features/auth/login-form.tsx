"use client";

import { signInWithEmailAndPassword } from "firebase/auth";
import { useTranslations } from "next-intl";
import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { safeNext } from "./safe-next";
import { useState, type FormEvent } from "react";
import { Alert, Button, Field, Input } from "../../components/ui";
import { firebaseAuth, startServerSession } from "../../lib/firebase-client";
import { mapFirebaseError, validateEmail, validatePassword, type AuthErrorKey } from "./validation";

export function LoginForm() {
  const t = useTranslations("auth");
  const router = useRouter();
  const next = safeNext(useSearchParams().get("next"));
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [errors, setErrors] = useState<{ email?: AuthErrorKey; password?: AuthErrorKey; form?: AuthErrorKey }>({});
  const [busy, setBusy] = useState(false);

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    const found = { email: validateEmail(email), password: validatePassword(password, { minLength: 1 }) };
    setErrors(found);
    if (found.email || found.password) return;
    setBusy(true);
    try {
      const cred = await signInWithEmailAndPassword(firebaseAuth(), email.trim(), password);
      await startServerSession(await cred.user.getIdToken());
      router.replace(next);
    } catch (err) {
      console.error("sign-in failed", err);
      setErrors({ form: mapFirebaseError((err as { code?: string }).code) });
    } finally {
      setBusy(false);
    }
  }

  return (
    <form onSubmit={onSubmit} noValidate className="space-y-4">
      <h1 className="font-display text-3xl font-bold">{t("loginTitle")}</h1>
      {errors.form && <Alert tone="error">{t(`errors.${errors.form}`)}</Alert>}
      <Field label={t("email")} error={errors.email && t(`errors.${errors.email}`)}>
        <Input type="email" autoComplete="email" value={email} onChange={(e) => setEmail(e.target.value)} />
      </Field>
      <Field label={t("password")} error={errors.password && t(`errors.${errors.password}`)}>
        <Input type="password" autoComplete="current-password" value={password} onChange={(e) => setPassword(e.target.value)} />
      </Field>
      <Button type="submit" size="lg" className="w-full" disabled={busy}>
        {t("loginSubmit")}
      </Button>
      <div className="flex justify-between text-sm">
        <Link className="text-primary hover:underline" href="/reset-password">
          {t("forgotPassword")}
        </Link>
        <span>
          {t("noAccount")}{" "}
          <Link className="text-primary hover:underline" href="/signup">
            {t("signupSubmit")}
          </Link>
        </span>
      </div>
    </form>
  );
}
