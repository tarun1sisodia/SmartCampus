import { axiosClient } from "@/lib/api/axios-client";
import {
  Organisation,
  OrganisationListParams,
  OrganisationListResponse,
  OrganisationUpsertPayload
} from "@/types/organisation";

type BackendOrganisation = {
  _id: string;
  name: string;
  type: "school" | "college";
  domain?: string | null;
  contactEmail?: string | null;
  address?: string | null;
  subscription?: { plan?: "free" | "premium" | "enterprise" } | null;
  status: "active" | "suspended" | "trial";
};

type BackendListEnvelope = {
  success: boolean;
  data: { data: BackendOrganisation[]; total: number; page: number; limit: number };
};

const mapOrganisation = (org: BackendOrganisation): Organisation => ({
  id: org._id,
  name: org.name,
  type: org.type,
  domain: org.domain ?? null,
  contactEmail: org.contactEmail ?? "",
  address: org.address ?? null,
  subscriptionPlan:
    org.subscription?.plan === "premium" || org.subscription?.plan === "enterprise"
      ? org.subscription.plan
      : "basic",
  status: org.status === "suspended" ? "suspended" : "active"
});

export async function getOrganisations(params: OrganisationListParams): Promise<OrganisationListResponse> {
  const query: Record<string, unknown> = { page: params.page, limit: params.limit };
  if (params.type && params.type !== "all") query.type = params.type;

  const { data } = await axiosClient.get<BackendListEnvelope>("/orgs", { params: query });
  const page = data.data.page ?? 1;
  const limit = data.data.limit ?? 10;
  const total = data.data.total ?? 0;
  return {
    items: (data.data.data ?? []).map(mapOrganisation),
    page,
    totalPages: limit > 0 ? Math.ceil(total / limit) : 1,
    totalItems: total
  };
}

export async function getOrganisationById(id: string): Promise<Organisation> {
  const { data } = await axiosClient.get<{ success: boolean; data: BackendOrganisation }>(`/orgs/${id}`);
  return mapOrganisation(data.data);
}

export async function createOrganisation(payload: OrganisationUpsertPayload): Promise<Organisation> {
  const { data } = await axiosClient.post<{ success: boolean; data: BackendOrganisation }>("/orgs", payload);
  return mapOrganisation(data.data);
}

export async function updateOrganisation(
  id: string,
  payload: Partial<OrganisationUpsertPayload> & { status?: "active" | "suspended" }
): Promise<Organisation> {
  const { data } = await axiosClient.patch<{ success: boolean; data: BackendOrganisation }>(`/orgs/${id}`, payload);
  return mapOrganisation(data.data);
}
