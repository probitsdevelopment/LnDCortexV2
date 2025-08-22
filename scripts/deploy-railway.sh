#!/bin/bash

# Railway Deployment Script for LnDCortexV2
# This script helps set up the Railway deployment configuration

set -e

echo "🚂 Railway Deployment Setup for LnDCortexV2"
echo "=============================================="

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI not found. Please install it first:"
    echo "   npm install -g @railway/cli"
    echo "   or visit: https://docs.railway.com/cli/installation"
    exit 1
fi

echo "✅ Railway CLI found"

# Check if user is logged in
if ! railway status &> /dev/null; then
    echo "🔐 Please log in to Railway first:"
    echo "   railway login"
    exit 1
fi

echo "✅ Railway authentication verified"

# Function to create and configure a service
configure_service() {
    local service_name=$1
    local config_file=$2
    local description=$3
    
    echo ""
    echo "📦 Configuring $service_name service..."
    echo "   Description: $description"
    echo "   Config file: $config_file"
    
    # Link to the service (user needs to create services manually first)
    echo "⚠️  Please ensure you have created a '$service_name' service in your Railway project"
    echo "   Then run: railway link --service $service_name"
    echo "   And set the RAILWAY_CONFIG_FILE variable to: $config_file"
}

# Function to check if required files exist
check_files() {
    echo ""
    echo "📋 Checking required files..."
    
    local files=(
        "railway-front.json"
        "railway-server.json" 
        "railway-worker.json"
        "packages/twenty-front/Dockerfile"
        "packages/twenty-server/Dockerfile"
        "packages/twenty-worker/Dockerfile"
        "packages/twenty-front/nginx.conf"
    )
    
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            echo "   ✅ $file"
        else
            echo "   ❌ $file (missing)"
            return 1
        fi
    done
    
    echo "✅ All required files present"
}

# Function to validate Docker files
validate_docker() {
    echo ""
    echo "🐳 Validating Docker configurations..."
    
    # Check if Docker is available
    if ! command -v docker &> /dev/null; then
        echo "⚠️  Docker not found - skipping validation"
        return 0
    fi
    
    echo "   Validating frontend Dockerfile..."
    if docker build -f packages/twenty-front/Dockerfile -t test-front . --dry-run &> /dev/null; then
        echo "   ✅ Frontend Dockerfile valid"
    else
        echo "   ❌ Frontend Dockerfile has issues"
    fi
    
    echo "   Validating server Dockerfile..."
    if docker build -f packages/twenty-server/Dockerfile -t test-server . --dry-run &> /dev/null; then
        echo "   ✅ Server Dockerfile valid"
    else
        echo "   ❌ Server Dockerfile has issues"
    fi
    
    echo "   Validating worker Dockerfile..."
    if docker build -f packages/twenty-worker/Dockerfile -t test-worker . --dry-run &> /dev/null; then
        echo "   ✅ Worker Dockerfile valid"
    else
        echo "   ❌ Worker Dockerfile has issues"
    fi
}

# Function to display deployment instructions
show_instructions() {
    echo ""
    echo "🚀 Railway Deployment Instructions"
    echo "=================================="
    echo ""
    echo "1. Create a new Railway project:"
    echo "   - Go to https://railway.com/dashboard"
    echo "   - Click 'New Project' → 'Empty Project'"
    echo "   - Name it 'LnDCortexV2' (or your preferred name)"
    echo ""
    echo "2. Add database services:"
    echo "   - PostgreSQL: Click 'New' → 'Database' → 'PostgreSQL'"
    echo "   - Redis: Click 'New' → 'Database' → 'Redis'"
    echo ""
    echo "3. Deploy application services from GitHub:"
    echo "   - twenty-server: Click 'New' → 'GitHub Repo' → Select repo"
    echo "   - twenty-worker: Click 'New' → 'GitHub Repo' → Select repo"
    echo "   - twenty-front: Click 'New' → 'GitHub Repo' → Select repo"
    echo ""
    echo "4. Configure each service:"
    echo "   - Set RAILWAY_CONFIG_FILE environment variable:"
    echo "     • twenty-server: railway-server.json"
    echo "     • twenty-worker: railway-worker.json"
    echo "     • twenty-front: railway-front.json"
    echo ""
    echo "5. Enable auto-deploy:"
    echo "   - Go to each service → Settings → Source"
    echo "   - Enable 'Auto Deploy'"
    echo "   - Set appropriate watch paths (see RAILWAY_DEPLOYMENT.md)"
    echo ""
    echo "6. Generate domains:"
    echo "   - Go to service Settings → Networking"
    echo "   - Click 'Generate Domain' for server and frontend"
    echo ""
    echo "📖 For detailed instructions, see: RAILWAY_DEPLOYMENT.md"
}

# Function to show environment variables template
show_env_template() {
    echo ""
    echo "🔧 Environment Variables Template"
    echo "================================"
    echo ""
    echo "Add these to your Railway project environment:"
    echo ""
    echo "# Security (Railway will auto-generate these)"
    echo "ACCESS_TOKEN_SECRET=\${{RAILWAY_PROJECT_ID}}"
    echo "LOGIN_TOKEN_SECRET=\${{RAILWAY_PROJECT_ID}}"
    echo "REFRESH_TOKEN_SECRET=\${{RAILWAY_PROJECT_ID}}"
    echo "FILE_TOKEN_SECRET=\${{RAILWAY_PROJECT_ID}}"
    echo ""
    echo "# Application Configuration"
    echo "SIGN_IN_PREFILLED=false"
    echo "STORAGE_TYPE=local"
    echo "MESSAGE_QUEUE_TYPE=bull-mq"
    echo "LOGGER_DRIVER=console"
    echo ""
    echo "# Service Configuration Files"
    echo "# (Set these individually per service)"
    echo "# twenty-server: RAILWAY_CONFIG_FILE=railway-server.json"
    echo "# twenty-worker: RAILWAY_CONFIG_FILE=railway-worker.json"
    echo "# twenty-front: RAILWAY_CONFIG_FILE=railway-front.json"
}

# Main execution
main() {
    # Check if we're in the right directory
    if [[ ! -f "package.json" ]] || [[ ! -d "packages" ]]; then
        echo "❌ Please run this script from the project root directory"
        exit 1
    fi
    
    # Validate setup
    check_files || {
        echo ""
        echo "❌ Missing required files. Please ensure all Dockerfiles and Railway configs are present."
        exit 1
    }
    
    # Validate Docker configurations
    validate_docker
    
    # Show service configuration info
    echo ""
    echo "📊 Service Overview"
    echo "=================="
    configure_service "twenty-front" "railway-front.json" "React frontend with Nginx"
    configure_service "twenty-server" "railway-server.json" "NestJS backend API server"
    configure_service "twenty-worker" "railway-worker.json" "Background job processor"
    
    # Show instructions
    show_instructions
    
    # Show environment variables
    show_env_template
    
    echo ""
    echo "✅ Setup validation complete!"
    echo ""
    echo "📝 Next steps:"
    echo "   1. Follow the deployment instructions above"
    echo "   2. See RAILWAY_DEPLOYMENT.md for detailed guidance"
    echo "   3. Monitor deployments in Railway dashboard"
    echo ""
    echo "🆘 Need help? Check the troubleshooting section in RAILWAY_DEPLOYMENT.md"
}

# Run main function
main "$@"