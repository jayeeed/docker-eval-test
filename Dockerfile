# Stage 1: Build stage
FROM node:20-slim AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: Production stage
FROM node:20-slim AS runner
WORKDIR /app
ENV NODE_ENV=production

# Create a non-root user and group
RUN groupadd -r appuser && useradd -r -g appuser -u 1001 appuser

# Copy built dependencies and files from builder
COPY --from=builder /app/package*.json ./
RUN npm ci --omit=dev
COPY --from=builder /app/dist ./dist

# Change ownership of /app to the non-root user
RUN chown -R appuser:appuser /app

# Switch to the non-root user
USER appuser

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000', (res) => process.exit(res.statusCode === 200 ? 0 : 1))" || exit 1

CMD ["node", "dist/index.js"]
