# SmartCampus Web Portals

This directory contains the two admin web applications:

- `super-admin` (planned port `3000`)
- `org-admin` (planned port `3001`)

## Current State

Initial folder scaffolding has been created based on:

- `SMARTCAMPUS_ADMIN_WEB_PORTALS_IMPLEMENTATION_GUIDE.md`

## Suggested Implementation Order

1. Bootstrap both apps with Next.js + TypeScript + Tailwind.
2. Set up shared architecture in each app:
   - API client
   - auth store
   - layout shell
   - UI primitives (DataTable, Modal, Toast)
3. Implement authentication flow and route guards.
4. Build dashboard pages and primary CRUD flows.
5. Add analytics/charts, exports, and smoke tests.
