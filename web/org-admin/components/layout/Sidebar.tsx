import Link from "next/link";
import { ThemeToggle } from "@/components/ui/ThemeToggle";

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
    <aside className="w-64 border-r border-border bg-card p-4">
      <div className="mb-4 flex items-center justify-between">
        <h2 className="text-lg font-semibold text-primary">Org Admin</h2>
        <ThemeToggle />
      </div>
      <nav className="space-y-1">
        {links.map(link => (
          <Link
            key={link.href}
            href={link.href}
            className="block rounded-md px-3 py-2 text-sm text-muted-foreground transition-colors hover:bg-accent hover:text-accent-foreground"
          >
            {link.label}
          </Link>
        ))}
      </nav>
    </aside>
  );
}
