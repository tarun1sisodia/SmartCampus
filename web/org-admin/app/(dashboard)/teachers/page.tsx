"use client";

import { FormEvent, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  deactivateTeacher,
  getTeachers,
  inviteTeacher,
  resendInvite
} from "@/lib/api/endpoints/user-api";
import { useToast } from "@/components/ui/Toast";

export default function TeachersPage() {
  const queryClient = useQueryClient();
  const { showToast } = useToast();
  const [showInviteForm, setShowInviteForm] = useState(false);
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");

  const { data, isLoading } = useQuery({
    queryKey: ["teachers"],
    queryFn: () => getTeachers({ page: 1, limit: 20 })
  });

  const inviteMutation = useMutation({
    mutationFn: inviteTeacher,
    onSuccess: () => {
      showToast("Teacher invited successfully", "success");
      setName("");
      setEmail("");
      setShowInviteForm(false);
      queryClient.invalidateQueries({ queryKey: ["teachers"] });
    },
    onError: () => showToast("Failed to invite teacher", "error")
  });

  const deactivateMutation = useMutation({
    mutationFn: deactivateTeacher,
    onSuccess: () => {
      showToast("Teacher deactivated", "success");
      queryClient.invalidateQueries({ queryKey: ["teachers"] });
    },
    onError: () => showToast("Failed to deactivate teacher", "error")
  });

  const resendInviteMutation = useMutation({
    mutationFn: resendInvite,
    onSuccess: () => showToast("Invite resent", "success"),
    onError: () => showToast("Failed to resend invite", "error")
  });

  const onInviteSubmit = async (event: FormEvent) => {
    event.preventDefault();
    await inviteMutation.mutateAsync({ name, email });
  };

  const teachers = data?.items ?? [];
  const pendingInvites = teachers.filter(teacher => !teacher.isActive);

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold">Teachers</h1>
        <button
          className="rounded bg-primary px-3 py-2 text-sm text-white"
          onClick={() => setShowInviteForm(prev => !prev)}
        >
          Invite Teacher
        </button>
      </div>

      {showInviteForm && (
        <form onSubmit={onInviteSubmit} className="rounded-lg border border-slate-200 bg-white p-4">
          <div className="grid grid-cols-1 gap-2 md:grid-cols-2">
            <input
              className="rounded border border-slate-300 px-3 py-2"
              placeholder="Teacher name"
              value={name}
              onChange={event => setName(event.target.value)}
              required
            />
            <input
              className="rounded border border-slate-300 px-3 py-2"
              placeholder="Teacher email"
              type="email"
              value={email}
              onChange={event => setEmail(event.target.value)}
              required
            />
          </div>
          <div className="mt-3">
            <button
              disabled={inviteMutation.isPending}
              className="rounded bg-secondary px-3 py-2 text-sm text-white disabled:opacity-70"
            >
              {inviteMutation.isPending ? "Sending..." : "Send Invite"}
            </button>
          </div>
        </form>
      )}

      {!!pendingInvites.length && (
        <div className="rounded-lg border border-warning/40 bg-warning/10 p-3 text-sm text-textPrimary">
          Pending invites: {pendingInvites.length}
        </div>
      )}

      <div className="rounded-lg border border-slate-200 bg-white p-4">
        <table className="min-w-full text-sm">
          <thead>
            <tr className="border-b border-slate-200">
              <th className="px-3 py-2 text-left">Name</th>
              <th className="px-3 py-2 text-left">Email</th>
              <th className="px-3 py-2 text-left">Status</th>
              <th className="px-3 py-2 text-left">Last Login</th>
              <th className="px-3 py-2 text-left">Actions</th>
            </tr>
          </thead>
          <tbody>
            {isLoading ? (
              <tr>
                <td className="px-3 py-4 text-textSecondary" colSpan={5}>
                  Loading teachers...
                </td>
              </tr>
            ) : !teachers.length ? (
              <tr>
                <td className="px-3 py-4 text-textSecondary" colSpan={5}>
                  No teachers found.
                </td>
              </tr>
            ) : (
              teachers.map(teacher => (
                <tr key={teacher.id} className="border-b border-slate-100">
                  <td className="px-3 py-2">{teacher.name}</td>
                  <td className="px-3 py-2">{teacher.email}</td>
                  <td className="px-3 py-2">{teacher.isActive ? "Active" : "Invited"}</td>
                  <td className="px-3 py-2">{teacher.lastLogin ?? "-"}</td>
                  <td className="px-3 py-2">
                    <div className="flex gap-2">
                      <button
                        className="text-danger underline"
                        onClick={() => deactivateMutation.mutate(teacher.id)}
                      >
                        Deactivate
                      </button>
                      {!teacher.isActive && (
                        <button
                          className="text-primary underline"
                          onClick={() => resendInviteMutation.mutate(teacher.id)}
                        >
                          Resend Invite
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
