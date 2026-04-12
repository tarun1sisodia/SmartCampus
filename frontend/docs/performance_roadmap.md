# SmartCampus Performance & Scalability Roadmap

This document outlines the systematic, phase-by-phase transformation of SmartCampus into a proactive, high-performance system. The goal is to minimize network dependency, ensure "instant-load" UI, and optimize both client-side and backend scalability.

---

## Phase 1: Background Infrastructure (Foundation)
**Objective**: Establish a reliable, battery-efficient background task framework that respects user data plans.

### Features
- **Centralized Job Dispatching**: Use `workmanager` to schedule tasks outside the app's lifecycle.
- **Network-Aware Scheduling**: Implement "WiFi-only" prefetching to maximize data throughput without impacting user data plans.
- **Battery-Aware Logic**: Ensure prefetching only occurs when the battery is not low.
- **Verification Framework**: A dedicated logging channel to track background task success/failure.

### Implementation Tasks
1.  **Add `workmanager`** dependency to `pubspec.yaml`.
2.  **Configure Android Manifest** for background permissions (Wake Lock, Boot Completed).
3.  **Configure iOS Info.plist** for Background Fetch and Processing.
4.  **Create `TaskHelper`** to initialize `Workmanager` and define the callback dispatcher.

---

## Phase 2: Proactive Data Prefetching (User Value)
**Objective**: Fetch and store the data a user is most likely to need *before* they ask for it.

### Features
- **High-Priority Entity Prefetching**: Automatically fetch "Active Classes" and "Upcoming Sessions" for Teachers.
- **Silent Background Sync**: The app remains silent until data is ready in local persistence.
- **Local Persistence Layer (Hive)**: Transition from simple storage to a structured, queryable local cache using Hive.

### Implementation Tasks
1.  **Create `PrefetchService`** to define "what" and "when" to fetch.
2.  **Link `PrefetchService`** to existing `OfflineService` methods.
3.  **Implement WiFi-only check** using `ConnectivityPlus`.

---

## Phase 3: Resilience & Global Consistency (Scale)
**Objective**: Implement the **Stale-While-Revalidate (SWR)** pattern to ensure the UI is never blocked by the network.

### Features
- **SWR Data Access**: `OfflineService` returns local data *immediately* and triggers a background refetch to update the cache.
- **Silent UI Updates**: Use GetX or Stream-based controllers to refresh the UI only when the "revalidated" data differs from the "stale" data.
- **Conflict Management**: Gracefully handle scenarios where local edits conflict with remote changes during background sync.

### Implementation Tasks
1.  **Refactor `OfflineService.getTeacherClasses()`** to return cache first and sync silently.
2.  **Add versioning/timestamps** to local data to track "staleness".

---

## Phase 4: Backend Performance (Database Optimization)
**Objective**: Optimize the Supabase (PostgreSQL) layer to handle a growing user base and high-frequency queries.

### Features
- **Composite Indexing**: Create specialized indices for frequently queried combinations (e.g., `(teacher_id, is_active)`).
- **Edge Functions for Batching**: Move complex data aggregation from the mobile client to Supabase Edge Functions to reduce payload size.
- **Query Optimization**: Audit all high-frequency queries for performance bottlenecks.

### Database Changes (Supabase SQL)
```sql
-- Example index for teacher class lookups
CREATE INDEX IF NOT EXISTS idx_classes_teacher_active 
ON public.classes (teacher_id, status) 
WHERE status = 'active';
```

---

## Phase 5: Observability & Health (Analytics)
**Objective**: Measure effectiveness and ensure the system doesn't negatively impact device health.

### Features
- **Telemetry**: Track "Cache Hit Ratio" vs "Network Fetch Count" via Sentry.
- **Error Tracking**: Monitor prefetch failures specifically to identify region-specific network issues.
- **Health Metrics**: track average time of background execution to prevent "long-running task" kills by OS.

---

## Verification & Deployment Plan (Incremental)
1. **Verification**: After each phase, we will perform a "Manual Verification" test (Backgrounding the app, waiting, and checking logs).
2. **Review**: The user (you) reviews the logs/behavior before we proceed to more complex logic.
3. **Enhance**: Based on verification, we tune the frequency and volume of data fetched.

---

## User Input Required
- **High-Value Data**: Which data (Classes, Students, Attendance Stats) should we prioritize for prefetching?
- **Battery Sensitivity**: Should we restrict prefetching ONLY when the phone is charging, or is "Battery Not Low" enough?
