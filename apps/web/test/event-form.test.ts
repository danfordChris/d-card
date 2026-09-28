import { describe, expect, it } from "vitest";
import {
  EMPTY_EVENT_FORM,
  isoToLocal,
  localToIso,
  toCreatePayload,
  validateStep,
  type EventFormValues,
} from "../src/features/events/event-form";

const filled: EventFormValues = {
  ...EMPTY_EVENT_FORM,
  title: "Harusi ya Juma & Neema",
  startsAt: "2026-12-12T15:00",
  contactName: "Asha",
  contactPhone: "0754 123 456",
  singleAmount: "50,000",
  doubleAmount: "100000",
};

describe("validateStep", () => {
  it("details requires title and start; end must follow start; map link must be a URL", () => {
    expect(validateStep("details", EMPTY_EVENT_FORM)).toEqual({ title: "required", startsAt: "required" });
    expect(validateStep("details", { ...filled, endsAt: "2026-12-12T14:00", venueMapUrl: "maps" })).toEqual({
      endsAt: "endsBeforeStart",
      venueMapUrl: "url",
    });
    expect(validateStep("details", filled)).toEqual({});
  });

  it("contact validates Tanzanian phones", () => {
    expect(validateStep("contact", { ...filled, contactPhone: "12345" })).toEqual({ contactPhone: "phone" });
    expect(validateStep("contact", { ...filled, contact2Phone: "+254700000000" })).toEqual({ contact2Phone: "phone" });
    expect(validateStep("contact", filled)).toEqual({});
  });

  it("options validates numbers and ranges", () => {
    expect(validateStep("options", { ...filled, headcountPct: "150", confirmationOffsetDays: "x", singleAmount: "-5" })).toEqual({
      headcountPct: "range",
      confirmationOffsetDays: "number",
      singleAmount: "number",
    });
    expect(validateStep("options", { ...filled, confirmationEnabled: false, confirmationOffsetDays: "x" })).toEqual({});
  });
});

describe("payload", () => {
  it("builds the API payload with +03:00 times and whole-number amounts", () => {
    expect(toCreatePayload(filled)).toMatchObject({
      planKey: "kawaida",
      eventTypeKey: "wedding",
      startsAt: "2026-12-12T15:00:00+03:00",
      endsAt: null,
      venueName: null,
      contactPhone: "0754 123 456",
      singleAmount: 50000,
      doubleAmount: 100000,
      headcountPct: 70,
    });
  });

  it("round-trips local time", () => {
    expect(localToIso("2026-12-12T15:00")).toBe("2026-12-12T15:00:00+03:00");
    expect(isoToLocal("2026-12-12T12:00:00.000Z")).toBe("2026-12-12T15:00");
  });
});
