# --- Base build image (with full toolchain) ---
FROM node:18-alpine AS builder

WORKDIR /app

# install dependencies
COPY package.json package-lock.json ./
RUN npm ci

# copy source and build
COPY . .
RUN npm run build

# --- Production runtime ---
FROM node:18-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

# copy only production deps
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# copy build artifacts
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/next.config.* ./

EXPOSE 3000
CMD ["npm", "start"]
