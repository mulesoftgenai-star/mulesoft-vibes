# Error Handling Standards for Order Management System APIs

## Overview
This document defines standardized error handling practices for all MuleSoft APIs in the Order Management System integration.

## Error Response Structure

### Standard Error Format
All APIs must use the following standardized error response structure:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": "Detailed error description",
    "timestamp": "2024-01-15T10:30:00Z",
    "traceId": "abc123-def456-ghi789",
    "path": "/api/v1/orders",
    "method": "POST",
    "statusCode": 400,
    "validationErrors": [...],
    "context": {...},
    "retryable": false,
    "retryAfter": 60,
    "helpUrl": "https://docs.api.company.com/errors/ERROR_CODE"
  }
}
```

### Required Fields
- **code**: Machine-readable error identifier (UPPER_CASE_WITH_UNDERSCORES)
- **message**: Human-readable error summary
- **timestamp**: ISO 8601 timestamp when error occurred
- **traceId**: Unique identifier for debugging and correlation

### Optional Fields
- **details**: Additional error information
- **path**: API endpoint where error occurred
- **method**: HTTP method used
- **statusCode**: HTTP status code
- **validationErrors**: Array of field-specific validation errors
- **context**: Additional context information
- **retryable**: Boolean indicating if operation can be retried
- **retryAfter**: Seconds to wait before retry (for retryable errors)
- **helpUrl**: Link to error documentation

## HTTP Status Codes

### 4xx Client Errors

#### 400 Bad Request
- **Usage**: Malformed request, invalid syntax, missing required fields
- **Error Codes**: `BAD_REQUEST`, `INVALID_REQUEST_FORMAT`, `MISSING_REQUIRED_FIELD`
- **Retryable**: No
- **Example**:
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": "One or more fields contain invalid data",
    "timestamp": "2024-01-15T10:30:00Z",
    "traceId": "abc123-def456-ghi789",
    "path": "/api/v1/orders",
    "method": "POST",
    "statusCode": 400,
    "validationErrors": [
      {
        "field": "customerId",
        "message": "This field is required",
        "code": "REQUIRED_FIELD_MISSING"
      }
    ],
    "retryable": false
  }
}
```

#### 401 Unauthorized
- **Usage**: Authentication required, invalid/expired token
- **Error Codes**: `UNAUTHORIZED`, `INVALID_TOKEN`, `EXPIRED_TOKEN`
- **Retryable**: No (unless token can be refreshed)
- **Headers**: Include `WWW-Authenticate` header
- **Example**:
```json
{
  "error": {
    "code": "INVALID_TOKEN",
    "message": "The provided access token is invalid",
    "details": "Token signature verification failed",
    "timestamp": "2024-01-15T10:30:00Z",
    "traceId": "def456-ghi789-jkl012",
    "path": "/api/v1/orders",
    "statusCode": 401,
    "retryable": false,
    "helpUrl": "https://docs.api.company.com/authentication"
  }
}
```

#### 403 Forbidden
- **Usage**: Valid authentication but insufficient permissions
- **Error Codes**: `FORBIDDEN`, `INSUFFICIENT_SCOPE`, `ACCESS_DENIED`
- **Retryable**: No
- **Example**:
```json
{
  "error": {
    "code": "INSUFFICIENT_SCOPE",
    "message": "Insufficient permissions for this operation",
    "details": "Required scope: orders:write, Available: orders:read",
    "timestamp": "2024-01-15T10:30:00Z",
    "traceId": "ghi789-jkl012-mno345",
    "path": "/api/v1/orders",
    "statusCode": 403,
    "context": {
      "userId": "user-123",
      "requiredScopes": ["orders:write"],
      "availableScopes": ["orders:read"]
    },
    "retryable": false
  }
}
```

#### 404 Not Found
- **Usage**: Requested resource does not exist
- **Error Codes**: `RESOURCE_NOT_FOUND`, `ORDER_NOT_FOUND`, `CUSTOMER_NOT_FOUND`
- **Retryable**: No
- **Example**:
```json
{
  "error": {
    "code": "ORDER_NOT_FOUND",
    "message": "Order not found",
    "details": "Order with ID 'ORD-999999' does not exist",
    "timestamp": "2024-01-15T10:30:00Z",
    "traceId": "jkl012-mno345-pqr678",
    "path": "/api/v1/orders/ORD-999999",
    "statusCode": 404,
    "retryable": false
  }
}
```

#### 409 Conflict
- **Usage**: Request conflicts with current resource state
- **Error Codes**: `RESOURCE_CONFLICT`, `VERSION_MISMATCH`, `DUPLICATE_RESOURCE`
- **Retryable**: Sometimes (after resolving conflict)
- **Example**:
```json
{
  "error": {
    "code": "ORDER_ALREADY_CANCELLED",
    "message": "Order cannot be modified",
    "details": "Order is already in CANCELLED status",
    "timestamp": "2024-01-15T10:30:00Z",
    "traceId": "mno345-pqr678-stu901",
    "path": "/api/v1/orders/ORD-12345",
    "statusCode": 409,
    "context": {
      "orderId": "ORD-12345",
      "currentStatus": "CANCELLED",
      "requestedAction": "UPDATE"
    },
    "retryable": false
  }
}
```

#### 422 Unprocessable Entity
- **Usage**: Well-formed request but semantic errors
- **Error Codes**: `BUSINESS_RULE_VIOLATION`, `INVALID_STATE_TRANSITION`
- **Retryable**: No (requires data correction)
- **Example**:
```json
{
  "error": {
    "code": "INSUFFICIENT_INVENTORY",
    "message": "Business validation failed",
    "details": "Insufficient inventory for requested quantity",
    "timestamp": "2024-01-15T10:30:00Z",
    "traceId": "pqr678-stu901-vwx234",
    "path": "/api/v1/orders",
    "statusCode": 422,
    "context": {
      "productId": "PROD-123",
      "requestedQuantity": 10,
      "availableQuantity": 5
    },
    "retryable": false
  }
}
```

#### 429 Too Many Requests
- **Usage**: Rate limit exceeded
- **Error Codes**: `RATE_LIMIT_EXCEEDED`, `QUOTA_EXCEEDED`
- **Retryable**: Yes (after waiting)
- **Headers**: Include `Retry-After` header
- **Example**:
```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Rate limit exceeded",
    "details": "Too many requests in the given time frame",
    "timestamp": "2024-01-15T10:30:00Z",
    "traceId": "stu901-vwx234-yza567",
    "path": "/api/v1/orders",
    "statusCode": 429,
    "context": {
      "limit": 1000,
      "window": 3600,
      "current": 1001
    },
    "retryable": true,
    "retryAfter": 60
  }
}
```

### 5xx Server Errors

#### 500 Internal Server Error
- **Usage**: Unexpected server error
- **Error Codes**: `INTERNAL_SERVER_ERROR`, `SYSTEM_ERROR`
- **Retryable**: Yes (with exponential backoff)
- **Example**:
```json
{
  "error": {
    "code": "DATABASE_CONNECTION_ERROR",
    "message": "Internal server error",
    "details": "Database connection timeout",
    "timestamp": "2024-01-15T10:30:00Z",
    "traceId": "vwx234-yza567-bcd890",
    "path": "/api/v1/orders",
    "statusCode": 500,
    "retryable": true,
    "retryAfter": 30
  }
}
```

#### 502 Bad Gateway
- **Usage**: Invalid response from upstream server
- **Error Codes**: `BAD_GATEWAY`, `UPSTREAM_ERROR`
- **Retryable**: Yes
- **Example**:
```json
{
  "error": {
    "code": "UPSTREAM_SERVICE_ERROR",
    "message": "Bad gateway",
    "details": "Invalid response from inventory service",
    "timestamp": "2024-01-15T10:30:00Z",
    "traceId": "yza567-bcd890-efg123",
    "path": "/api/v1/orders",
    "statusCode": 502,
    "context": {
      "upstreamService": "inventory-service",
      "upstreamError": "Connection refused"
    },
    "retryable": true,
    "retryAfter": 10
  }
}
```

#### 503 Service Unavailable
- **Usage**: Service temporarily unavailable
- **Error Codes**: `SERVICE_UNAVAILABLE`, `MAINTENANCE_MODE`
- **Retryable**: Yes (after waiting)
- **Headers**: Include `Retry-After` header
- **Example**:
```json
{
  "error": {
    "code": "SERVICE_UNAVAILABLE",
    "message": "Service temporarily unavailable",
    "details": "System maintenance in progress",
    "timestamp": "2024-01-15T10:30:00Z",
    "traceId": "bcd890-efg123-hij456",
    "path": "/api/v1/orders",
    "statusCode": 503,
    "retryable": true,
    "retryAfter": 300
  }
}
```

#### 504 Gateway Timeout
- **Usage**: Timeout waiting for upstream server
- **Error Codes**: `GATEWAY_TIMEOUT`, `UPSTREAM_TIMEOUT`
- **Retryable**: Yes
- **Example**:
```json
{
  "error": {
    "code": "PAYMENT_SERVICE_TIMEOUT",
    "message": "Gateway timeout",
    "details": "Timeout while waiting for payment service",
    "timestamp": "2024-01-15T10:30:00Z",
    "traceId": "efg123-hij456-klm789",
    "path": "/api/v1/orders",
    "statusCode": 504,
    "context": {
      "upstreamService": "payment-service",
      "timeoutDuration": "30s"
    },
    "retryable": true,
    "retryAfter": 30
  }
}
```

## Error Code Categories

### System Errors (SYS_xxx)
- `SYS_DATABASE_ERROR` - Database operation failed
- `SYS_NETWORK_ERROR` - Network communication error
- `SYS_TIMEOUT_ERROR` - Operation timeout
- `SYS_CONFIGURATION_ERROR` - System configuration issue

### Validation Errors (VAL_xxx)
- `VAL_REQUIRED_FIELD` - Required field missing
- `VAL_INVALID_FORMAT` - Field format validation failed
- `VAL_INVALID_VALUE` - Field value validation failed
- `VAL_CONSTRAINT_VIOLATION` - Business constraint violated

### Business Errors (BUS_xxx)
- `BUS_RULE_VIOLATION` - Business rule validation failed
- `BUS_STATE_INVALID` - Invalid business state
- `BUS_OPERATION_NOT_ALLOWED` - Operation not permitted
- `BUS_RESOURCE_LOCKED` - Resource is locked

### Integration Errors (INT_xxx)
- `INT_UPSTREAM_ERROR` - Upstream service error
- `INT_DOWNSTREAM_ERROR` - Downstream service error
- `INT_TRANSFORMATION_ERROR` - Data transformation failed
- `INT_MAPPING_ERROR` - Field mapping error

## Retry Strategy

### Retry Decision Matrix
| Error Type | HTTP Status | Retryable | Strategy |
|------------|-------------|-----------|----------|
| Client Errors | 4xx | No | Fix request and retry |
| Rate Limiting | 429 | Yes | Wait and retry with backoff |
| Server Errors | 5xx | Yes | Exponential backoff |
| Network Errors | - | Yes | Exponential backoff |
| Timeouts | 504 | Yes | Linear backoff |

### Retry Configuration
```yaml
retryPolicy:
  maxAttempts: 3
  initialDelay: 1000ms
  maxDelay: 30000ms
  backoffMultiplier: 2.0
  retryableErrors:
    - 500
    - 502
    - 503
    - 504
    - CONNECTION_TIMEOUT
    - NETWORK_ERROR
```

## Error Logging

### Log Level Guidelines
- **ERROR**: All 5xx errors and critical business errors
- **WARN**: 4xx errors except 401/403, business rule violations
- **INFO**: Successful requests, normal business flows
- **DEBUG**: Detailed request/response data

### Required Log Fields
```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "level": "ERROR",
  "traceId": "abc123-def456-ghi789",
  "correlationId": "corr-123-456",
  "service": "order-experience-api",
  "operation": "createOrder",
  "userId": "user-12345",
  "errorCode": "VALIDATION_ERROR",
  "statusCode": 400,
  "duration": 1250,
  "message": "Order validation failed",
  "stackTrace": "...",
  "context": {
    "customerId": "CUST-123",
    "orderId": null
  }
}
```

## Best Practices

### Error Response Design
1. **Consistency**: Use standardized error response format
2. **Clarity**: Provide clear, actionable error messages
3. **Correlation**: Include trace IDs for debugging
4. **Context**: Add relevant context information
5. **Documentation**: Link to error documentation

### Error Handling Implementation
1. **Validation**: Validate inputs early and thoroughly
2. **Graceful Degradation**: Handle partial failures gracefully
3. **Circuit Breakers**: Implement circuit breakers for external calls
4. **Timeout Management**: Set appropriate timeouts
5. **Monitoring**: Monitor error rates and patterns

### Client Guidelines
1. **Parse Errors**: Parse error responses properly
2. **Handle Retries**: Implement retry logic for retryable errors
3. **Log Trace IDs**: Log trace IDs for support requests
4. **Display Messages**: Show user-friendly error messages
5. **Fallback**: Implement fallback mechanisms

This error handling standard ensures consistent, predictable error responses across all Order Management System APIs, enabling better debugging, monitoring, and client error handling.
