import { describe, expect, it } from "vitest";
import { formatLocalPhone, InvalidPhoneError, isValidPhone, normalisePhone } from "../src/index.js";

describe("normalisePhone", () => {
  it.each(["0754123456", "+255754123456", "754123456", "255754123456", "0754 123 456", "+255 754-123-456"])(
    "normalises %s to 255754123456",
    (input) => {
      expect(normalisePhone(input)).toBe("255754123456");
    },
  );

  it.each(["12345", "2557541234567", "", "07541234ab", "+0754123456", "+754123456", "07541234567"])(
    "rejects %j",
    (input) => {
      expect(() => normalisePhone(input)).toThrow(InvalidPhoneError);
      expect(isValidPhone(input)).toBe(false);
    },
  );
});

describe("formatLocalPhone", () => {
  it("formats a stored phone for SMS display", () => {
    expect(formatLocalPhone("255754123456")).toBe("0754 123 456");
  });
});
