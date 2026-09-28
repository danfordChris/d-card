// Admin reports reuse the billing money format ("TSh 1,234,500") so amounts read the same everywhere.
export { formatMoney as formatTzs } from "../billing/format";

export const formatCount = (n: number) => n.toLocaleString("en-US");

export const formatPercent = (n: number | null) => (n === null ? "—" : `${n.toLocaleString("en-US", { maximumFractionDigits: 1 })}%`);
