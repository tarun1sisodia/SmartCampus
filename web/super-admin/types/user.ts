export type UserRole = "super_admin" | "org_admin";

export type UserStatus = "active" | "inactive";

export type AdminUser = {
  id: string;
  name: string;
  email: string;
  role: UserRole;
  organisationName?: string | null;
  status: UserStatus;
  lastLogin?: string | null;
};

export type UserListParams = {
  page?: number;
  limit?: number;
  role?: UserRole | "all";
};

export type UserListResponse = {
  items: AdminUser[];
  page: number;
  totalPages: number;
  totalItems: number;
};
