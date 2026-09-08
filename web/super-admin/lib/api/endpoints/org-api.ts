import { axiosClient } from "@/lib/api/axios-client";
import {
  Organisation,
  OrganisationListParams,
  OrganisationListResponse,
  OrganisationUpsertPayload
} from "@/types/organisation";

type ApiEnvelope<T> = { success: boolean; data: T };
type BackendList<T> = { data: T[]; total: number; page: number; limit: number };

function unwrap<T>(payload: ApiEnvelope<T> | T): T {
  const data = (payload as ApiEnvelope<T>).data;
  return data !== undefined ? data : (payload as T);
}

function toOrganisation(raw: Record<string, unknown>): Organisation {
  return {
    id: (raw.id ?? raw._id ?? "").toString(),
    name: (raw.name ?? "").toString(),
    type: (raw.type as Organisation["type"]) ?? "school",
    domain: raw.domain ? raw.domain.toString() : null,
    contactEmail: (raw.contactEmail ?? "").toString(),
    address: raw.address ? raw.address.toString() : null,
    subscriptionPlan:
      ((raw.subscriptionPlan as string) ??
        (raw.subscription as Record<string, unknown>)?.plan as string ??
        "basic") as Organisation["subscriptionPlan"],
    status: (raw.status as Organisation["status"]) ?? "active"
  };
}

function toOrganisationListResponse(response: BackendList<Organisation>): OrganisationListResponse {
  return {
    items: response.data.map(item => toOrganisation(item as Record<string, unknown>)),
    page: response.page,
    totalPages: Math.ceil(response.total / response.limit),
    totalItems: response.total
  };
}

export async function getOrganisations(params: OrganisationListParams): Promise<OrganisationListResponse> {
  const { data } = await axiosClient.get<ApiEnvelope<BackendList<Organisation>>>("/orgs", { params });
  return toOrganisationListResponse(unwrap(data));
}

export async function getOrganisationById(id: string): Promise<Organisation> {
  const { data } = await axiosClient.get<ApiEnvelope<Organisation>>(`/orgs/${id}`);
  return toOrganisation(unwrap(data) as Record<string, unknown>);
}

export async function createOrganisation(payload: OrganisationUpsertPayload): Promise<Organisation> {
  const { data } = await axiosClient.post<ApiEnvelope<Organisation>>("/orgs", payload);
  return toOrganisation(unwrap(data) as Record<string, unknown>);
}

export async function updateOrganisation(
  id: string,
  payload: Partial<OrganisationUpsertPayload> & { status?: "active" | "suspended" }
): Promise<Organisation> {
  const { data } = await axiosClient.patch<ApiEnvelope<Organisation>>(`/orgs/${id}`, payload);
  return toOrganisation(unwrap(data) as Record<string, unknown>);
}
