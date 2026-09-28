"use client";

import { createUserWithEmailAndPassword, sendEmailVerification } from "firebase/auth";
import { useTranslations } from "next-intl";
import Link from "next/link";
import { useSearchParams } from "next/navigation";
import { safeNext } from "./safe-next";
import { useState, type FormEvent } from "react";
import { Alert, Button, Field, Input } from "../../components/ui";
import { firebaseAuth, startServerSession } from "../../lib/firebase-client";
import { mapFirebaseError, validateEmail, validatePassword, type AuthErrorKey } from "./validation";

export function SignupForm() {
  const t = useTranslations("auth");
  const nextParam = useSearchParams().get("next");
  const next = safeNext(nextParam);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [errors, setErrors] = useState<{ email?: AuthErrorKey; password?: AuthErrorKey; form?: AuthErrorKey }>({});
  const [busy, setBusy] = useState(false);
  const [sent, setSent] = useState(false);

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    const found = { email: validateEmail(email), password: validatePassword(password) };
    setErrors(found);
    if (found.email || found.password) return;
    setBusy(true);
    try {
      const cred = await createUserWithEmailAndPassword(firebaseAuth(), email.trim(), password);
      await sendEmailVerification(cred.user);
      await startServerSession(await cred.user.getIdToken());
      setSent(true);
    } catch (err) {
      console.error("sign-in failed", err);
      setErrors({ form: mapFirebaseError((err as { code?: string }).code) });
    } finally {
      setBusy(false);
    }
  }

  if (sent) {
    return (
      <div className="space-y-4">
        <Alert tone="success">{t("verifySent")}</Alert>
        <Link className="text-sm text-brand-600 hover:underline" href={next}>
          {t("loginSubmit")} →
        </Link>
      </div>
    );
  }

  return (
    <form onSubmit={onSubmit} noValidate className="space-y-4">
      <h1 className="text-xl font-semibold">{t("signupTitle")}</h1>
      {errors.form && <Alert tone="error">{t(`errors.${errors.form}`)}</Alert>}
      <Field label={t("email")} error={errors.email && t(`errors.${errors.email}`)}>
        <Input type="email" autoComplete="email" value={email} onChange={(e) => setEmail(e.target.value)} />
      </Field>
      <Field label={t("password")} error={errors.password && t(`errors.${errors.password}`)}>
        <Input type="password" autoComplete="new-password" value={password} onChange={(e) => setPassword(e.target.value)} />
      </Field>
      <Button type="submit" className="w-full" disabled={busy}>
        {t("signupSubmit")}
      </Button>
      <p className="text-sm">
        {t("haveAccount")}{" "}
        <Link className="text-brand-600 hover:underline" href={nextParam ? `/login?next=${encodeURIComponent(next)}` : "/login"}>
          {t("loginSubmit")}
        </Link>
      </p>
    </form>
  );
}
