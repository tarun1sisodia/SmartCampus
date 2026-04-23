"use client";

import { useRouter } from "next/navigation";
import { useMutation } from "@tanstack/react-query";
import { createOrganisation } from "@/lib/api/endpoints/org-api";
import { OrganisationForm } from "@/components/organisations/OrganisationForm";
import { OrganisationFormValues } from "@/lib/validations/organisation.schema";
import { useToast } from "@/components/ui/Toast";

export default function CreateOrganisationPage() {
  const router = useRouter();
  const { showToast } = useToast();
  const mutation = useMutation({
    mutationFn: createOrganisation,
    onSuccess: () => {
      showToast("Organisation created successfully", "success");
      router.push("/organisations");
    },
    onError: () => showToast("Failed to create organisation", "error")
  });

  const handleSubmit = async (values: OrganisationFormValues) => {
    await mutation.mutateAsync(values);
  };

  return (
    <div className="space-y-4">
      <h1 className="text-2xl font-semibold">Create Organisation</h1>
      <OrganisationForm submitLabel="Create Organisation" onSubmit={handleSubmit} />
    </div>
  );
}
