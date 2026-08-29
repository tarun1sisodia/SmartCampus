// =============================================================
// (dashboard)/organisations/page.tsx (super-admin)  ->  ALGORITHM ONLY
// (source: web/super-admin/app/(dashboard)/organisations/page.tsx)
// =============================================================

// useQuery getOrganisations({ page, limit, search: debouncedSearch, type })  // useDebounce on typing
// filter bar: search input + type select (all/school/college)
// table of orgs (name, type, status, plan) ; row action suspend/activate ->
//   updateOrganisation mutation (PATCH /orgs/:id action) -> invalidate + refetch
// 'NEW ORGANISATION' -> /organisations/create
