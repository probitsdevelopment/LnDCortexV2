# Use the Node LTS official image
FROM node:lts-alpine AS build

# Set config to reduce output noise
ENV NPM_CONFIG_UPDATE_NOTIFIER=false
ENV NPM_CONFIG_FUND=false

# Create and change to the app directory
WORKDIR /app

# Copy workspace package files first (for better caching)
COPY package.json yarn.lock nx.json tsconfig.base.json ./

# Copy package.json files for all dependencies
COPY packages/twenty-server/package.json ./packages/twenty-server/
COPY packages/twenty-shared/package.json ./packages/twenty-shared/
COPY packages/twenty-utils/package.json ./packages/twenty-utils/
COPY packages/twenty-emails/package.json ./packages/twenty-emails/

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy the application code
COPY packages/twenty-server ./packages/twenty-server
COPY packages/twenty-shared ./packages/twenty-shared
COPY packages/twenty-utils ./packages/twenty-utils
COPY packages/twenty-emails ./packages/twenty-emails
COPY tools ./tools

# Build the server
RUN npx nx build twenty-server

# Production stage
FROM node:lts-alpine AS production

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Create app user for security
RUN addgroup -g 1001 -S nodejs
RUN adduser -S twenty -u 1001

# Set working directory
WORKDIR /app

# Copy built application
COPY --from=build --chown=twenty:nodejs /app/packages/twenty-server/dist ./dist
COPY --from=build --chown=twenty:nodejs /app/packages/twenty-server/package.json ./package.json
COPY --from=build --chown=twenty:nodejs /app/yarn.lock ./yarn.lock

# Install only production dependencies
RUN yarn install --frozen-lockfile --production && yarn cache clean

# Switch to non-root user
USER twenty

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD node -e "const http = require('http'); const options = { port: 3000, path: '/healthz', timeout: 5000 }; const req = http.request(options, (res) => { if (res.statusCode === 200) { process.exit(0); } else { process.exit(1); } }); req.on('error', () => process.exit(1)); req.end();"

# Start the server with dumb-init for proper signal handling
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/src/main.js"]