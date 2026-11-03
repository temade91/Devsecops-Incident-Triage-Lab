# Stage 1: Build & Dependency Resolution
FROM node:20-alpine3.19 AS dependencies
WORKDIR /app
COPY package*.json ./
# Production standard: strict lockfile installation
RUN npm ci --only=production && npm cache clean --force

# Stage 2: Hardened Runtime Container
FROM node:20-alpine3.19 AS runtime

# Security Hardening: Principle of Least Privilege
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy production node_modules and app code
COPY --from=dependencies /app/node_modules ./node_modules
COPY package.json index.js ./

# Enforce file ownership and drop root
RUN chown -R appuser:appgroup /app
USER appuser

EXPOSE 3000

# Container Healthcheck Probe
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:3000/healthz || exit 1

CMD ["node", "index.js"]