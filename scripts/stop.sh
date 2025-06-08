#!/bin/bash
# API Gateway stop script

set -e

echo "🛑 Stopping API Gateway..."

# Stop the gateway
docker-compose down

echo "✅ API Gateway stopped successfully!"

# Optionally remove the shared network if no other services are using it
# echo "🔍 Checking if microservices network can be removed..."
# if docker network ls | grep -q "microservices_network"; then
#     if [ "$(docker network inspect microservices_network --format='{{len .Containers}}')" -eq "0" ]; then
#         echo "📡 Removing empty microservices network..."
#         docker network rm microservices_network
#     else
#         echo "📡 Keeping microservices network (other services connected)"
#     fi
# fi