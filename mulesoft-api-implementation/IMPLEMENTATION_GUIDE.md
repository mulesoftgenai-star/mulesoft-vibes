# MuleSoft API Templates - Implementation Guide

## Overview

This guide provides step-by-step instructions for implementing the Order Management System integration using the provided MuleSoft API templates following the API-Led Connectivity pattern.

## Prerequisites

### Technical Requirements
- **MuleSoft Anypoint Studio**: Version 7.14 or higher
- **Mule Runtime**: Version 4.6.0 or higher
- **Java Development Kit**: JDK 1.8 or JDK 11
- **Maven**: Version 3.8.0 or higher
- **Database**: MySQL 8.0+ (or compatible database)

### Access Requirements
- Anypoint Platform account with appropriate entitlements
- CloudHub or Runtime Fabric environment access
- Exchange permissions for publishing APIs
- API Manager access for security policies

## Architecture Overview

The templates implement a three-layer API-Led Connectivity architecture:

```
┌─────────────────────────────────────────────────────────────┐
│                    External Clients                        │
│            (Web Apps, Mobile Apps, B2B Partners)           │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│                   Experience Layer                         │
│               Order Experience API (8081)                  │
│           Customer-facing order operations                 │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│                    Process Layer                           │
│                Order Process API (8082)                    │
│              Business logic orchestration                  │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│                    System Layer                            │
│  Customer API │ Inventory API │ Payment API │ Shipping API │
│     (8083)    │     (8084)    │    (8085)   │    (8086)    │
└─────────────────────────────────────────────────────────────┘
```

## Implementation Steps

### Step 1: Environment Setup

#### 1.1 Clone or Copy Templates
```bash
# Copy the templates to your workspace
cp -r mulesoft-api-templates/ /path/to/your/workspace/
cd /path/to/your/workspace/mulesoft-api-templates/
```

#### 1.2 Database Setup
```sql
-- Create database
CREATE DATABASE order_management_dev;

-- Create tables (example for Customer System API)
CREATE TABLE customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    status ENUM('ACTIVE', 'INACTIVE', 'BLOCKED') DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

#### 1.3 Configure Properties
Update environment-specific properties:

**shared-resources/properties/config-dev.yaml**:
```yaml
# Update database connection
db:
  host: "your-database-host"
  port: "3306"
  name: "order_management_dev"

# Update system endpoints  
customer:
  api:
    host: "your-customer-system-host"
    port: "8083"
```

**shared-resources/properties/secure-properties-dev.yaml**:
```yaml
# Encrypt and update sensitive values
db:
  username: "![your-encrypted-db-username]"
  password: "![your-encrypted-db-password]"
```

### Step 2: Deploy System Layer APIs

Deploy APIs in this order to satisfy dependencies:

#### 2.1 Customer System API
```bash
cd system-layer/customer-system-api/
mvn clean compile
mvn clean package -DskipMunitTests
# Deploy to CloudHub or Runtime Fabric
```

#### 2.2 Inventory System API
```bash
cd ../inventory-system-api/
mvn clean compile
mvn clean package -DskipMunitTests
```

#### 2.3 Payment System API
```bash
cd ../payment-system-api/
mvn clean compile
mvn clean package -DskipMunitTests
```

#### 2.4 Shipping System API
```bash
cd ../shipping-system-api/
mvn clean compile
mvn clean package -DskipMunitTests
```

### Step 3: Deploy Process Layer API

#### 3.1 Order Process API
```bash
cd ../../process-layer/order-process-api/
mvn clean compile
mvn clean package -DskipMunitTests
```

**Update Configuration**:
Ensure system API endpoints are correctly configured in properties files.

### Step 4: Deploy Experience Layer API

#### 4.1 Order Experience API
```bash
cd ../../experience-layer/order-experience-api/
mvn clean compile
mvn clean package -DskipMunitTests
```

### Step 5: Security Configuration

#### 5.1 OAuth 2.0 Setup
1. Configure OAuth provider in API Manager
2. Apply OAuth 2.0 policies to all APIs
3. Update client credentials in secure properties

#### 5.2 API Policies
Apply the following policies through API Manager:
- **OAuth 2.0**: Client credentials validation
- **Rate Limiting**: Based on client requirements
- **CORS**: For web applications
- **Request/Response Logging**: For monitoring

### Step 6: Testing and Validation

#### 6.1 Health Checks
Test health endpoints for all APIs:
```bash
# Experience Layer
curl -X GET https://your-domain/api/v2/health

# Process Layer  
curl -X GET https://your-process-domain/api/v2/health

# System Layer
curl -X GET https://your-customer-domain/api/v1/health
```

#### 6.2 End-to-End Testing
Use the provided Postman collection to test complete order flow:
1. Create order via Experience API
2. Verify customer validation
3. Check inventory reservation
4. Confirm payment authorization
5. Validate shipment creation

#### 6.3 Load Testing
Recommended tools:
- **JMeter**: For comprehensive load testing
- **Postman**: For functional testing
- **MuleSoft Functional Testing**: For automated testing

### Step 7: Monitoring and Observability

#### 7.1 Anypoint Monitoring
- Enable custom metrics
- Configure dashboards
- Set up alerting rules

#### 7.2 Business Events
Configure business events for:
- Order creation
- Payment processing
- Shipment tracking
- Error occurrences

#### 7.3 Logging
- Structured logging is pre-configured
- Log aggregation via external tools (Splunk, ELK)
- Error correlation using correlation IDs

## Configuration Reference

### Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `mule.env` | Environment identifier | `dev`, `staging`, `prod` |
| `encryption.key` | Secure properties key | `${secure::encryption.key}` |

### Port Assignments

| API Layer | Default Port | Customizable |
|-----------|--------------|--------------|
| Experience Layer | 8081 | Yes |
| Process Layer | 8082 | Yes |
| Customer System | 8083 | Yes |
| Inventory System | 8084 | Yes |
| Payment System | 8085 | Yes |
| Shipping System | 8086 | Yes |

### Database Configuration

**MySQL Connection Pool Settings**:
```yaml
db:
  connection:
    pool:
      minPoolSize: 5
      maxPoolSize: 20
      acquireIncrement: 1
      maxIdleTime: 1800
```

## Error Handling

### Standard Error Codes

| Code | HTTP Status | Description | Retry |
|------|-------------|-------------|-------|
| `ORDER_NOT_FOUND` | 404 | Order ID not found | No |
| `CUSTOMER_NOT_FOUND` | 404 | Customer ID not found | No |
| `INSUFFICIENT_INVENTORY` | 400 | Not enough stock | No |
| `PAYMENT_FAILED` | 400 | Payment processing failed | Manual |
| `CIRCUIT_BREAKER_OPEN` | 503 | Service temporarily unavailable | Auto |

### Circuit Breaker Configuration

| System | Failure Threshold | Recovery Time | Fallback |
|--------|-------------------|---------------|----------|
| Customer System | 5 failures/60s | 30s | Cached data |
| Inventory System | 3 failures/30s | 60s | Manual verification |
| Payment Gateway | 5 failures/120s | 120s | Queue for retry |
| Shipping System | 3 failures/60s | 90s | Manual shipment |

## Security Best Practices

### API Security
1. **OAuth 2.0**: All APIs require valid tokens
2. **HTTPS Only**: TLS 1.2+ for all communications  
3. **Rate Limiting**: Prevent abuse and DDoS
4. **Input Validation**: RAML-based validation
5. **Data Masking**: PII protection in logs

### Data Protection
- **Encryption at Rest**: Database encryption
- **Encryption in Transit**: HTTPS/TLS
- **PCI Compliance**: Payment data handling
- **Data Retention**: Automated cleanup policies

## Performance Optimization

### Recommended Settings

**CloudHub Deployment**:
- **Production**: 3 workers, 1.0 vCore each
- **Staging**: 2 workers, 0.2 vCore each  
- **Development**: 1 worker, 0.1 vCore each

**Connection Pooling**:
- **HTTP**: 10 connections per endpoint
- **Database**: 20 connections max
- **Timeouts**: 30s connection, 60s read

### Monitoring KPIs
- **API Response Time**: < 3 seconds (95th percentile)
- **Throughput**: 1000+ orders/hour
- **Error Rate**: < 0.1% unrecoverable errors
- **Availability**: 99.9% uptime SLA

## Troubleshooting

### Common Issues

**1. Connection Timeouts**
```
Symptoms: HTTP:TIMEOUT errors
Solution: Increase timeout values in properties
Check: Network connectivity between APIs
```

**2. Circuit Breaker Open**
```
Symptoms: CIRCUIT_BREAKER_OPEN errors  
Solution: Check downstream system health
Check: Error rates in monitoring dashboard
```

**3. Authentication Failures**
```
Symptoms: SECURITY:UNAUTHORIZED errors
Solution: Verify OAuth token validity
Check: Client credentials configuration
```

**4. Database Connection Issues**
```
Symptoms: Database connectivity errors
Solution: Verify connection pool settings
Check: Database server accessibility
```

### Debug Mode
Enable debug logging for troubleshooting:
```yaml
logging:
  level: "DEBUG"
  categories:
    - name: "com.company.integration"
      level: "DEBUG"
```

## Deployment Automation

### CI/CD Pipeline
```yaml
stages:
  - validate
  - test
  - build
  - deploy-dev
  - integration-test
  - deploy-staging
  - deploy-production
```

### Infrastructure as Code
Use provided CloudHub deployment configuration:
- Environment-specific worker sizing
- Auto-scaling policies
- Monitoring configurations
- Security policies

## Support and Maintenance

### Regular Tasks
- **Weekly**: Review error logs and performance metrics
- **Monthly**: Update security patches and dependencies
- **Quarterly**: Performance testing and optimization
- **Annually**: Architecture review and scaling assessment

### Monitoring Checklist
- [ ] API health endpoints responding
- [ ] Error rates within acceptable limits
- [ ] Response times meeting SLA
- [ ] Database connection pool healthy
- [ ] Security policies active
- [ ] Circuit breakers functioning

## Contact Information

For technical support and questions:
- **Email**: integration-support@company.com
- **Slack**: #mulesoft-integration
- **Documentation**: Internal wiki/confluence

---

**Document Version**: 2.0  
**Last Updated**: March 2026  
**Compatibility**: Mule Runtime 4.4+

## Appendix

### Template Structure Summary
```
mulesoft-api-templates/
├── shared-resources/           # Common configurations
├── experience-layer/           # Customer-facing APIs
├── process-layer/             # Business orchestration
├── system-layer/              # Backend integrations
├── deployment/                # Deployment configurations
└── IMPLEMENTATION_GUIDE.md    # This guide
```

### Quick Commands Reference
```bash
# Build all projects