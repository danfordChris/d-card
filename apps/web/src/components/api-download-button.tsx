"use client";

import { useState, type CSSProperties, type ReactNode } from "react";
import { downloadFromApi } from "../lib/api-fetch";

/** A download "link" for API files: fetched with the X-API-Key header, then saved. */
export function ApiDownloadButton({
  url,
  fileName,
  className,
  style,
  children,
}: {
  url: string;
  fileName: string;
  className?: string;
  style?: CSSProperties;
  children: ReactNode;
}) {
  const [busy, setBusy] = useState(false);
  return (
    <button
      type="button"
      className={className}
      style={style}
      disabled={busy}
      onClick={async () => {
        setBusy(true);
        await downloadFromApi(url, fileName);
        setBusy(false);
      }}
    >
      {children}
    </button>
  );
}
