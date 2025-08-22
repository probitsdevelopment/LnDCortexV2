# Railway Deployment Guide

This guide explains how to deploy the Twenty-based LnDCortexV2 application on Railway with auto-deploy from GitHub.

## Architecture Overview

The application consists of 5 services:
- **PostgreSQL Database** (managed service)
- **Redis** (managed service) 
- **twenty-server** (NestJS backend API)
- **twenty-worker** (background job processor)
- **twenty-front** (React frontend)

## Prerequisites

1. Railway account
2. GitHub repository with this code
3. Domain name (optional, for custom domains)

## Step 1: Create New Railway Project

1. Go to [Railway Dashboard](https://railway.com/dashboard)
2. Click "New Project"
3. Choose "Empty Project"
4. Rename project to "LnDCortexV2" or desired name

## Step 2: Add Database Services

### Add PostgreSQL
1. Click "New" → "Database" → "PostgreSQL"
2. Name it "Postgres"
3. Wait for deployment to complete

### Add Redis
1. Click "New" → "Database" → "Redis"
2. Name it "Redis"  
3. Wait for deployment to complete

## Step 3: Deploy Backend Services

### Deploy twenty-server
1. Click "New" → "GitHub Repo"
2. Select your forked repository
3. Service name: "twenty-server"
4. In service settings:
   - **Root Directory**: `/`
   - **Build Command**: (leave empty, Docker handles this)
   - **Start Command**: (leave empty, Docker handles this)
5. Go to "Variables" tab and add:
   ```
   RAILWAY_CONFIG_FILE=railway-server.json
   ```
6. Deploy the service

### Deploy twenty-worker
1. Click "New" → "GitHub Repo" 
2. Select your repository again
3. Service name: "twenty-worker"
4. In service settings:
   - **Root Directory**: `/`
5. Go to "Variables" tab and add:
   ```
   RAILWAY_CONFIG_FILE=railway-worker.json
   ```
6. Deploy the service

## Step 4: Deploy Frontend Service

### Deploy twenty-front
1. Click "New" → "GitHub Repo"
2. Select your repository again  
3. Service name: "twenty-front"
4. In service settings:
   - **Root Directory**: `/`
5. Go to "Variables" tab and add:
   ```
   RAILWAY_CONFIG_FILE=railway-front.json
   ```
6. Deploy the service

## Step 5: Configure Networking

### Generate Domains
1. Go to each service's "Settings" → "Networking"
2. Click "Generate Domain" for:
   - twenty-server
   - twenty-front
3. Note down the generated domains

### Update Environment Variables
The services should automatically reference each other via the configuration files, but verify:

**twenty-server variables include**:
- `FRONT_BASE_URL`: References twenty-front domain
- `DATABASE_URL`: References Postgres service
- `REDIS_URL`: References Redis service

**twenty-front variables include**:
- `REACT_APP_SERVER_BASE_URL`: References twenty-server domain

## Step 6: Configure Auto-Deploy from GitHub

### Enable GitHub Integration
1. Go to each service's "Settings" → "Source"
2. Ensure "Auto Deploy" is enabled
3. Set branch to `main` (or your default branch)
4. Configure "Watch Paths" for efficient builds:

**For twenty-server**:
```
packages/twenty-server/**
packages/twenty-shared/**
packages/twenty-emails/**
packages/twenty-utils/**
railway-server.json
```

**For twenty-worker**:
```
packages/twenty-server/**
packages/twenty-shared/**
packages/twenty-emails/**
packages/twenty-utils/**
railway-worker.json
```

**For twenty-front**:
```
packages/twenty-front/**
packages/twenty-ui/**
packages/twenty-shared/**
packages/twenty-utils/**
railway-front.json
```

## Step 7: Environment Variables Setup

### Required Environment Variables

Add these to your Railway project environment:

**Global Variables** (can be shared across services):
```bash
# Security tokens (use Railway project ID for simplicity)
ACCESS_TOKEN_SECRET=${{RAILWAY_PROJECT_ID}}
LOGIN_TOKEN_SECRET=${{RAILWAY_PROJECT_ID}}
REFRESH_TOKEN_SECRET=${{RAILWAY_PROJECT_ID}}
FILE_TOKEN_SECRET=${{RAILWAY_PROJECT_ID}}

# Application configuration
SIGN_IN_PREFILLED=false
STORAGE_TYPE=local
MESSAGE_QUEUE_TYPE=bull-mq
LOGGER_DRIVER=console
```

### Optional Environment Variables

For production customization:
```bash
# Email configuration (if using email features)
EMAIL_FROM_ADDRESS=noreply@yourdomain.com
EMAIL_FROM_NAME="Your App Name"

# File storage (if using external storage)
STORAGE_S3_REGION=us-east-1
STORAGE_S3_BUCKET_NAME=your-bucket-name

# Analytics (if using ClickHouse)
ANALYTICS_ENABLED=false
```

## Step 8: Database Initialization

After deployment, initialize the database:

1. Go to twenty-server service
2. Open the "Deployments" tab
3. Click on the latest deployment
4. Use the "Terminal" or check logs for any migration commands needed

The application should automatically run migrations on startup.

## Step 9: Verification

### Health Checks
- **twenty-server**: `https://your-server-domain.railway.app/healthz`
- **twenty-front**: `https://your-frontend-domain.railway.app/health`

### Application Access
- Frontend: `https://your-frontend-domain.railway.app`
- Backend API: `https://your-server-domain.railway.app/graphql`
- Backend REST: `https://your-server-domain.railway.app/rest`

## Troubleshooting

### Common Issues

1. **Services failing to start**:
   - Check service logs in Railway dashboard
   - Verify environment variables are set correctly
   - Ensure Docker builds complete successfully

2. **Database connection issues**:
   - Verify DATABASE_URL is properly referenced
   - Check PostgreSQL service is running
   - Ensure network connectivity between services

3. **Frontend not connecting to backend**:
   - Verify REACT_APP_SERVER_BASE_URL points to correct backend domain
   - Check CORS configuration in backend
   - Ensure both services are deployed and running

4. **Auto-deploy not triggering**:
   - Check Watch Paths configuration
   - Verify GitHub webhook is active
   - Ensure branch name matches configured branch

### Monitoring

- **Logs**: Available in each service's dashboard
- **Metrics**: CPU, Memory, Network usage in service overview
- **Uptime**: Monitor via health check endpoints

## Advanced Configuration

### Custom Domains
1. In service settings → Networking
2. Add custom domain
3. Configure DNS records as instructed
4. Update environment variables to use custom domains

### Scaling
- Adjust replica count in service settings
- Monitor resource usage and scale accordingly
- Consider upgrading Railway plan for higher limits

### Security
- Use Railway's environment variable encryption
- Enable Railway's IP allowlisting if needed
- Configure proper CORS origins
- Set up monitoring and alerting

## Production Checklist

- [ ] All services deployed and healthy
- [ ] Database initialized with migrations
- [ ] Environment variables configured
- [ ] Domains generated and working
- [ ] Health checks passing
- [ ] Auto-deploy configured
- [ ] Monitoring setup
- [ ] Backup strategy defined
- [ ] Security measures implemented