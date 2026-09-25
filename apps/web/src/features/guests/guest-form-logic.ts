import { isValidPhone } from "@dcard/core/phone";

export type GuestFormValues = {
  name: string;
  phone: string;
  cardType: "single" | "double";
  partnerName: string;
  consent: boolean;
};

export type GuestFormErrors = Partial<Record<"name" | "phone" | "consent", "required" | "phone" | "consent">>;

export const EMPTY_GUEST: GuestFormValues = { name: "", phone: "", cardType: "single", partnerName: "", consent: false };

export function validateGuest(values: GuestFormValues, mode: "add" | "edit"): GuestFormErrors {
  const errors: GuestFormErrors = {};
  if (!values.name.trim()) errors.name = "required";
  if (mode === "add") {
    if (!values.phone.trim()) errors.phone = "required";
    else if (!isValidPhone(values.phone)) errors.phone = "phone";
    if (!values.consent) errors.consent = "consent";
  }
  return errors;
}

export function toGuestPayload(values: GuestFormValues) {
  return {
    name: values.name.trim(),
    cardType: values.cardType,
    partnerName: values.cardType === "double" && values.partnerName.trim() ? values.partnerName.trim() : null,
  };
}
