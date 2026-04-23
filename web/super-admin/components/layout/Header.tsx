"use client";

import { useAuth } from "@/lib/hooks/useAuth";

export function Header() {
  const { user, logout } = useAuth();

  return (
    <header className="flex h-16 items-center justify-between border-b border-slate-200 bg-white px-6">
      <p className="text-sm text-textSecondary">SmartCampus Platform Console</p>
      <div className="flex items-center gap-3">
        <span className="text-sm text-textPrimary">{user?.name ?? "Guest"}</span>
        <button
          onClick={() => logout()}
          className="rounded bg-primary px-3 py-1.5 text-sm font-medium text-white"
        >
          Logout
        </button>
      </div>
    </header>
  );
}
