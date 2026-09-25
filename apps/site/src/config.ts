// Site settings from the build environment. Contact buttons stay hidden until set (WEB-4).
const env = import.meta.env;

/** Accepts 0754…, +255 754…, 255754… or 754… and returns 255XXXXXXXXX (or "" when unset). */
const intl = (v: string | undefined) => {
  const d = (v ?? "").replace(/\D/g, "");
  if (!d) return "";
  if (d.startsWith("255")) return d;
  if (d.startsWith("0")) return `255${d.slice(1)}`;
  return d.length === 9 ? `255${d}` : d;
};

export const site = {
  /** The D-Card web app. Unset until it is deployed: calls to action then go to #contact. */
  appUrl: (env.SITE_APP_URL ?? "").replace(/\/$/, ""),
  /** WhatsApp number in international form, e.g. 255754123456. */
  whatsapp: intl(env.SITE_WHATSAPP),
  /** Phone number in international form, e.g. 255754123456. */
  phone: intl(env.SITE_PHONE),
  email: env.SITE_EMAIL ?? "",
};

export const localPhone = (intl: string) => (intl.startsWith("255") ? `0${intl.slice(3, 6)} ${intl.slice(6, 9)} ${intl.slice(9)}` : intl);
