import type { InputHTMLAttributes } from "react";
import { cn } from "./cn";

export function Input({ className, ...props }: InputHTMLAttributes<HTMLInputElement>) {
  return (
    <input
      className={cn(
        "block w-full rounded-lg border-0 bg-white px-3 py-2 text-sm text-gray-900 ring-1 ring-gray-300",
        "placeholder:text-gray-400 focus:ring-2 focus:ring-brand-600 focus:outline-none",
        "aria-[invalid=true]:ring-red-500",
        className,
      )}
      {...props}
    />
  );
}
