import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./lib/**/*.{js,ts,jsx,tsx,mdx}"
  ],
  theme: {
    extend: {
      colors: {
        primary: "#4F46E5",
        secondary: "#64748B",
        success: "#10B981",
        warning: "#F59E0B",
        danger: "#E11D48",
        bg: "#F8FAFC",
        surface: "#FFFFFF",
        textPrimary: "#111827",
        textSecondary: "#6B7280"
      }
    }
  },
  darkMode: "class",
  plugins: []
};

export default config;
