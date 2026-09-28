// CSV writer for host exports (T06-04). UTF-8 with a BOM so Excel detects the encoding.

export type CsvCell = string | number | boolean | null | undefined;

const BOM = "\uFEFF";
/** Spreadsheet apps treat these leading characters as a formula (CSV/formula injection). */
const FORMULA_START = /^[=+\-@\t\r]/;

/** One cell: guards formula starts with a leading quote, then quotes when needed. Numbers pass through. */
export function csvCell(value: CsvCell): string {
  if (value === null || value === undefined) return "";
  if (typeof value === "number") return Number.isFinite(value) ? String(value) : "";
  let text = String(value);
  if (FORMULA_START.test(text)) text = `'${text}`;
  return /[",\r\n]/.test(text) ? `"${text.replace(/"/g, '""')}"` : text;
}

/** Header plus rows, CRLF line endings (RFC 4180), prefixed with a BOM. */
export function toCsv(header: readonly string[], rows: readonly (readonly CsvCell[])[]): string {
  return BOM + [header, ...rows].map((row) => row.map(csvCell).join(",")).join("\r\n") + "\r\n";
}
