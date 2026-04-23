"use client";

import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { useRouter } from "next/navigation";
import { useDispatch } from "react-redux";
import { AppDispatch } from "@/lib/store/store";
import { login } from "@/lib/store/slices/authSlice";
import { setAccessTokenCookie } from "@/lib/utils/authCookies";

const loginSchema = z.object({
  email: z.string().trim().email("Enter a valid email"),
  password: z.string().min(6, "Password must be at least 6 characters")
});

type LoginFormValues = z.infer<typeof loginSchema>;

export default function LoginPage() {
  const dispatch = useDispatch<AppDispatch>();
  const router = useRouter();
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
    setError
  } = useForm<LoginFormValues>({
    resolver: zodResolver(loginSchema),
    defaultValues: { email: "", password: "" }
  });

  const onSubmit = async (values: LoginFormValues) => {
    const resultAction = await dispatch(login(values));
    if (login.fulfilled.match(resultAction)) {
      setAccessTokenCookie(resultAction.payload.accessToken);
      router.push("/dashboard");
      return;
    }
    setError("root", { message: "Login failed. Please verify your credentials." });
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-bg">
      <form onSubmit={handleSubmit(onSubmit)} className="card w-full max-w-sm space-y-3">
        <h1 className="text-xl font-semibold">Super Admin Login</h1>
        <input
          className="w-full rounded border border-slate-300 px-3 py-2"
          placeholder="Email"
          {...register("email")}
          required
        />
        {errors.email && <p className="text-xs text-danger">{errors.email.message}</p>}
        <input
          className="w-full rounded border border-slate-300 px-3 py-2"
          placeholder="Password"
          type="password"
          {...register("password")}
          required
        />
        {errors.password && <p className="text-xs text-danger">{errors.password.message}</p>}
        {errors.root?.message && <p className="text-xs text-danger">{errors.root.message}</p>}
        <button
          disabled={isSubmitting}
          className="w-full rounded bg-primary px-3 py-2 text-white disabled:cursor-not-allowed disabled:opacity-70"
        >
          {isSubmitting ? "Signing in..." : "Login"}
        </button>
      </form>
    </div>
  );
}
