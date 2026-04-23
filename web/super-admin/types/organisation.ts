export type OrganisationType = "school" | "college";
export type OrganisationStatus = "active" | "suspended";
export type SubscriptionPlan = "basic" | "premium" | "enterprise";

export type Organisation = {
  id: string;
  name: string;
  type: OrganisationType;
  domain?: string | null;
  contactEmail: string;
  address?: string | null;
  subscriptionPlan: SubscriptionPlan;
  status: OrganisationStatus;
};

export type OrganisationListParams = {
  page?: number;
  limit?: number;
  search?: string;
  type?: OrganisationType | "all";
};

export type OrganisationListResponse = {
  items: Organisation[];
  page: number;
  totalPages: number;
  totalItems: number;
};

export type OrganisationUpsertPayload = {
  name: string;
  type: OrganisationType;
  domain?: string;
  contactEmail: string;
  address?: string;
  subscriptionPlan: SubscriptionPlan;
  status?: OrganisationStatus;
};
