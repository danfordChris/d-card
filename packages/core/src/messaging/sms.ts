// SMS length and character checks (docs/design/features/notifications.md MSG-4).
// GSM 03.38 basic set + extension table; anything else forces UCS-2 (70 chars/segment).

const GSM_BASIC =
  "@£$¥èéùìòÇ\nØø\rÅåΔ_ΦΓΛΩΠΨΣΘΞÆæßÉ !\"#¤%&'()*+,-./0123456789:;<=>?¡ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÑÜ§¿abcdefghijklmnopqrstuvwxyzäöñüà";
const GSM_EXTENDED = "^{}\\[~]|€\f";
const basic = new Set([...GSM_BASIC]);
const extended = new Set([...GSM_EXTENDED]);

/** Characters that break GSM-7 encoding (emoji, curly quotes…), unique, in order of appearance. */
export function gsmProblems(text: string): string[] {
  const bad: string[] = [];
  for (const ch of text) {
    if (!basic.has(ch) && !extended.has(ch) && !bad.includes(ch)) bad.push(ch);
  }
  return bad;
}

export type SmsLength = { encoding: "gsm7" | "ucs2"; units: number; segments: number; perSegment: number };

/** GSM-7: 160 per single SMS, 153 per part; extended characters count double. UCS-2: 70 / 67. */
export function smsLength(text: string): SmsLength {
  if (gsmProblems(text).length === 0) {
    let units = 0;
    for (const ch of text) units += extended.has(ch) ? 2 : 1;
    const segments = units <= 160 ? 1 : Math.ceil(units / 153);
    return { encoding: "gsm7", units, segments: Math.max(segments, 1), perSegment: units <= 160 ? 160 : 153 };
  }
  const units = [...text].reduce((n, ch) => n + (ch.codePointAt(0)! > 0xffff ? 2 : 1), 0);
  const segments = units <= 70 ? 1 : Math.ceil(units / 67);
  return { encoding: "ucs2", units, segments: Math.max(segments, 1), perSegment: units <= 70 ? 70 : 67 };
}

/** Public naming used by the message editor and API contract. */
export const smsSegments = smsLength;
