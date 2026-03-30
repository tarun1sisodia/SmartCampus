# SmartCampus Production & Reliability Guide

This guide outlines strategies to ensure **100% uptime** and rapid recovery during production incidents, such as service outages or data corruption.

## 1. Hotpatching with Shorebird

Shorebird allows you to push UI and logic fixes directly to users without waiting for App Store or Play Store reviews.

### When to use:
- Critical UI bugs.
- Rapidly changing business logic.
- Emergency security patches.

### Commands:
```bash
# Push a hotfix to all users
shorebird patch android
```

---

## 2. Service Redundancy (The "Alternate Version" Strategy)

If Supabase or a critical dependency goes down, you must be able to switch the app's data source or UI state immediately.

### Strategy: Git Branch Switching
Maintain an `emergency-offline` or `secondary-backend` branch.
1. **Branch A (Main)**: Uses Supabase.
2. **Branch B (Fallback)**: Configured to use a secondary REST API or a Read-Only local mode.

### Implementation:
If a primary service fails:
1. Merge the `Fallback` configuration into `Main`.
2. Push a **Shorebird Patch**.
3. All users will be redirected to the secondary infrastructure within minutes.

---

## 3. Handling Data Corruption

If a package or database migration corrupts data:
- **Local Wipe**: Use the `LocalDbService` to force a cache clear.
- **Remote Rollback**: Use Supabase's point-in-time recovery.

## 4. Scaling for Thousands of Users

- **Horizontal Scaling**: Supabase handles this automatically via PostgreSQL replication.
- **Edge Caching**: Use Supabase Edge Functions to pre-calculate reporting statistics.
- **CDN**: Ensure all student images are served via a globally distributed CDN (already configured via Supabase Storage).
