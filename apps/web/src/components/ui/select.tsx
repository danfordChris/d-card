import type { SelectHTMLAttributes, TextareaHTMLAttributes } from "react";
import { cn } from "./cn";

const FILLED = "block w-full rounded-field border-0 bg-field px-4 text-[15px] text-ink focus:ring-2 focus:ring-primary focus:outline-none aria-[invalid=true]:ring-2 aria-[invalid=true]:ring-danger disabled:opacity-60";

/** Filled select matching `Input`. */
export function Select({ className, ...props }: SelectHTMLAttributes<HTMLSelectElement>) {
  return <select className={cn(FILLED, "h-12 pr-10", className)} {...props} />;
}

/** Filled textarea matching `Input`. */
export function Textarea({ className, ...props }: TextareaHTMLAttributes<HTMLTextAreaElement>) {
  return <textarea className={cn(FILLED, "py-3 placeholder:text-muted", className)} {...props} />;
}
