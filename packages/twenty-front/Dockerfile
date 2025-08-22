# Use the Node alpine official image
FROM node:lts-alpine AS build

# Set config to reduce output noise
ENV NPM_CONFIG_UPDATE_NOTIFIER=false
ENV NPM_CONFIG_FUND=false

# Create and change to the app directory
WORKDIR /app

# Copy workspace package files first (for better caching)
COPY package.json yarn.lock nx.json tsconfig.base.json ./

# Copy packages
COPY packages/twenty-front/package.json ./packages/twenty-front/
COPY packages/twenty-ui/package.json ./packages/twenty-ui/
COPY packages/twenty-shared/package.json ./packages/twenty-shared/
COPY packages/twenty-utils/package.json ./packages/twenty-utils/

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy the application code
COPY packages/twenty-front ./packages/twenty-front
COPY packages/twenty-ui ./packages/twenty-ui
COPY packages/twenty-shared ./packages/twenty-shared
COPY packages/twenty-utils ./packages/twenty-utils
COPY tools ./tools

# Build the frontend
RUN npx nx build twenty-front

# Production stage with nginx
FROM nginx:alpine

# Copy custom nginx config
COPY packages/twenty-front/nginx.conf /etc/nginx/conf.d/default.conf

# Copy the built app from build stage
COPY --from=build /app/packages/twenty-front/build /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]