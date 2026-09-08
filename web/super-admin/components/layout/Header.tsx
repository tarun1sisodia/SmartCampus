"use client";

import { useAuth } from "@/lib/hooks/useAuth";
import { ThemeToggle } from "@/components/ui/ThemeToggle";

export function Header() {
  const { user, logout } = useAuth();

  return (
    <header className="flex h-16 items-center justify-between border-b border-border bg-card px-6">
      <p className="text-sm text-muted-foreground">SmartCampus Platform Console</p>
      <div className="flex items-center gap-3">
        <span className="text-sm text-foreground">{user?.name ?? "Guest"}</span>
        <ThemeToggle />
        <button
          onClick={() => logout()}
          className="rounded-md bg-primary px-3 py-1.5 text-sm font-medium text-primary-foreground"
        >
          Logout
        </button>
      </div>
    </header>
  );
}
