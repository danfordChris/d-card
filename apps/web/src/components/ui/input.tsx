import type { InputHTMLAttributes } from "react";
import { cn } from "./cn";

/** Filled input: tile background, no outline until focus. */
export function Input({ className, ...props }: InputHTMLAttributes<HTMLInputElement>) {
  return (
    <input
      className={cn(
        "block h-12 w-full rounded-field border-0 bg-field px-4 text-[15px] text-ink",
        "placeholder:text-muted focus:ring-2 focus:ring-primary focus:outline-none",
        "aria-[invalid=true]:ring-2 aria-[invalid=true]:ring-danger",
        className,
      )}
      {...props}
    />
  );
}
