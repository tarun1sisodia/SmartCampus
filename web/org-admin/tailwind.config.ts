import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./app/**/*.{js,ts,jsx,tsx,mdx}", "./components/**/*.{js,ts,jsx,tsx,mdx}"],
  theme: {
    extend: {
      colors: {
        primary: "#2563EB",
        secondary: "#0D9488",
        success: "#22C55E",
        warning: "#F97316",
        danger: "#EF4444",
        bg: "#F1F5F9",
        surface: "#FFFFFF",
        textPrimary: "#1E293B",
        textSecondary: "#64748B"
      }
    }
  },
  darkMode: "class",
  plugins: []
};

export default config;
