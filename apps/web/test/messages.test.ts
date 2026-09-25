import { describe, expect, it } from "vitest";
import en from "../messages/en.json";
import sw from "../messages/sw.json";
import { toLocale } from "../src/i18n/config";

function keys(obj: object, prefix = ""): string[] {
  return Object.entries(obj).flatMap(([k, v]) =>
    v && typeof v === "object" ? keys(v, `${prefix}${k}.`) : [`${prefix}${k}`],
  );
}

describe("messages", () => {
  it("Swahili and English define the same keys", () => {
    expect(keys(sw).sort()).toEqual(keys(en).sort());
  });

  it("locale cookie falls back to Swahili", () => {
    expect(toLocale("en")).toBe("en");
    expect(toLocale("fr")).toBe("sw");
    expect(toLocale(undefined)).toBe("sw");
  });
});
