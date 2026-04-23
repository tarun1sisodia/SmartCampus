import type { Metadata } from "next";
import "./globals.css";
import { AppProviders } from "@/lib/providers/AppProviders";

export const metadata: Metadata = {
  title: "SmartCampus Super Admin",
  description: "Platform administration portal"
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <AppProviders>{children}</AppProviders>
      </body>
    </html>
  );
}
