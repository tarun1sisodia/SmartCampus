"use client";

import { useMutation, useQuery } from "@tanstack/react-query";
import { useParams } from "next/navigation";
import { getOrganisationById, updateOrganisation } from "@/lib/api/endpoints/org-api";
import { OrganisationForm } from "@/components/organisations/OrganisationForm";
import { OrganisationFormValues } from "@/lib/validations/organisation.schema";
import { useToast } from "@/components/ui/Toast";

export default function OrganisationDetailPage() {
  const params = useParams<{ id: string }>();
  const organisationId = params.id;
  const { showToast } = useToast();
  const { data, isLoading, refetch } = useQuery({
    queryKey: ["organisation", organisationId],
    queryFn: () => getOrganisationById(organisationId),
    enabled: Boolean(organisationId)
  });

  const mutation = useMutation({
    mutationFn: (payload: OrganisationFormValues) => updateOrganisation(organisationId, payload),
    onSuccess: async () => {
      showToast("Organisation updated", "success");
      await refetch();
    },
    onError: () => showToast("Failed to update organisation", "error")
  });

  const handleSubmit = async (values: OrganisationFormValues) => {
    await mutation.mutateAsync(values);
  };

  return (
    <div className="space-y-4">
      <h1 className="text-2xl font-semibold">Organisation Detail</h1>
      {isLoading || !data ? (
        <div className="card text-sm text-muted-foreground">Loading organisation details...</div>
      ) : (
        <OrganisationForm
          submitLabel="Save Changes"
          initialValues={{
            name: data.name,
            type: data.type,
            domain: data.domain ?? "",
            contactEmail: data.contactEmail,
            address: data.address ?? "",
            subscriptionPlan: data.subscriptionPlan,
            status: data.status
          }}
          onSubmit={handleSubmit}
        />
      )}
    </div>
  );
}
