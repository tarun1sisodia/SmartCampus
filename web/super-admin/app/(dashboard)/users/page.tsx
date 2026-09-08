"use client";

import { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useToast } from "@/components/ui/Toast";
import {
  deactivateUser,
  getUsers,
  promoteToSuperAdmin,
  resetPassword
} from "@/lib/api/endpoints/user-api";
import { UserRole } from "@/types/user";

export default function UsersPage() {
  const queryClient = useQueryClient();
  const { showToast } = useToast();
  const [role, setRole] = useState<UserRole | "all">("all");

  const { data, isLoading } = useQuery({
    queryKey: ["users", role],
    queryFn: () => getUsers({ page: 1, limit: 20, role })
  });

  const resetMutation = useMutation({
    mutationFn: resetPassword,
    onSuccess: () => showToast("Password reset email sent", "success"),
    onError: () => showToast("Failed to send reset password email", "error")
  });

  const deactivateMutation = useMutation({
    mutationFn: deactivateUser,
    onSuccess: () => {
      showToast("User deactivated", "success");
      queryClient.invalidateQueries({ queryKey: ["users"] });
    },
    onError: () => showToast("Failed to deactivate user", "error")
  });

  const promoteMutation = useMutation({
    mutationFn: promoteToSuperAdmin,
    onSuccess: () => {
      showToast("User promoted to super admin", "success");
      queryClient.invalidateQueries({ queryKey: ["users"] });
    },
    onError: () => showToast("Failed to promote user", "error")
  });

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold">Users</h1>
        <select
          className="rounded border border-input px-3 py-2 text-sm"
          value={role}
          onChange={event => setRole(event.target.value as UserRole | "all")}
        >
          <option value="all">All Roles</option>
          <option value="super_admin">Super Admin</option>
          <option value="org_admin">Org Admin</option>
        </select>
      </div>

      <div className="card overflow-auto">
        <table className="min-w-full text-sm">
          <thead>
            <tr className="border-b border-border">
              <th className="px-3 py-2 text-left">Name</th>
              <th className="px-3 py-2 text-left">Email</th>
              <th className="px-3 py-2 text-left">Role</th>
              <th className="px-3 py-2 text-left">Organisation</th>
              <th className="px-3 py-2 text-left">Status</th>
              <th className="px-3 py-2 text-left">Last Login</th>
              <th className="px-3 py-2 text-left">Actions</th>
            </tr>
          </thead>
          <tbody>
            {isLoading ? (
              <tr>
                <td className="px-3 py-4 text-muted-foreground" colSpan={7}>
                  Loading users...
                </td>
              </tr>
            ) : !data?.items?.length ? (
              <tr>
                <td className="px-3 py-4 text-muted-foreground" colSpan={7}>
                  No users found.
                </td>
              </tr>
            ) : (
              data.items.map(user => (
                <tr key={user.id} className="border-b border-border">
                  <td className="px-3 py-2">{user.name}</td>
                  <td className="px-3 py-2">{user.email}</td>
                  <td className="px-3 py-2">{user.role}</td>
                  <td className="px-3 py-2">{user.organisationName ?? "-"}</td>
                  <td className="px-3 py-2">{user.status}</td>
                  <td className="px-3 py-2">{user.lastLogin ?? "-"}</td>
                  <td className="px-3 py-2">
                    <div className="flex flex-wrap gap-2">
                      <button
                        className="text-primary underline"
                        onClick={() => resetMutation.mutate(user.id)}
                      >
                        Reset Password
                      </button>
                      <button
                        className="text-danger underline"
                        onClick={() => {
                          if (window.confirm("Deactivate this user?")) {
                            deactivateMutation.mutate(user.id);
                          }
                        }}
                      >
                        Deactivate
                      </button>
                      {user.role === "org_admin" && (
                        <button
                          className="text-success underline"
                          onClick={() => promoteMutation.mutate(user.id)}
                        >
                          Promote
                        </button>
                      )}
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
