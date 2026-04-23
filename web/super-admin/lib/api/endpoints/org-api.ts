import { axiosClient } from "@/lib/api/axios-client";
import {
  Organisation,
  OrganisationListParams,
  OrganisationListResponse,
  OrganisationUpsertPayload
} from "@/types/organisation";

export async function getOrganisations(params: OrganisationListParams): Promise<OrganisationListResponse> {
  const { data } = await axiosClient.get<OrganisationListResponse>("/orgs", { params });
  return data;
}

export async function getOrganisationById(id: string): Promise<Organisation> {
  const { data } = await axiosClient.get<Organisation>(`/orgs/${id}`);
  return data;
}

export async function createOrganisation(payload: OrganisationUpsertPayload): Promise<Organisation> {
  const { data } = await axiosClient.post<Organisation>("/orgs", payload);
  return data;
}

export async function updateOrganisation(
  id: string,
  payload: Partial<OrganisationUpsertPayload> & { status?: "active" | "suspended" }
): Promise<Organisation> {
  const { data } = await axiosClient.patch<Organisation>(`/orgs/${id}`, payload);
  return data;
}
