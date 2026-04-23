import Link from "next/link";

const links = [
  { href: "/dashboard", label: "Dashboard" },
  { href: "/teachers", label: "Teachers" },
  { href: "/students", label: "Students" },
  { href: "/courses", label: "Courses" },
  { href: "/sessions", label: "Sessions" },
  { href: "/analytics", label: "Analytics" },
  { href: "/settings", label: "Settings" }
];

export function Sidebar() {
  return (
    <aside className="w-64 border-r border-slate-200 bg-white p-4">
      <h2 className="mb-4 text-lg font-semibold text-primary">Org Admin</h2>
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
