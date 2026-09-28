import { cn } from "./cn";

/** Segmented tabs on a tile background; the active tab is a primary pill. */
export function Tabs<T extends string>({
  items,
  value,
  onChange,
  label,
}: {
  items: { value: T; label: string }[];
  value: T;
  onChange: (value: T) => void;
  label: string;
}) {
  return (
    <div role="tablist" aria-label={label} className="inline-flex gap-1 rounded-2xl bg-tile p-1">
      {items.map((item) => (
        <button
          key={item.value}
          type="button"
          role="tab"
          aria-selected={item.value === value}
          onClick={() => onChange(item.value)}
          className={cn(
            "h-10 rounded-xl px-4 text-sm font-bold focus-visible:outline-2 focus-visible:outline-primary",
            item.value === value ? "bg-primary text-on-primary" : "text-ink hover:bg-tile2",
          )}
        >
          {item.label}
        </button>
      ))}
    </div>
  );
}
