#!/bin/bash
# API Gateway startup script

set -e

echo "🚀 Starting API Gateway..."

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Create shared network if it doesn't exist
if ! docker network ls | grep -q "microservices_network"; then
    echo "📡 Creating microservices network..."
    docker network create microservices_network --subnet=172.20.0.0/16
fi

# Start the gateway
echo "🌐 Starting API Gateway container..."
docker-compose up -d

# Wait for startup
echo "⏳ Waiting for gateway to be ready..."
sleep 10

# Health check
echo "🔍 Checking gateway health..."
if curl -f http://localhost:9090/health >/dev/null 2>&1; then
    echo "✅ API Gateway is running successfully!"
    echo ""
    echo "📍 Service Endpoints:"
    echo "   AuthService: http://localhost"
    echo "   Keycloak:    http://localhost:8081"
    echo "   PgAdmin:     http://localhost:8080"
    echo "   Monitor:     http://localhost:9090"
    echo ""
    echo "📊 Gateway Status:"
    curl -s http://localhost:9090/services | python3 -m json.tool 2>/dev/null || echo "   Gateway is running"
else
    echo "❌ API Gateway health check failed"
    echo "📋 Checking logs..."
    docker-compose logs api-gateway | tail -20
    exit 1
fi