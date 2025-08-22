# Twenty CRM Railway Deployment Guide

## Overview
This guide helps you deploy Twenty CRM on Railway.app with separate development and testing environments.

## Prerequisites
- Railway account
- GitHub repository with your Twenty CRM code
- Railway CLI (optional but recommended)

## Project Structure
Your monorepo will deploy as 4 separate Railway services:
- **Frontend** (twenty-front)
- **Backend API** (twenty-server) 
- **Background Worker** (twenty-worker)
- **Databases** (PostgreSQL + Redis)

## Step 1: Create Railway Project

1. Go to [Railway.app](https://railway.app)
2. Click "New Project"
3. Select "Deploy from GitHub repo"
4. Choose your Twenty CRM repository

## Step 2: Set Up Services

### Create 4 Services:
1. **Frontend Service**
2. **Backend Service** 
3. **Worker Service**
4. **Database Services** (PostgreSQL + Redis)

### Configure Each Service:

#### Frontend Service
- Service Name: `twenty-frontend-dev` (or `twenty-frontend-test`)
- Config File: `railway-front.json`
- Environment Variables:
  ```
  REACT_APP_SERVER_BASE_URL=https://[your-backend-service].railway.app
  NODE_ENV=development (or test)
  NIXPACKS_NX_APP_NAME=twenty-front
  ```

#### Backend Service  
- Service Name: `twenty-backend-dev` (or `twenty-backend-test`)
- Config File: `railway-server.json`
- Environment Variables:
  ```
  NODE_ENV=development (or test)
  NIXPACKS_NX_APP_NAME=twenty-server
  DATABASE_URL=${{Postgres.DATABASE_URL}}
  REDIS_URL=${{Redis.REDIS_URL}}
  JWT_SECRET=[generate-random-secret]
  FRONT_BASE_URL=https://[your-frontend-service].railway.app
  ```

#### Worker Service
- Service Name: `twenty-worker-dev` (or `twenty-worker-test`) 
- Config File: `railway-worker.json`
- Environment Variables:
  ```
  NODE_ENV=development (or test)
  NIXPACKS_NX_APP_NAME=twenty-server
  DATABASE_URL=${{Postgres.DATABASE_URL}}
  REDIS_URL=${{Redis.REDIS_URL}}
  ```

#### Database Services
1. **Add PostgreSQL**:
   - Click "New" → "Database" → "PostgreSQL"
   - Service Name: `postgres-dev` (or `postgres-test`)

2. **Add Redis**:
   - Click "New" → "Database" → "Redis"  
   - Service Name: `redis-dev` (or `redis-test`)

## Step 3: Environment Variables

### Required Environment Variables:

#### Backend (.env variables)
```bash
# Database
DATABASE_URL=${{Postgres.DATABASE_URL}}
REDIS_URL=${{Redis.REDIS_URL}}

# JWT & Security
JWT_SECRET=your-super-secret-jwt-key-here
ACCESS_TOKEN_SECRET=your-access-token-secret
LOGIN_TOKEN_SECRET=your-login-token-secret
REFRESH_TOKEN_SECRET=your-refresh-token-secret

# URLs
FRONT_BASE_URL=https://[frontend-service].railway.app
SERVER_URL=https://[backend-service].railway.app

# Email (optional)
EMAIL_FROM_ADDRESS=noreply@yourdomain.com
EMAIL_SYSTEM_ADDRESS=system@yourdomain.com

# Storage
STORAGE_TYPE=local
STORAGE_LOCAL_PATH=.local-storage

# Features
SIGN_IN_PREFILLED=true
IS_SIGN_UP_DISABLED=false
```

#### Frontend (.env variables)
```bash
REACT_APP_SERVER_BASE_URL=https://[backend-service].railway.app
GENERATE_SOURCEMAP=false
```

## Step 4: Deployment Commands

Each service uses these commands:

### Frontend
- Build: `npx nx build twenty-front`
- Start: `npx nx start twenty-front`

### Backend  
- Build: `npx nx build twenty-server`
- Start: `npx nx start twenty-server`

### Worker
- Build: `npx nx build twenty-server` 
- Start: `npx nx run twenty-server:worker`

## Step 5: Custom Start Commands

Set these in Railway Service Settings → Start Command:

- **Frontend**: `npx nx start twenty-front`
- **Backend**: `npx nx start twenty-server`  
- **Worker**: `npx nx run twenty-server:worker`

## Step 6: Health Checks

Backend service includes health check at `/healthz` endpoint.

## Step 7: Watch Paths (Important!)

To prevent unnecessary rebuilds, configure watch paths for each service:

- **Frontend**: `packages/twenty-front/**`
- **Backend**: `packages/twenty-server/**`
- **Worker**: `packages/twenty-server/**`

## Two Environment Setup

### Development Environment
- Project Name: `twenty-crm-dev`
- Services: `twenty-frontend-dev`, `twenty-backend-dev`, `twenty-worker-dev`
- GitHub Branch: `develop` or `main`

### Testing Environment  
- Project Name: `twenty-crm-test`
- Services: `twenty-frontend-test`, `twenty-backend-test`, `twenty-worker-test`
- GitHub Branch: `staging` or `test`

## Quick Deploy Commands

Using Railway CLI:

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Link to project
railway link [project-id]

# Deploy specific service
railway up --service [service-name]
```

## Common Issues & Solutions

1. **Build Timeouts**: Increase build timeout in service settings
2. **Memory Issues**: Upgrade Railway plan or optimize build process
3. **Environment Variables**: Double-check all required variables are set
4. **Database Connections**: Ensure DATABASE_URL and REDIS_URL are properly referenced

## Monitoring

- Check logs in Railway dashboard
- Monitor resource usage
- Set up alerts for failures

## Next Steps

1. Set up custom domain (optional)
2. Configure SSL certificates  
3. Set up monitoring and logging
4. Configure CI/CD with GitHub Actions
5. Set up backups for databases

## Support

- Railway Documentation: https://docs.railway.app
- Twenty CRM Documentation: https://twenty.com/docs
- Community Support: Railway Discord or Twenty GitHub issues