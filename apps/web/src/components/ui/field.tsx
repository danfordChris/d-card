import { cloneElement, isValidElement, useId, type ReactElement, type ReactNode } from "react";

/** Label + control + error/help text, wired with ids for screen readers. */
export function Field({
  label,
  error,
  hint,
  children,
}: {
  label: string;
  error?: string | undefined;
  hint?: string | undefined;
  children: ReactElement<Record<string, unknown>>;
}) {
  const id = useId();
  const messageId = `${id}-msg`;
  const control = isValidElement(children)
    ? cloneElement(children, {
        id,
        "aria-invalid": error ? true : undefined,
        "aria-describedby": error || hint ? messageId : undefined,
      })
    : children;
  let message: ReactNode = null;
  if (error) {
    message = (
      <p id={messageId} role="alert" className="mt-1 text-sm text-danger">
        {error}
      </p>
    );
  } else if (hint) {
    message = (
      <p id={messageId} className="mt-1 text-sm text-muted">
        {hint}
      </p>
    );
  }
  return (
    <div>
      <label htmlFor={id} className="mb-1.5 block text-sm font-semibold text-ink">
        {label}
      </label>
      {control}
      {message}
    </div>
  );
}
