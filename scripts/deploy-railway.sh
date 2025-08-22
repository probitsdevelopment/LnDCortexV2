#!/bin/bash

# Twenty CRM Railway Deployment Script
# Usage: ./scripts/deploy-railway.sh [environment] [service]
# Example: ./scripts/deploy-railway.sh dev frontend

set -e

ENVIRONMENT=${1:-dev}
SERVICE=${2:-all}

echo "🚀 Deploying Twenty CRM to Railway..."
echo "Environment: $ENVIRONMENT"
echo "Service: $SERVICE"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo -e "${RED}Railway CLI not found. Installing...${NC}"
    npm install -g @railway/cli
fi

# Check if user is logged in
if ! railway whoami &> /dev/null; then
    echo -e "${YELLOW}Please login to Railway:${NC}"
    railway login
fi

# Function to deploy specific service
deploy_service() {
    local service_name=$1
    local config_file=$2
    
    echo -e "${YELLOW}Deploying $service_name...${NC}"
    
    # Use specific railway config file
    if [ -f "$config_file" ]; then
        cp "$config_file" railway.json
        railway up --service "$service_name-$ENVIRONMENT"
        rm railway.json
    else
        echo -e "${RED}Config file $config_file not found!${NC}"
        exit 1
    fi
}

# Deploy based on service parameter
case $SERVICE in
    "frontend"|"front")
        deploy_service "twenty-frontend" "railway-front.json"
        ;;
    "backend"|"server")
        deploy_service "twenty-backend" "railway-server.json" 
        ;;
    "worker")
        deploy_service "twenty-worker" "railway-worker.json"
        ;;
    "all")
        echo -e "${YELLOW}Deploying all services...${NC}"
        deploy_service "twenty-backend" "railway-server.json"
        deploy_service "twenty-worker" "railway-worker.json" 
        deploy_service "twenty-frontend" "railway-front.json"
        ;;
    *)
        echo -e "${RED}Invalid service: $SERVICE${NC}"
        echo "Valid options: frontend, backend, worker, all"
        exit 1
        ;;
esac

echo -e "${GREEN}✅ Deployment completed!${NC}"

# Display service URLs
echo -e "${YELLOW}Service URLs:${NC}"
railway status