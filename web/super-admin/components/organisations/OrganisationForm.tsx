"use client";

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import {
  OrganisationFormValues,
  organisationSchema
} from "@/lib/validations/organisation.schema";

type Props = {
  initialValues?: Partial<OrganisationFormValues>;
  submitLabel: string;
  onSubmit: (values: OrganisationFormValues) => Promise<void>;
};

export function OrganisationForm({ initialValues, submitLabel, onSubmit }: Props) {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting }
  } = useForm<OrganisationFormValues>({
    resolver: zodResolver(organisationSchema),
    defaultValues: {
      name: initialValues?.name ?? "",
      type: initialValues?.type ?? "school",
      domain: initialValues?.domain ?? "",
      contactEmail: initialValues?.contactEmail ?? "",
      address: initialValues?.address ?? "",
      subscriptionPlan: initialValues?.subscriptionPlan ?? "basic",
      status: initialValues?.status ?? "active"
    }
  });

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="card grid grid-cols-1 gap-3 md:grid-cols-2">
      <div className="md:col-span-2">
        <label className="mb-1 block text-sm text-textSecondary">Name</label>
        <input className="w-full rounded border border-slate-300 px-3 py-2" {...register("name")} />
        {errors.name && <p className="mt-1 text-xs text-danger">{errors.name.message}</p>}
      </div>

      <div>
        <label className="mb-1 block text-sm text-textSecondary">Type</label>
        <select className="w-full rounded border border-slate-300 px-3 py-2" {...register("type")}>
          <option value="school">School</option>
          <option value="college">College</option>
        </select>
      </div>

      <div>
        <label className="mb-1 block text-sm text-textSecondary">Subscription Plan</label>
        <select
          className="w-full rounded border border-slate-300 px-3 py-2"
          {...register("subscriptionPlan")}
        >
          <option value="basic">Basic</option>
          <option value="premium">Premium</option>
          <option value="enterprise">Enterprise</option>
        </select>
      </div>

      <div>
        <label className="mb-1 block text-sm text-textSecondary">Contact Email</label>
        <input
          className="w-full rounded border border-slate-300 px-3 py-2"
          type="email"
          {...register("contactEmail")}
        />
        {errors.contactEmail && (
          <p className="mt-1 text-xs text-danger">{errors.contactEmail.message}</p>
        )}
      </div>

      <div>
        <label className="mb-1 block text-sm text-textSecondary">Domain</label>
        <input className="w-full rounded border border-slate-300 px-3 py-2" {...register("domain")} />
      </div>

      <div className="md:col-span-2">
        <label className="mb-1 block text-sm text-textSecondary">Address</label>
        <textarea
          className="w-full rounded border border-slate-300 px-3 py-2"
          rows={3}
          {...register("address")}
        />
      </div>

      <div>
        <label className="mb-1 block text-sm text-textSecondary">Status</label>
        <select className="w-full rounded border border-slate-300 px-3 py-2" {...register("status")}>
          <option value="active">Active</option>
          <option value="suspended">Suspended</option>
        </select>
      </div>

      <div className="flex items-end justify-end md:col-span-1">
        <button
          disabled={isSubmitting}
          className="rounded bg-primary px-4 py-2 text-sm text-white disabled:opacity-70"
        >
          {isSubmitting ? "Saving..." : submitLabel}
        </button>
      </div>
    </form>
  );
}
