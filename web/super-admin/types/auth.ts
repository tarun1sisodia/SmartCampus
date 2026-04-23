export type AuthUser = {
  id: string;
  name: string;
  email: string;
  role: "super_admin" | "org_admin";
};

export type AuthTokens = {
  accessToken: string;
  refreshToken: string;
};

export type LoginRequest = {
  email: string;
  password: string;
};

export type LoginResponse = AuthTokens & {
  user: AuthUser;
};
