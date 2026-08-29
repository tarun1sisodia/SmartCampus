// =============================================================
// (dashboard)/teachers/page.tsx (org-admin)  ->  ALGORITHM ONLY
// (source: web/org-admin/app/(dashboard)/teachers/page.tsx)
// =============================================================

// react-query useQuery getTeachers({page,limit}) -> table of name/email/status
// 'INVITE TEACHER' toggles an inline form (name+email):
//   submit -> inviteTeacher mutation (POST /users/invite role=teacher) -> toast + invalidate list
// row actions:
//   DEACTIVATE -> deactivateTeacher (DELETE /users/:id) with confirm + invalidate
//   RESEND     -> resendInvite (POST /users/:id/resend-invite) for pending users
