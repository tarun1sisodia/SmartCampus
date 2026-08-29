// =============================================================
// Dockerfile (backend)  ->  ALGORITHM ONLY (source: backend/Dockerfile)
// =============================================================

// multi-stage: node:20-alpine builder -> npm install -> copy source
// final: node:20-alpine + app -> create NON-ROOT user nodeapp -> USER nodeapp
// EXPOSE 5000 -> CMD node server.js
