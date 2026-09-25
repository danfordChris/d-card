// @vitest-environment jsdom
import { cleanup, render, screen } from "@testing-library/react";
import { NextIntlClientProvider } from "next-intl";
import { afterEach, describe, expect, it } from "vitest";
import en from "../messages/en.json";
import sw from "../messages/sw.json";
import { ImportReportView } from "../src/features/imports/import-report";

afterEach(cleanup);

const report = {
  total: 5,
  valid: 2,
  invalid: [{ row: 3, phone: "123", reason: "invalid_phone" as const }],
  duplicatesInFile: [{ row: 4, phone: "255713000001", firstRow: 2 }],
  existing: [{ row: 5, phone: "255713000099", name: "Existing Guest" }],
};

describe("ImportReportView", () => {
  it("lists counts, problems, duplicates and existing guests (English)", () => {
    render(
      <NextIntlClientProvider locale="en" messages={en}>
        <ImportReportView report={report} />
      </NextIntlClientProvider>,
    );
    expect(screen.getByText("Ready to add: 2")).toBeTruthy();
    expect(screen.getByText("Row 3: 123 — invalid phone number")).toBeTruthy();
    expect(screen.getByText("Row 4: same number as row 2")).toBeTruthy();
    expect(screen.getByText("Row 5: Existing Guest")).toBeTruthy();
  });

  it("renders in Swahili", () => {
    render(
      <NextIntlClientProvider locale="sw" messages={sw}>
        <ImportReportView report={report} />
      </NextIntlClientProvider>,
    );
    expect(screen.getByText("Tayari kuongezwa: 2")).toBeTruthy();
    expect(screen.getByText("Mstari 3: 123 — namba ya simu si sahihi")).toBeTruthy();
  });
});
