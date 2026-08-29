// =============================================================
// store.ts (org-admin)  ->  ALGORITHM ONLY (source: web/org-admin/lib/store/store.ts)
// =============================================================

// configureStore: reducer { auth }
//   preloadedState = hydrateAuth()  -> restore session from sessionStorage on reload
// injectStore(store) -> let axios interceptors read/dispatch auth
// export RootState + AppDispatch types
