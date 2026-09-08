export default function SettingsPage() {
  return (
    <div className="space-y-4">
      <h1 className="text-2xl font-semibold">System Settings</h1>
      <div className="card">
        <p className="text-sm text-muted-foreground">
          Feature flags and global limits form placeholder mapped to `PATCH /settings`.
        </p>
      </div>
    </div>
  );
}
