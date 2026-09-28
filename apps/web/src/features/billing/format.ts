// One money formatter for every billing screen: whole TZS as "TSh 50,000".

const NUMBER = new Intl.NumberFormat("en-US", { maximumFractionDigits: 0 });

export function formatMoney(amount: number): string {
  const sign = amount < 0 ? "−" : "";
  return `${sign}TSh ${NUMBER.format(Math.abs(Math.round(amount)))}`;
}

/** Receipt dates are always shown in Tanzanian time. */
export function formatPaymentDate(iso: string, locale: string): string {
  return new Intl.DateTimeFormat(locale === "sw" ? "sw-TZ" : "en-GB", {
    dateStyle: "medium",
    timeStyle: "short",
    timeZone: "Africa/Dar_es_Salaam",
  }).format(new Date(iso));
}
