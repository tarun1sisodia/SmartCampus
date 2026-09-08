"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { getOrganisations, updateOrganisation } from "@/lib/api/endpoints/org-api";
import { Organisation } from "@/types/organisation";
import { useDebounce } from "@/lib/hooks/useDebounce";
import { useToast } from "@/components/ui/Toast";

export default function OrganisationsPage() {
  const queryClient = useQueryClient();
  const { showToast } = useToast();
  const [search, setSearch] = useState("");
  const [type, setType] = useState<"all" | "school" | "college">("all");
  const debouncedSearch = useDebounce(search, 350);

  const { data, isLoading } = useQuery({
    queryKey: ["organisations", debouncedSearch, type],
    queryFn: () => getOrganisations({ page: 1, limit: 20, search: debouncedSearch, type })
  });

  const statusMutation = useMutation({
    mutationFn: ({ orgId, status }: { orgId: string; status: "active" | "suspended" }) =>
      updateOrganisation(orgId, { status }),
    onSuccess: () => {
      showToast("Organisation status updated", "success");
      queryClient.invalidateQueries({ queryKey: ["organisations"] });
    },
    onError: () => showToast("Failed to update organisation status", "error")
  });

  const items = useMemo(() => data?.items ?? [], [data]);

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold">Organisations</h1>
        <Link href="/organisations/create" className="rounded-md bg-primary px-3 py-2 text-sm text-primary-foreground">
          Create Organisation
        </Link>
      </div>

      <div className="card flex flex-col gap-2 md:flex-row">
        <input
          placeholder="Search organisation name"
          className="w-full rounded border border-input px-3 py-2"
          value={search}
          onChange={event => setSearch(event.target.value)}
        />
        <select
          className="rounded border border-input px-3 py-2"
          value={type}
          onChange={event => setType(event.target.value as "all" | "school" | "college")}
        >
          <option value="all">All Types</option>
          <option value="school">School</option>
          <option value="college">College</option>
        </select>
      </div>

      <div className="card overflow-auto">
        <table className="min-w-full text-sm">
          <thead>
            <tr className="border-b border-border">
              <th className="px-3 py-2 text-left">Name</th>
              <th className="px-3 py-2 text-left">Type</th>
              <th className="px-3 py-2 text-left">Status</th>
              <th className="px-3 py-2 text-left">Plan</th>
              <th className="px-3 py-2 text-left">Actions</th>
            </tr>
          </thead>
          <tbody>
            {isLoading ? (
              <tr>
                <td className="px-3 py-4 text-muted-foreground" colSpan={5}>
                  Loading organisations...
                </td>
              </tr>
            ) : items.length === 0 ? (
              <tr>
                <td className="px-3 py-4 text-muted-foreground" colSpan={5}>
                  No organisations found.
                </td>
              </tr>
            ) : (
              items.map((org: Organisation) => (
                <tr key={org.id} className="border-b border-border">
                  <td className="px-3 py-2">{org.name}</td>
                  <td className="px-3 py-2">{org.type}</td>
                  <td className="px-3 py-2">{org.status}</td>
                  <td className="px-3 py-2">{org.subscriptionPlan}</td>
                  <td className="px-3 py-2">
                    <div className="flex gap-2">
                      <Link href={`/organisations/${org.id}`} className="text-primary underline">
                        Edit
                      </Link>
                      <button
                        className="text-warning underline"
                        onClick={() =>
                          statusMutation.mutate({
                            orgId: org.id,
                            status: org.status === "active" ? "suspended" : "active"
                          })
                        }
                      >
                        {org.status === "active" ? "Suspend" : "Activate"}
                      </button>
                    </div>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
