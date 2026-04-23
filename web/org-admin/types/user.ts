export type Teacher = {
  id: string;
  name: string;
  email: string;
  isActive: boolean;
  lastLogin?: string | null;
};

export type TeachersResponse = {
  items: Teacher[];
  page: number;
  totalPages: number;
  totalItems: number;
};

export type InviteTeacherPayload = {
  name: string;
  email: string;
};
