FROM node:20-alpine AS builder

WORKDIR /app

# Copy dependency files
COPY package.json yarn.lock ./

# Install dependencies with frozen lockfile
RUN yarn install --frozen-lockfile

# Copy application code
COPY . .

# Environment variables (non-sensitive)
ENV VITE_APP_API_ENDPOINT_URL="https://api.themoviedb.org/3"

# Build the application with secret mounted
RUN --mount=type=secret,id=tmdb_api_key \
    VITE_APP_TMDB_V3_API_KEY=$(cat /run/secrets/tmdb_api_key) \
    yarn build

# Production stage
FROM nginx:stable-alpine

# Copy custom nginx config (if you have one)
# COPY nginx.conf /etc/nginx/nginx.conf

WORKDIR /usr/share/nginx/html

# Remove default nginx static assets
RUN rm -rf ./*

# Copy built assets from builder
COPY --from=builder /app/dist .

# Run as non-root user
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid

USER nginx

EXPOSE 80

ENTRYPOINT ["nginx", "-g", "daemon off;"]