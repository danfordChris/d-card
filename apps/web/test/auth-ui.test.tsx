// @vitest-environment jsdom
import { cleanup, fireEvent, render, screen } from "@testing-library/react";
import { NextIntlClientProvider } from "next-intl";
import { afterEach, describe, expect, it, vi } from "vitest";
import en from "../messages/en.json";
import sw from "../messages/sw.json";
import { Field, Input } from "../src/components/ui";
import { LoginForm } from "../src/features/auth/login-form";
import { mapFirebaseError, validateEmail, validatePassword } from "../src/features/auth/validation";

vi.mock("next/navigation", () => ({
  useRouter: () => ({ replace: vi.fn(), refresh: vi.fn() }),
  useSearchParams: () => new URLSearchParams(),
}));
vi.mock("firebase/auth", () => ({ signInWithEmailAndPassword: vi.fn() }));
vi.mock("../src/lib/firebase-client", () => ({ firebaseAuth: vi.fn(), startServerSession: vi.fn() }));

afterEach(cleanup);

const renderIn = (locale: "sw" | "en", ui: React.ReactNode) =>
  render(
    <NextIntlClientProvider locale={locale} messages={locale === "sw" ? sw : en}>
      {ui}
    </NextIntlClientProvider>,
  );

describe("validation helpers", () => {
  it("validates email and password", () => {
    expect(validateEmail("")).toBe("required");
    expect(validateEmail("nope")).toBe("email");
    expect(validateEmail("a@b.co")).toBeUndefined();
    expect(validatePassword("short")).toBe("passwordLength");
    expect(validatePassword("long-enough")).toBeUndefined();
    expect(mapFirebaseError("auth/invalid-credential")).toBe("invalidCredentials");
    expect(mapFirebaseError("auth/email-already-in-use")).toBe("emailInUse");
    expect(mapFirebaseError("auth/configuration-not-found")).toBe("authConfig");
    expect(mapFirebaseError("auth/operation-not-allowed")).toBe("authConfig");
    expect(mapFirebaseError("dcard/session")).toBe("serverSession");
    expect(mapFirebaseError("auth/too-many-requests")).toBe("tooManyRequests");
    expect(mapFirebaseError("anything-else")).toBe("generic");
  });
});

describe("Field", () => {
  it("links label, control and error for screen readers", () => {
    render(
      <Field label="Email" error="Required">
        <Input />
      </Field>,
    );
    const input = screen.getByLabelText("Email");
    expect(input.getAttribute("aria-invalid")).toBe("true");
    expect(document.getElementById(input.getAttribute("aria-describedby")!)?.textContent).toBe("Required");
  });
});

describe("LoginForm", () => {
  it("renders in Swahili and shows localised validation errors", () => {
    renderIn("sw", <LoginForm />);
    expect(screen.getByRole("heading", { name: "Ingia D-Card" })).toBeTruthy();
    fireEvent.click(screen.getByRole("button", { name: "Ingia" }));
    expect(screen.getAllByText("Sehemu hii inahitajika.")).toHaveLength(2);
  });

  it("renders in English", () => {
    renderIn("en", <LoginForm />);
    expect(screen.getByRole("heading", { name: "Sign in to D-Card" })).toBeTruthy();
    fireEvent.change(screen.getByLabelText("Email"), { target: { value: "bad" } });
    fireEvent.click(screen.getByRole("button", { name: "Sign in" }));
    expect(screen.getByText("Enter a valid email address.")).toBeTruthy();
  });
});
