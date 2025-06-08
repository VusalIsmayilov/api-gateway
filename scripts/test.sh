#!/bin/bash
# API Gateway test script

set -e

echo "🧪 Testing API Gateway..."

# Test gateway health
echo "🔍 Testing gateway health..."
if curl -f http://localhost:9090/health >/dev/null 2>&1; then
    echo "✅ Gateway health: OK"
else
    echo "❌ Gateway health: FAILED"
    exit 1
fi

# Test AuthService through gateway
echo "🔍 Testing AuthService through gateway..."
if curl -f http://localhost/health >/dev/null 2>&1; then
    echo "✅ AuthService proxy: OK"
else
    echo "❌ AuthService proxy: FAILED"
fi

# Test Keycloak through gateway
echo "🔍 Testing Keycloak through gateway..."
if curl -f http://localhost:8081/health/ready >/dev/null 2>&1; then
    echo "✅ Keycloak proxy: OK"
else
    echo "❌ Keycloak proxy: FAILED"
fi

# Test PgAdmin through gateway
echo "🔍 Testing PgAdmin through gateway..."
if curl -f http://localhost:8080/ >/dev/null 2>&1; then
    echo "✅ PgAdmin proxy: OK"
else
    echo "❌ PgAdmin proxy: FAILED"
fi

# Test rate limiting
echo "🔍 Testing rate limiting..."
echo "Making 6 rapid API calls to test rate limiting..."
for i in {1..6}; do
    response_code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/api/admin/status)
    if [ "$response_code" = "429" ]; then
        echo "✅ Rate limiting: Working (got 429 on request $i)"
        break
    elif [ "$i" = "6" ]; then
        echo "⚠️  Rate limiting: May not be triggered (all requests succeeded)"
    fi
done

# Test monitoring endpoints
echo "🔍 Testing monitoring endpoints..."
if curl -f http://localhost:9090/services >/dev/null 2>&1; then
    echo "✅ Services endpoint: OK"
else
    echo "❌ Services endpoint: FAILED"
fi

if curl -f http://localhost:9090/nginx_status >/dev/null 2>&1; then
    echo "✅ Nginx status: OK"
else
    echo "❌ Nginx status: FAILED"
fi

echo ""
echo "📊 Gateway Service Status:"
curl -s http://localhost:9090/services 2>/dev/null | python3 -m json.tool || echo "Failed to get service status"

echo ""
echo "🎯 Test Results Summary:"
echo "   Gateway: $(curl -s http://localhost:9090/health 2>/dev/null | grep -q healthy && echo "✅ Healthy" || echo "❌ Unhealthy")"
echo "   AuthService: $(curl -f http://localhost/health >/dev/null 2>&1 && echo "✅ Available" || echo "❌ Unavailable")"
echo "   Keycloak: $(curl -f http://localhost:8081/health/ready >/dev/null 2>&1 && echo "✅ Available" || echo "❌ Unavailable")"
echo "   PgAdmin: $(curl -f http://localhost:8080/ >/dev/null 2>&1 && echo "✅ Available" || echo "❌ Unavailable")"