# API Naming Conventions for Order Management System

## Overview
This document defines naming conventions for MuleSoft APIs following the Order Management System integration standards.

## API Naming Standards

### API Titles
- **Format**: `{Business Domain} {Layer} API`
- **Examples**:
  - `Order Experience API`
  - `Customer System API`
  - `Payment Process API`

### Base URI Structure
- **Experience Layer**: `https://api.{environment}.company.com/{domain}/{version}`
- **Process Layer**: `https://process-api.{environment}.company.com/{domain}/{version}`
- **System Layer**: `https://system-api.{environment}.company.com/{domain}/{version}`

### Resource Naming
- Use **plural nouns** for collections: `/orders`, `/customers`, `/payments`
- Use **lowercase with hyphens** for multi-word resources: `/order-items`, `/shipping-addresses`
- Use **descriptive names** that reflect business concepts
- Avoid abbreviations unless they are widely understood

### HTTP Methods
- **GET**: Retrieve resources
- **POST**: Create new resources
- **PUT**: Update entire resource (full replacement)
- **PATCH**: Partial update of resource
- **DELETE**: Remove resource (soft delete preferred)

### Query Parameters
- Use **camelCase** for parameter names: `customerId`, `orderDate`, `pageSize`
- Use consistent parameter names across APIs:
  - `page` - Page number (1-based)
  - `limit` or `size` - Items per page
  - `sort` - Sort criteria
  - `filter` - Filter expression
  - `q` - Search query

### Headers
- Use **X-** prefix for custom headers: `X-Request-ID`, `X-Correlation-ID`
- Use consistent header names across all APIs
- Standard headers:
  - `X-Request-ID` - Unique request identifier
  - `X-Correlation-ID` - Request correlation for tracing
  - `X-Client-ID` - Client application identifier
  - `Authorization` - OAuth 2.0 Bearer token

### Response Fields
- Use **camelCase** for JSON field names: `orderId`, `customerId`, `totalAmount`
- Use consistent field names across APIs:
  - `id` - Primary identifier
  - `createdAt` - Creation timestamp
  - `updatedAt` - Last modification timestamp
  - `version` - Resource version for optimistic locking

### Error Codes
- Use **UPPER_CASE_WITH_UNDERSCORES** for error codes: `VALIDATION_ERROR`, `RESOURCE_NOT_FOUND`
- Follow hierarchy pattern:
  - `{CATEGORY}_{SPECIFIC_ERROR}`: `ORDER_NOT_FOUND`, `PAYMENT_FAILED`
  - Use HTTP status code as prefix: `400_VALIDATION_ERROR`, `404_ORDER_NOT_FOUND`

## Data Type Naming

### Primitive Types
- Use appropriate RAML data types: `string`, `integer`, `number`, `boolean`, `datetime`
- Use patterns for validation: `^[A-Z]{3}$` for currency codes
- Use enums for fixed value sets: `[PENDING, CONFIRMED, CANCELLED]`

### Object Types
- Use **PascalCase** for type names: `Order`, `Customer`, `PaymentDetails`
- Use descriptive names: `ShippingAddress`, `OrderItem`, `PaymentMethod`
- Suffix with purpose when needed: `CreateOrderRequest`, `OrderResponse`

### Collection Types
- Use plural forms: `Orders`, `Customers`, `PaymentMethods`
- Use descriptive collection names: `OrderItems`, `ShippingOptions`

## Versioning Strategy

### API Versions
- Use **semantic versioning**: `v1.0`, `v1.1`, `v2.0`
- Include version in base URI: `/api/v1/orders`
- Support multiple versions simultaneously
- Deprecate versions gracefully with advance notice

### Backward Compatibility
- Additive changes are allowed in minor versions
- Breaking changes require major version increment
- Maintain backward compatibility for at least 2 major versions

## Environment Naming
- **dev** - Development environment
- **test** - Testing environment  
- **staging** - Staging/UAT environment
- **prod** - Production environment

## Examples

### Good Naming Examples
```yaml
# Resource naming
GET /api/v1/orders
POST /api/v1/orders
GET /api/v1/orders/{orderId}
PUT /api/v1/orders/{orderId}
DELETE /api/v1/orders/{orderId}

# Query parameters
GET /api/v1/orders?customerId=CUST-123&status=PENDING&page=1&limit=20

# Headers
X-Request-ID: req-12345-67890-abcdef
X-Correlation-ID: corr-98765-43210-fedcba
X-Client-ID: mobile-app-v1.2.3

# Response fields
{
  "orderId": "ORD-20240115-001",
  "customerId": "CUST-12345",
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z",
  "version": 1
}
```

### Bad Naming Examples
```yaml
# Avoid these patterns
GET /api/v1/order        # Should be plural
GET /api/v1/getOrders    # Don't include HTTP method in path
GET /api/v1/orders?customerid=123  # Should be camelCase

# Headers
Request-ID: 123          # Should use X- prefix
custom-header: value     # Should be X-Custom-Header

# Response fields
{
  "order_id": "123",     # Should be camelCase
  "created_date": "...", # Should be createdAt
  "cust_id": "456"       # Avoid abbreviations
}
```

## Validation Rules

### Required Validations
1. **API Title** matches pattern: `{Domain} {Layer} API`
2. **Base URI** follows layer-specific pattern
3. **Resources** use plural nouns in lowercase
4. **Parameters** use camelCase naming
5. **Headers** use X- prefix for custom headers
6. **Error codes** use UPPER_CASE_WITH_UNDERSCORES
7. **Types** use PascalCase naming
8. **Fields** use camelCase in JSON responses

### Recommended Tools
- RAML linting tools for validation
- API design review checklist
- Automated naming convention checks in CI/CD pipeline

This naming convention ensures consistency, readability, and maintainability across all Order Management System APIs.