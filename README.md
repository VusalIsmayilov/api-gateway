# API Gateway

Enterprise-grade API Gateway using Nginx for microservices architecture.

## 🚀 Quick Start

```bash
# Start the API Gateway
docker-compose up -d

# Check gateway status
curl http://localhost:9090/health

# View all services
curl http://localhost:9090/services
```

## 🌐 Service Endpoints

### Primary Services
- **AuthService API**: http://localhost
  - Swagger: http://localhost/swagger
  - Health: http://localhost/health
  - Admin: http://localhost/api/admin/status

- **Keycloak**: http://localhost:8081
  - Admin Console: http://localhost:8081/admin
  - Health: http://localhost:8081/health/ready

- **PgAdmin**: http://localhost:8080
  - Database Administration Interface

### Monitoring
- **Gateway Monitor**: http://localhost:9090
  - Health: http://localhost:9090/health
  - Services: http://localhost:9090/services
  - Nginx Status: http://localhost:9090/nginx_status

## 🔧 Configuration

### Service-Specific Configs
- `nginx/conf.d/authservice.conf` - Authentication service routing
- `nginx/conf.d/keycloak.conf` - Identity provider routing  
- `nginx/conf.d/pgadmin.conf` - Database admin routing
- `nginx/conf.d/monitoring.conf` - Gateway monitoring

### Rate Limiting
- **Global**: 100 req/s per IP
- **API**: 10 req/s per IP
- **Auth**: 5 req/s per IP (login, register, etc.)
- **Admin**: 2 req/s per IP (admin operations)

### Security Features
- Security headers (X-Frame-Options, XSS Protection, etc.)
- Request size limits
- Connection limiting (20 per IP)
- Real IP detection for load balancer scenarios

## 📊 Monitoring & Logs

### Service Logs
```bash
# Gateway logs
docker-compose logs -f api-gateway

# Specific service logs
docker exec api_gateway tail -f /var/log/nginx/authservice_api.log
docker exec api_gateway tail -f /var/log/nginx/keycloak_admin.log
docker exec api_gateway tail -f /var/log/nginx/pgadmin_access.log
```

### Health Checks
```bash
# Gateway health
curl http://localhost:9090/health

# Service health through gateway
curl http://localhost/health          # AuthService
curl http://localhost:8081/health/ready  # Keycloak
```

## 🔗 Network Architecture

```
Internet/Client
      ↓
API Gateway (Nginx) :80, :8081, :8080, :9090
      ↓
┌─────────────────────────────────────────┐
│         microservices_network          │
│                                         │
│  AuthService ←→ Keycloak ←→ PgAdmin    │
│       ↓                                 │
│   PostgreSQL                           │
└─────────────────────────────────────────┘
```

## 🚀 Adding New Services

1. **Create service configuration**:
   ```bash
   # Example: nginx/conf.d/orderservice.conf
   upstream orderservice_backend {
       server orderservice_app:8080;
   }
   
   server {
       listen 8082;
       location / {
           proxy_pass http://orderservice_backend;
           # ... proxy settings
       }
   }
   ```

2. **Update docker-compose.yml**:
   ```yaml
   services:
     api-gateway:
       ports:
         - "8082:8082"  # Add new service port
   ```

3. **Add to monitoring**:
   Update `monitoring.conf` services endpoint.

## 🛠️ Development vs Production

### Development (Current)
- AuthService runs locally (`host.docker.internal:5000`)
- Simple SSL configuration
- Detailed logging enabled

### Production
- All services containerized
- Proper SSL/TLS certificates
- Log aggregation
- Health check alerting

## 🔒 Security Considerations

### Production Checklist
- [ ] Enable HTTPS/TLS termination
- [ ] Implement proper SSL certificates
- [ ] Add IP whitelisting for admin endpoints
- [ ] Configure log rotation
- [ ] Set up monitoring alerts
- [ ] Implement JWT validation at gateway level
- [ ] Add CORS policies
- [ ] Enable access logging for audit

## 📈 Performance Tuning

### Connection Pooling
- Keepalive connections to backend services
- Connection limits per IP
- Buffer size optimization

### Caching
- Static asset caching for PgAdmin
- Response caching for read-only endpoints
- Browser cache headers

### Scaling
- Multiple gateway instances behind load balancer
- Backend service auto-scaling
- Database connection pooling

## 🐛 Troubleshooting

### Common Issues

1. **Service Unreachable**
   ```bash
   # Check service status
   docker-compose ps
   
   # Test backend directly
   curl http://localhost:5000/health  # AuthService
   docker exec api_gateway curl http://authservice_keycloak:8080/health/ready
   ```

2. **Rate Limiting Issues**
   ```bash
   # Check rate limit status
   curl http://localhost:9090/rate-limits
   
   # View nginx error logs
   docker-compose logs api-gateway | grep "limiting requests"
   ```

3. **Configuration Errors**
   ```bash
   # Test nginx configuration
   docker exec api_gateway nginx -t
   
   # Reload configuration
   docker exec api_gateway nginx -s reload
   ```

## 📝 Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `GATEWAY_HTTP_PORT` | 80 | Main HTTP port |
| `GATEWAY_HTTPS_PORT` | 443 | Main HTTPS port |
| `KEYCLOAK_PORT` | 8081 | Keycloak access port |
| `PGADMIN_PORT` | 8080 | PgAdmin access port |
| `MONITORING_PORT` | 9090 | Gateway monitoring port |