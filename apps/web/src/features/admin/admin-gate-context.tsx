"use client";

import { createContext, useCallback, useContext } from "react";
import { adminCall, SECOND_FACTOR_REQUIRED, type ApiResult } from "./platform-api";

/** Called when an admin API says the second factor is missing or expired; the gate then asks for a code. */
export const AdminLockContext = createContext<() => void>(() => {});

/** `adminCall` that re-locks the admin area on `second_factor_required`. */
export function useAdminCall() {
  const lock = useContext(AdminLockContext);
  return useCallback(
    async <T,>(url: string, init?: RequestInit): Promise<ApiResult<T>> => {
      const result = await adminCall<T>(url, init);
      if (!result.ok && result.code === SECOND_FACTOR_REQUIRED) lock();
      return result;
    },
    [lock],
  );
}
