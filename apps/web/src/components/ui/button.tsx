import type { ButtonHTMLAttributes } from "react";
import { cn } from "./cn";

type Variant = "primary" | "tonal" | "secondary" | "danger" | "ghost";

const VARIANTS: Record<Variant, string> = {
  primary: "bg-primary text-on-primary hover:bg-primary-strong disabled:opacity-50",
  tonal: "bg-tile text-ink hover:bg-tile2 disabled:opacity-50",
  /** Former name of `tonal`. */
  secondary: "bg-tile text-ink hover:bg-tile2 disabled:opacity-50",
  danger: "bg-danger-bg text-danger hover:brightness-95 disabled:opacity-50",
  ghost: "text-primary hover:bg-tile",
};

/** Button look for links (`<Link className={buttonClasses("tonal")}>`). */
export function buttonClasses(variant: Variant = "primary", size: "md" | "lg" = "md", className?: string): string {
  return cn(
    "inline-flex min-h-11 items-center justify-center gap-2 rounded-button px-5 font-bold transition-colors",
    size === "lg" ? "h-14 text-base" : "h-11 text-sm",
    "focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary",
    "disabled:cursor-not-allowed",
    VARIANTS[variant],
    className,
  );
}

export function Button({
  variant = "primary",
  size = "md",
  className,
  type = "button",
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & { variant?: Variant; size?: "md" | "lg" }) {
  return (
    <button
      type={type}
      className={buttonClasses(variant, size, className)}
      {...props}
    />
  );
}
