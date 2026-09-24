import type { Metadata } from "next";
import type { ReactNode } from "react";

export const metadata: Metadata = {
  title: "D-Card",
  description: "Kadi za mwaliko za kidigitali · Digital event invitation cards",
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="sw">
      <body>{children}</body>
    </html>
  );
}
