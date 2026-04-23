import Link from "next/link";

const links = [
  { href: "/dashboard", label: "Dashboard" },
  { href: "/organisations", label: "Organisations" },
  { href: "/users", label: "Users" },
  { href: "/backups", label: "Backups" },
  { href: "/audit-logs", label: "Audit Logs" },
  { href: "/settings", label: "Settings" }
];

export function Sidebar() {
  return (
    <aside className="w-64 border-r border-slate-200 bg-white p-4">
      <h2 className="mb-4 text-lg font-semibold text-primary">SuperAdmin</h2>
      <nav className="space-y-1">
        {links.map(link => (
          <Link
            key={link.href}
            href={link.href}
            className="block rounded px-3 py-2 text-sm text-textSecondary hover:bg-slate-100 hover:text-textPrimary"
          >
            {link.label}
          </Link>
        ))}
      </nav>
    </aside>
  );
}
