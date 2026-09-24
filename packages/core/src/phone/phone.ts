import { InvalidPhoneError } from "../errors.js";

// docs/design/features/guests-and-cards.md (GST-3): all phones are stored as
// "255" + 9 digits. Accepted inputs: 0XXXXXXXXX, +255XXXXXXXXX, 255XXXXXXXXX, XXXXXXXXX,
// with optional spaces, dashes, dots or parentheses.

const SEPARATORS = /[\s\-().]/g;

export function normalisePhone(input: string): string {
  const cleaned = input.trim().replace(SEPARATORS, "");
  const digits = cleaned.startsWith("+") ? cleaned.slice(1) : cleaned;
  if (!/^\d+$/.test(digits)) {
    throw new InvalidPhoneError(input);
  }
  let national: string;
  if (digits.length === 12 && digits.startsWith("255")) {
    national = digits.slice(3);
  } else if (digits.length === 10 && digits.startsWith("0") && !cleaned.startsWith("+")) {
    national = digits.slice(1);
  } else if (digits.length === 9 && !cleaned.startsWith("+")) {
    national = digits;
  } else {
    throw new InvalidPhoneError(input);
  }
  return `255${national}`;
}

export function isValidPhone(input: string): boolean {
  try {
    normalisePhone(input);
    return true;
  } catch {
    return false;
  }
}

/** Formats a stored phone (255XXXXXXXXX) for display in SMS: "0754 123 456". */
export function formatLocalPhone(stored: string): string {
  const normalised = normalisePhone(stored);
  const n = normalised.slice(3);
  return `0${n.slice(0, 3)} ${n.slice(3, 6)} ${n.slice(6)}`;
}
