"use client";

import axios from "axios";

const API_URL = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8080";

export const axiosClient = axios.create({
  baseURL: API_URL
});
