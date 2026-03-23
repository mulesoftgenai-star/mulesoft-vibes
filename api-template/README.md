# MuleSoft Order Management API Templates

This directory contains comprehensive API templates for the Order Management System integration, following MuleSoft's API-Led Connectivity approach with Experience, Process, and System layers.

## 📋 Overview

These templates provide standardized implementations for:
- **Experience Layer**: Customer-facing APIs for order management
- **Process Layer**: Business logic orchestration and workflow management  
- **System Layer**: Direct system integrations (Customer, Inventory, Payment, Shipping)
- **Shared Resources**: Common configurations, security, and utilities

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Experience Layer                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │           Order Experience API                      │   │
│  │  • Customer-facing order operations               │   │
│  │  • Request/response transformation                │   │
│  │  • Rate limiting & caching                       │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                     Process Layer                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │           Order Process API                         │   │
│  │  • Business logic orchestration                   │   │
│  │  • Workflow management                            │   │
│  │  • Event-driven processing                       │   │
│  │  • State management                               │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                     System Layer                           │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌──────────┐ │
│  │  Customer   │ │ Inventory   │ │  Payment    │ │ Shipping │ │
│  │ System API  │ │ System API  │ │ System API  │ │System API│ │
│  │             │ │             │ │             │ │          │ │
│  │• DB Access  │ │• Stock Mgmt │ │• Payment    │ │• Shipping│ │
│  │• CRUD Ops   │ │• Reserv.    │ │  Processing │ │  Labels  │ │
│  └─────────────┘ └─────────────┘ └─────────────┘ └──────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 📁 Directory Structure

```
api-template/
├── shared-resources/           # Common configurations
│   ├── global.xml             # Global Mule configurations
│   ├── config.yaml           # Application properties
│   └── secure-properties.yaml # Encrypted properties
├── experience-layer/          # Customer-facing APIs
│   ├── pom.xml
│   └── src/main/mule/
│       └── order-experience-api.xml
├── process-layer/             # Business logic orchestration
│   ├── pom.xml
│   └── src/main/mule/
│       └── order-process-api.xml
└── system-layer/              # System integrations
    ├── customer/              # Customer management
    │   ├── pom.xml
    │   └── src/main/mule/
    │       └── customer-system-api.xml
    ├── inventory/             # Inventory management
    ├── payment/               # Payment processing
    └── shipping/              # Shipping and fulfillment
```

## 🚀 Quick Start

### Prerequisites

- MuleSoft Anypoint Studio 7.x or later
- Mule Runtime 4.9.4 or later
- Java 8 or 11
- Maven 3.6.x or later

### 1. Using a Template

1. Copy the desired template directory to your project location
2. Update the `pom.xml` with your project details:
   ```xml
   <groupId>com.yourcompany.orderms</groupId>
   <artifactId>your-api-name</artifactId>
   <version>1.0.0</version>
   <name>Your API Name</name>
   ```

3. Update configuration files:
   - `config.yaml`: Environment-specific settings
   - `secure-properties.yaml`: Encrypted credentials

4. Customize the Mule flows for your specific requirements

### 2. Configuration Setup

#### Environment Properties
Update `config.yaml` with your environment settings:

```yaml
http:
  host: "0.0.0.0"
  port: "8081"

database:
  host: "${secure::db.host}"
  port: "${secure::db.port}"
  database: "${secure::db.name}"

systems:
  customer:
    host: "${secure::customer.system.host}"
    basePath: "/api/v1"
    timeout: "30000"
```

#### Secure Properties
Encrypt sensitive values in `secure-properties.yaml`:

```yaml
db:
  host: "ENC(encrypted_db_host)"
  username: "ENC(encrypted_db_username)"
  password: "ENC(encrypted_db_password)"
```

### 3. Build and Deploy

```bash
# Build the project
mvn clean compile

# Package for deployment
mvn clean package

# Deploy to CloudHub (requires Anypoint CLI)
anypoint-cli runtime-mgr cloudhub-application deploy --runtime=4.9.4
```

## 🔧 Template Features

### Experience Layer Template

**Key Features:**
- OAuth 2.0 security integration
- Request/response transformation
- Error handling with proper HTTP status codes
- Correlation ID tracking
- Rate limiting and caching headers
- Integration with Process Layer APIs

**Endpoints:**
- `GET /orders` - List orders with pagination
- `POST /orders` - Create new order
- `GET /orders/{orderId}` - Get order details

**Technologies:**
- APIKit for RAML-based development
- DataWeave for transformations
- HTTP Connector for API calls

### Process Layer Template

**Key Features:**
- Business workflow orchestration
- Multi-step order processing
- State management with Object Store
- Event-driven architecture with Anypoint MQ
- Compensation pattern for rollbacks
- Circuit breaker pattern for resilience

**Workflow Steps:**
1. Customer validation
2. Inventory availability check
3. Payment authorization
4. Order creation in system
5. Fulfillment initiation

**Technologies:**
- Object Store for state management
- Anypoint MQ for event publishing
- Subflows for modular design
- Error handling and recovery

### System Layer Template (Customer)

**Key Features:**
- Direct database connectivity
- CRUD operations for customer data
- Connection pooling optimization
- SQL injection prevention
- Data transformation and validation

**Endpoints:**
- `GET /customers/{customerId}` - Retrieve customer
- `POST /customers` - Create customer
- `PUT /customers/{customerId}` - Update customer

**Technologies:**
- Database Connector with connection pooling
- Prepared statements for security
- DataWeave for data transformation

## 🔒 Security Features

### Authentication & Authorization
- OAuth 2.0 implementation
- JWT token validation
- Role-based access control
- API key authentication

### Data Protection
- TLS 1.3 encryption in transit
- AES-256 encryption at rest
- PII data masking
- Secure properties encryption

### API Security
- Rate limiting policies
- CORS configuration
- Input validation
- SQL injection prevention

## 📊 Monitoring & Observability

### Logging
- Structured JSON logging
- Correlation ID tracking
- Configurable log levels
- Performance metrics

### Monitoring
- Health check endpoints
- Custom business KPIs
- Error rate tracking
- Response time monitoring

### Alerting
- Threshold-based alerts
- Error rate escalation
- Performance degradation detection
- Circuit breaker notifications

## 🧪 Testing

### Unit Testing
```bash
# Run unit tests
mvn test

# Run with coverage
mvn clean test jacoco:report
```

### Integration Testing
```bash
# Run integration tests
mvn verify -P integration-tests
```

### MUnit Testing
Each template includes MUnit test examples:
- Flow testing
- Mock configurations
- Assertion examples
- Error scenario testing

## 📈 Performance Optimization

### Caching Strategy
- API response caching
- Database query result caching
- Object Store configuration
- TTL management

### Connection Pooling
- Database connection pools
- HTTP connection reuse
- Optimal pool sizing
- Connection health checks

### Scalability
- Horizontal scaling support
- Load balancing configuration
- Auto-scaling policies
- Resource optimization

## 🔄 DevOps Integration

### CI/CD Pipeline
```yaml
# Example Jenkins pipeline
pipeline {
  stages {
    stage('Build') {
      steps {
        sh 'mvn clean compile'
      }
    }
    stage('Test') {
      steps {
        sh 'mvn test'
      }
    }
    stage('Deploy') {
      steps {
        sh 'mvn clean package'
        sh 'anypoint-cli runtime-mgr cloudhub-application deploy'
      }
    }
  }
}
```

### Environment Management
- Environment-specific configurations
- Blue-green deployment support
- Canary release strategies
- Rollback procedures

## 📋 Best Practices

### Code Organization
- Modular flow design
- Reusable subflows
- Configuration externalization
- Error handling patterns

### Performance
- Efficient DataWeave transformations
- Optimal batch processing
- Memory management
- Resource cleanup

### Security
- Principle of least privilege
- Input validation
- Secure coding practices
- Regular security audits

## 🐛 Troubleshooting

### Common Issues

1. **Connection Timeouts**
   - Check network connectivity
   - Verify timeout configurations
   - Review circuit breaker settings

2. **Database Connection Errors**
   - Validate connection parameters
   - Check connection pool settings
   - Verify database availability

3. **Authentication Failures**
   - Verify OAuth configuration
   - Check token expiration
   - Validate client credentials

### Debug Mode
Enable detailed logging for troubleshooting:

```yaml
logging:
  level: "DEBUG"
  pattern: "[%d{yyyy-MM-dd HH:mm:ss}] %-5level %logger{36} - %msg%n"
```

## 📚 Additional Resources

### Documentation
- [MuleSoft Documentation](https://docs.mulesoft.com/)
- [API-Led Connectivity](https://www.mulesoft.com/resources/api-led-connectivity)
- [DataWeave Reference](https://docs.mulesoft.com/dataweave/)

### Training
- [MuleSoft Training](https://training.mulesoft.com/)
- [Anypoint Platform Fundamentals](https://training.mulesoft.com/course/anypoint-platform-fundamentals)

### Community
- [MuleSoft Community](https://help.mulesoft.com/)
- [MuleSoft Forums](https://forums.mulesoft.com/)
- [GitHub Examples](https://github.com/mulesoft)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For support and questions:
- Email: integration-support@company.com
- Slack: #mulesoft-integration
- Documentation: [Internal Wiki](link-to-internal-docs)

---

**Last Updated:** March 23, 2026  
**Version:** 1.0.0  
**Maintained by:** Integration Architecture Team