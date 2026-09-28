# D-Card worker (BullMQ consumers). Build context: repo root.
#   docker build -f apps/worker/Dockerfile .
FROM node:24-slim AS build
WORKDIR /app
RUN corepack enable
# Workspace manifests first so the dependency layer caches between code changes.
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json tsconfig*.json ./
COPY packages ./packages
COPY apps/worker ./apps/worker
RUN pnpm install --frozen-lockfile --filter "@dcard/worker..." \
 && pnpm turbo run build --filter "@dcard/worker..."

FROM node:24-slim
ENV NODE_ENV=production
WORKDIR /app
COPY --from=build /app /app
USER node
CMD ["node", "apps/worker/dist/main.js"]
