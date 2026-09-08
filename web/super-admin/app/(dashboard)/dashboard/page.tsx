const kpis = [
  { label: "Organisations", value: "128" },
  { label: "Users", value: "1,924" },
  { label: "Students", value: "59,312" },
  { label: "Avg Attendance", value: "81.3%" }
];

export default function SuperAdminDashboardPage() {
  return (
    <div className="space-y-4">
      <h1 className="text-2xl font-semibold">Dashboard</h1>
      <div className="grid grid-cols-1 gap-3 md:grid-cols-2 lg:grid-cols-4">
        {kpis.map(kpi => (
          <div className="card" key={kpi.label}>
            <p className="text-sm text-muted-foreground">{kpi.label}</p>
            <p className="text-2xl font-bold">{kpi.value}</p>
          </div>
        ))}
      </div>
      <div className="card">
        <p className="font-semibold">Attendance Trend (Last 6 Months)</p>
        <p className="mt-2 text-sm text-muted-foreground">
          Chart integration placeholder (Recharts) ready for API wiring with React Query.
        </p>
      </div>
    </div>
  );
}
