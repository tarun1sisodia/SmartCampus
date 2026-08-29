// =============================================================
// org-api.ts (super-admin)  ->  ALGORITHM ONLY (source: web/super-admin/lib/api/endpoints/org-api.ts)
// =============================================================

// mapOrganisation(backend org) -> UI shape (rename fields, default status/plan)
// getOrganisations({ page, limit, search?, type? }) -> GET /orgs with query -> { data, total, page, limit }
// getOrganisationById(id) -> GET /orgs/:id
// createOrganisation(payload) -> POST /orgs
// updateOrganisation(id, payload { action: suspend|activate | ...fields }) -> PATCH /orgs/:id
