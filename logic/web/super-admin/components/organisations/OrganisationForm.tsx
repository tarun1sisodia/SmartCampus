// =============================================================
// OrganisationForm.tsx (super-admin)  ->  ALGORITHM ONLY
// (source: web/super-admin/components/organisations/OrganisationForm.tsx)
// =============================================================

// react-hook-form + zodResolver(organisationSchema):
//   fields name/type/domain/contactEmail/address/plan (+ status when editing)
//   submit -> onSubmit callback (create or update) ; invalid -> inline field errors
//   used by both the create page and the [id] edit page
