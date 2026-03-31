# Order Management API Error Handling Implementation

## Overview

This document provides comprehensive documentation for the error handling implementation across all Order Management APIs, covering Experience, Process, and System layers.

## Error Handling Strategy

### Design Principles

1. **Consistent Error Response Structure**: All APIs follow RFC 7807 Problem Details standard
2. **Layer-Specific Handling**: Each API layer has tailored error handling for its specific concerns
3. **Comprehensive Coverage**: All standard HTTP error codes (400, 401, 404, 500) are handled
4. **Correlation Tracking**: Every error includes correlation ID for request tracing
5. **Business Context**: Business errors include specific business error codes and context

### Standard Error Response Format

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable error message",
    "description": "Detailed error description",
    "timestamp": "2026-03-31T14:30:45.123Z",
    "correlationId": "550e8400-e29b-41d4-a716-446655440000",
    "details": [
      {
        "field": "fieldName",
        "reason": "Specific reason for error"
      }
    ]
  }
}
```

## HTTP Status Code Coverage

### 400 Bad Request
- **Validation Errors**: Invalid input data format or values
- **APIKit Bad Request**: Malformed request structure
- **Triggers**: VALIDATION:*, APIKIT:BAD_REQUEST

### 401 Unauthorized
- **Authentication Errors**: Missing or invalid credentials
- **Triggers**: HTTP:UNAUTHORIZED, CLIENT_SECURITY

### 403 Forbidden
- **Authorization Errors**: Insufficient permissions
- **Triggers**: HTTP:FORBIDDEN

### 404 Not Found
- **Resource Not Found**: Requested resource doesn't exist
- **Triggers**: APIKIT:NOT_FOUND, HTTP:NOT_FOUND

### 405 Method Not Allowed
- **Method Restriction**: HTTP method not supported for resource
- **Triggers**: APIKIT:METHOD_NOT_ALLOWED

### 409 Conflict
- **Business Logic Errors**: Business rule violations
- **Triggers**: BUSINESS_ERROR, ORDER:DUPLICATE, ORDER:INVALID_STATUS

### 422 Unprocessable Entity
- **Business Validation Errors**: Semantic validation failures
- **Triggers**: BUSINESS:VALIDATION_ERROR, ORDER:CUSTOMER_INVALID

### 429 Too Many Requests
- **Rate Limiting**: API rate limits exceeded
- **Triggers**: HTTP:RETRY_EXHAUSTED, THROTTLING

### 500 Internal Server Error
- **System Failures**: Internal system errors
- **Triggers**: HTTP:INTERNAL_SERVER_ERROR, CONNECTIVITY, TIMEOUT

### 502 Bad Gateway
- **Downstream Service Errors**: External service communication issues
- **Triggers**: HTTP:BAD_REQUEST, HTTP:CLIENT_SECURITY, HTTP:PARSING

### 503 Service Unavailable
- **Service Unavailability**: Temporary service outages
- **Triggers**: HTTP:SERVICE_UNAVAILABLE, REDELIVERY_EXHAUSTED

## Layer-Specific Error Handling

### Experience API Layer (global-error-handler-experience)

**Purpose**: Handle user-facing errors with customer-friendly messages

**Key Features**:
- User-friendly error messages
- Client correlation ID handling
- Support reference generation for customer service
- Rate limiting enforcement

**Error Types Handled**:
- Input validation errors
- Authentication/Authorization errors
- Resource not found
- Business rule violations
- System failures

**Sample Response**:
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "description": "The request contains invalid data",
    "timestamp": "2026-03-31T14:30:45.123Z",
    "correlationId": "550e8400-e29b-41d4-a716-446655440000",
    "details": [
      {
        "field": "customerId",
        "reason": "Customer ID is required"
      }
    ]
  }
}
```

### Process API Layer (global-error-handler-process)

**Purpose**: Handle process orchestration errors with business context

**Key Features**:
- Process step tracking
- Business error code classification
- Rollback requirement indication
- Upstream error aggregation

**Error Types Handled**:
- Process validation errors
- Business process failures
- System integration errors
- Transaction rollback scenarios

**Sample Response**:
```json
{
  "error": {
    "code": "PROCESS_BUSINESS_ERROR",
    "message": "Business process validation failed",
    "description": "Business rule violation in process layer",
    "timestamp": "2026-03-31T14:30:45.123Z",
    "correlationId": "550e8400-e29b-41d4-a716-446655440000",
    "layer": "PROCESS",
    "processStep": "customer-validation",
    "businessErrorCode": "CUSTOMER_INVALID",
    "rollbackRequired": true,
    "details": [
      {
        "businessRule": "CUSTOMER_VALIDATION",
        "reason": "Customer is not active"
      }
    ]
  }
}
```

### System API Layer (global-error-handler-system)

**Purpose**: Handle backend system integration errors

**Key Features**:
- Backend system identification
- Original error code preservation
- Retry capability indication
- Resource context tracking

**Error Types Handled**:
- Backend system validation
- Resource not found in external systems
- Database connectivity issues
- External service timeouts

**Sample Response**:
```json
{
  "error": {
    "code": "BACKEND_SYSTEM_ERROR",
    "message": "Backend system error",
    "description": "Error communicating with backend system",
    "timestamp": "2026-03-31T14:30:45.123Z",
    "correlationId": "550e8400-e29b-41d4-a716-446655440000",
    "layer": "SYSTEM",
    "systemName": "CUSTOMER_DB",
    "systemErrorCode": "CONNECTION_TIMEOUT",
    "systemErrorMessage": "Database connection timeout",
    "retryable": true,
    "details": [
      {
        "system": "CUSTOMER_DB",
        "reason": "Database connection timeout after 30 seconds"
      }
    ]
  }
}
```

## Business Error Types

### Order-Specific Errors

| Error Type | HTTP Code | Description |
|------------|-----------|-------------|
| ORDER:DUPLICATE | 409 | Duplicate order submission |
| ORDER:INVALID_STATUS | 409 | Invalid order status transition |
| ORDER:INSUFFICIENT_INVENTORY | 409 | Not enough inventory for order |
| ORDER:CUSTOMER_INVALID | 422 | Customer validation failed |
| ORDER:PAYMENT_FAILED | 402 | Payment processing failed |

### Validation Errors

| Error Type | HTTP Code | Description |
|------------|-----------|-------------|
| BUSINESS:VALIDATION_ERROR | 422 | General business validation failure |
| VALIDATION:NOT_NULL | 400 | Required field is missing |
| VALIDATION:INVALID_EMAIL | 400 | Invalid email format |
| VALIDATION:INVALID_NUMBER | 400 | Invalid number format |

## Helper Sub-flows

### set-correlation-id
- **Purpose**: Ensures every request has a unique correlation ID for tracking
- **Location**: All API layers
- **Behavior**: Uses existing `x-correlation-id` header or generates new UUID

### set-system-context
- **Purpose**: Sets system context variables for System APIs
- **Variables Set**: `systemName`, `resourceType`, `resourceId`
- **Usage**: Enables context-aware error handling

### validate-required-fields
- **Purpose**: Generic payload validation helper
- **Validation**: Checks for null or empty payloads
- **Error Type**: `BUSINESS:VALIDATION_ERROR`

### check-circuit-breaker
- **Purpose**: Implements circuit breaker pattern for external services
- **States**: `OPEN`, `CLOSED`
- **Error Type**: `CIRCUIT_BREAKER:OPEN`

## Implementation Guidelines

### Error Handler Configuration

Each API must reference the appropriate global error handler:

```xml
<!-- Experience API -->
<error-handler ref="global-error-handler-experience" />

<!-- Process API -->
<error-handler ref="global-error-handler-process" />

<!-- System API -->
<error-handler ref="global-error-handler-system" />
```

### Error Type Conventions

1. **System Errors**: Use standard HTTP connector error types
2. **Business Errors**: Prefix with `BUSINESS:` or domain-specific prefix (e.g., `ORDER:`)
3. **Validation Errors**: Use `VALIDATION:` prefix for input validation
4. **Custom Errors**: Use descriptive prefixes (e.g., `CIRCUIT_BREAKER:`, `THROTTLING:`)

### Context Variables Usage

Set appropriate context variables for enhanced error reporting:

```xml
<!-- Process API -->
<set-variable variableName="currentProcessStep" value="customer-validation" />
<set-variable variableName="rollbackRequired" value="true" />

<!-- System API -->
<set-variable variableName="systemName" value="CUSTOMER_DB" />
<set-variable variableName="resourceType" value="CUSTOMER" />
<set-variable variableName="resourceId" value="#[vars.customerId]" />
```

## Testing Error Scenarios

### Unit Testing

Test each error type with appropriate mock scenarios:

```xml
<!-- Test validation error -->
<munit:test name="test-validation-error" expectedErrorType="BUSINESS:VALIDATION_ERROR">
  <munit:execution>
    <set-payload value='{}' />
    <flow-ref name="create-order-flow" />
  </munit:execution>
</munit:test>

<!-- Test system error -->
<munit:test name="test-system-error" expectedErrorType="HTTP:CONNECTIVITY">
  <munit:execution>
    <munit:mock-when processor="http:request">
      <munit:with-attributes>
        <munit:with-attribute attributeName="config-ref" whereValue="Order_Process_API_Config"/>
      </munit:with-attributes>
      <munit:then-return>
        <munit:error typeId="HTTP:CONNECTIVITY"/>
      </munit:then-return>
    </munit:mock-when>
    <flow-ref name="create-order-flow" />
  </munit:execution>
</munit:test>
```

### Integration Testing

Test error propagation across API layers:

1. **End-to-End Error Flow**: Verify errors propagate correctly from System → Process → Experience APIs
2. **Correlation ID Tracking**: Ensure correlation IDs are preserved across all layers
3. **Error Response Format**: Validate all error responses follow RFC 7807 standard
4. **HTTP Status Codes**: Verify appropriate HTTP status codes are returned

## Monitoring and Alerting

### Log Patterns

Each error handler includes structured logging:

```
[LEVEL] [LAYER] error: [ERROR_DESCRIPTION] - [CONTEXT] - Correlation ID: [CORRELATION_ID]
```

Examples:
```
WARN Experience API Validation error: Customer ID is required - Correlation ID: 550e8400-e29b-41d4-a716-446655440000
ERROR Process API System error: Database connection timeout - Step: customer-validation - Correlation ID: 550e8400-e29b-41d4-a716-446655440000
ERROR System API Backend system error: Connection refused - System: CUSTOMER_DB - Correlation ID: 550e8400-e29b-41d4-a716-446655440000
```

### Alert Thresholds

Set up monitoring alerts for:

- **5xx Errors**: > 5% error rate in 5-minute window
- **4xx Errors**: > 20% error rate in 5-minute window
- **Circuit Breaker**: Any `CIRCUIT_BREAKER:OPEN` events
- **Database Errors**: Any `DB:CONNECTIVITY` or `DB:QUERY_EXECUTION` errors

## Performance Considerations

### Error Handler Performance

1. **Efficient Transformations**: Use DataWeave efficiently in error transformations
2. **Minimal Logging**: Log essential information only to avoid performance impact
3. **Circuit Breaker**: Implement to prevent cascading failures
4. **Timeout Configuration**: Set appropriate timeouts for all external calls

### Resource Management

1. **Connection Pooling**: Configure appropriate connection pools for databases
2. **Memory Management**: Ensure error handlers don't create memory leaks
3. **Thread Safety**: Verify thread safety in shared error handling components

## Compliance and Security

### Data Privacy

1. **Sensitive Data**: Never log sensitive information (passwords, tokens, PII)
2. **Error Masking**: Mask sensitive data in error responses
3. **Correlation IDs**: Use correlation IDs instead of exposing internal identifiers

### Security Headers

Include security headers in error responses:

```xml
<http:headers>
  <http:header headerName="X-Content-Type-Options" value="nosniff" />
  <http:header headerName="X-Frame-Options" value="DENY" />
  <http:header headerName="X-XSS-Protection" value="1; mode=block" />
</http:headers>
```

## Troubleshooting Guide

### Common Issues

1. **Missing Correlation ID**: Check if `set-correlation-id` sub-flow is called
2. **Wrong HTTP Status**: Verify error type mapping in global error handlers
3. **Missing Error Details**: Ensure context variables are set before error occurs
4. **XML Namespace Issues**: Verify all required namespaces are declared

### Debug Tools

1. **Logger Component**: Add temporary loggers to trace error flow
2. **Correlation ID Tracking**: Use correlation ID to trace requests across APIs
3. **Error Handler Testing**: Use MUnit to test specific error scenarios
4. **Network Tracing**: Use tools like Wireshark to debug connectivity issues

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-03-31 | Initial implementation with comprehensive error handling |

## References

- [RFC 7807 - Problem Details for HTTP APIs](https://tools.ietf.org/html/rfc7807)
- [MuleSoft Error Handling Documentation](https://docs.mulesoft.com/mule-runtime/4.4/error-handling)
- [Order Management BRD Section 13](./Integration%20Business%20Requirements%20Document.docx)
- [MuleSoft Best Practices](https://docs.mulesoft.com/mule-runtime/4.4/intro-error-handlers)
