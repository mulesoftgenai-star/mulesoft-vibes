# API Interface Specifications

## Overview

This document provides detailed API interface specifications for all APIs in the Order Management System integration, including request/response schemas, error handling, and interface contracts.

## API Standards & Conventions

### REST API Design Principles
- **Resource-based URLs**: `/api/orders/{orderId}`
- **HTTP methods**: GET (retrieve), POST (create), PUT (replace), PATCH (update), DELETE (remove)
- **Status codes**: Standard HTTP status codes (200, 201, 400, 404, 500, etc.)
- **Content-Type**: `application/json` for request/response bodies
- **Versioning**: URL versioning (`/api/v1/orders`) or header versioning

### Common Headers

| Header | Required | Description | Example |
|--------|----------|-------------|---------|
| Authorization | Yes | OAuth 2.0 Bearer token | `Bearer eyJ0eXAiOiJKV1QiLCJhbGc...` |
| Content-Type | Yes | Request content type | `application/json` |
| Accept | No | Acceptable response types | `application/json` |
| X-Request-ID | No | Unique request identifier | `req-12345-67890` |
| X-Correlation-ID | No | Correlation for tracing | `corr-abcde-fghij` |

### Standard Error Response Format

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": "Invalid customer ID format",
    "timestamp": "2026-03-23T13:00:00Z",
    "requestId": "req-12345-67890"
  }
}
```

## 1. Order Experience API

### Base URL
```
https://api.orderms.com/experience/v1
```

### Endpoints

#### 1.1 Create Order
```http
POST /orders
```

**Request Schema:**
```json
{
  "customerId": "string (required)",
  "items": [
    {
      "productId": "string (required)",
      "quantity": "integer (required, min: 1)",
      "unitPrice": "number (required, >= 0)"
    }
  ],
  "shippingAddress": {
    "street": "string (required)",
    "city": "string (required)",
    "state": "string (required)",
    "zipCode": "string (required)",
    "country": "string (required)"
  },
  "billingAddress": {
    "street": "string (optional)",
    "city": "string (optional)",
    "state": "string (optional)",
    "zipCode": "string (optional)",
    "country": "string (optional)"
  },
  "paymentMethod": {
    "type": "CREDIT_CARD | PAYPAL | ACH (required)",
    "token": "string (required)"
  },
  "preferences": {
    "expeditedShipping": "boolean (optional)",
    "giftWrap": "boolean (optional)",
    "specialInstructions": "string (optional)"
  }
}
```

**Response Schema (201 Created):**
```json
{
  "orderId": "ORD-2026-001234",
  "status": "CREATED",
  "totalAmount": 159.98,
  "estimatedDelivery": "2026-03-28T00:00:00Z",
  "trackingNumber": "TRK-ABC123DEF456",
  "items": [
    {
      "productId": "P001",
      "quantity": 2,
      "unitPrice": 29.99,
      "lineTotal": 59.98
    }
  ],
  "charges": {
    "subtotal": 59.98,
    "tax": 4.80,
    "shipping": 9.99,
    "total": 74.77
  },
  "timestamps": {
    "created": "2026-03-23T13:00:00Z",
    "lastUpdated": "2026-03-23T13:00:00Z"
  }
}
```

#### 1.2 Get Order Details
```http
GET /orders/{orderId}
```

**Path Parameters:**
- `orderId`: Order identifier (string, required)

**Query Parameters:**
- `includeItems`: Include item details (boolean, default: true)
- `includeHistory`: Include status history (boolean, default: false)

**Response Schema (200 OK):**
```json
{
  "orderId": "ORD-2026-001234",
  "customerId": "CUST-12345",
  "status": "SHIPPED",
  "orderDate": "2026-03-23T13:00:00Z",
  "totalAmount": 74.77,
  "items": [
    {
      "productId": "P001",
      "productName": "Premium Widget",
      "quantity": 2,
      "unitPrice": 29.99,
      "lineTotal": 59.98
    }
  ],
  "shipping": {
    "method": "STANDARD",
    "carrier": "FedEx",
    "trackingNumber": "TRK-ABC123DEF456",
    "estimatedDelivery": "2026-03-28T00:00:00Z",
    "address": {
      "street": "123 Main St",
      "city": "Anytown",
      "state": "CA",
      "zipCode": "12345",
      "country": "US"
    }
  },
  "payment": {
    "method": "CREDIT_CARD",
    "status": "AUTHORIZED",
    "last4": "1234",
    "amount": 74.77
  },
  "statusHistory": [
    {
      "status": "CREATED",
      "timestamp": "2026-03-23T13:00:00Z",
      "notes": "Order created successfully"
    },
    {
      "status": "CONFIRMED",
      "timestamp": "2026-03-23T13:05:00Z",
      "notes": "Payment authorized and inventory reserved"
    },
    {
      "status": "SHIPPED",
      "timestamp": "2026-03-24T10:30:00Z",
      "notes": "Package dispatched via FedEx"
    }
  ]
}
```

#### 1.3 List Orders
```http
GET /orders
```

**Query Parameters:**
- `customerId`: Filter by customer (string, optional)
- `status`: Filter by status (string, optional)
- `dateFrom`: Start date (ISO 8601, optional)
- `dateTo`: End date (ISO 8601, optional)
- `page`: Page number (integer, default: 1)
- `limit`: Items per page (integer, default: 20, max: 100)

**Response Schema (200 OK):**
```json
{
  "orders": [
    {
      "orderId": "ORD-2026-001234",
      "customerId": "CUST-12345",
      "status": "SHIPPED",
      "orderDate": "2026-03-23T13:00:00Z",
      "totalAmount": 74.77,
      "itemCount": 1
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "totalPages": 5,
    "totalItems": 87,
    "hasNext": true,
    "hasPrevious": false
  }
}
```

#### 1.4 Update Order Status
```http
PATCH /orders/{orderId}/status
```

**Request Schema:**
```json
{
  "status": "CANCELLED | RETURNED | DELIVERED (required)",
  "reason": "string (optional)",
  "notes": "string (optional)"
}
```

**Response Schema (200 OK):**
```json
{
  "orderId": "ORD-2026-001234",
  "status": "CANCELLED",
  "updatedAt": "2026-03-23T14:30:00Z",
  "reason": "Customer request",
  "notes": "Cancelled per customer phone request"
}
```

## 2. Customer Experience API

### Base URL
```
https://api.orderms.com/experience/v1
```

#### 2.1 Get Customer Profile
```http
GET /customers/{customerId}
```

**Response Schema (200 OK):**
```json
{
  "customerId": "CUST-12345",
  "profile": {
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@example.com",
    "phone": "+1-555-123-4567",
    "dateOfBirth": "1985-06-15",
    "membershipLevel": "GOLD"
  },
  "addresses": [
    {
      "id": "ADDR-001",
      "type": "SHIPPING",
      "isDefault": true,
      "street": "123 Main St",
      "city": "Anytown",
      "state": "CA",
      "zipCode": "12345",
      "country": "US"
    }
  ],
  "preferences": {
    "emailNotifications": true,
    "smsNotifications": false,
    "language": "en-US",
    "currency": "USD"
  },
  "orderSummary": {
    "totalOrders": 23,
    "totalSpent": 1247.85,
    "averageOrderValue": 54.25,
    "lastOrderDate": "2026-03-20T00:00:00Z"
  }
}
```

## 3. Order Processing API (Process Layer)

### Base URL
```
https://api.orderms.com/process/v1
```

#### 3.1 Process Order Workflow
```http
POST /order-workflow
```

**Request Schema:**
```json
{
  "orderRequest": {
    "customerId": "string",
    "items": [/* order items */],
    "shippingAddress": {/* address */},
    "paymentMethod": {/* payment */}
  },
  "workflow": {
    "type": "STANDARD | EXPEDITED | B2B",
    "validationRules": [
      "CUSTOMER_VALIDATION",
      "INVENTORY_CHECK",
      "PAYMENT_AUTHORIZATION"
    ],
    "notificationPreferences": {
      "email": true,
      "sms": false,
      "push": true
    }
  }
}
```

**Response Schema (202 Accepted):**
```json
{
  "workflowId": "WF-2026-001234",
  "status": "PROCESSING",
  "steps": [
    {
      "name": "CUSTOMER_VALIDATION",
      "status": "COMPLETED",
      "completedAt": "2026-03-23T13:00:15Z"
    },
    {
      "name": "INVENTORY_CHECK",
      "status": "IN_PROGRESS",
      "startedAt": "2026-03-23T13:00:20Z"
    },
    {
      "name": "PAYMENT_AUTHORIZATION",
      "status": "PENDING"
    }
  ],
  "estimatedCompletion": "2026-03-23T13:02:00Z"
}
```

## 4. System Layer APIs

### 4.1 OMS System API

#### Base URL
```
https://api.orderms.com/system/oms/v1
```

#### Create Order in OMS
```http
POST /orders
```

**Request Schema:**
```json
{
  "externalOrderId": "ORD-2026-001234",
  "customerId": "CUST-12345",
  "orderData": {
    "items": [
      {
        "sku": "SKU-P001",
        "quantity": 2,
        "unitPrice": 29.99,
        "lineTotal": 59.98
      }
    ],
    "totals": {
      "subtotal": 59.98,
      "tax": 4.80,
      "shipping": 9.99,
      "total": 74.77
    },
    "addresses": {/* shipping/billing addresses */},
    "payment": {/* payment details */}
  },
  "metadata": {
    "source": "WEB",
    "channel": "ONLINE",
    "campaignCode": "SPRING2026"
  }
}
```

**Response Schema (201 Created):**
```json
{
  "omsOrderId": "OMS-789012",
  "externalOrderId": "ORD-2026-001234",
  "status": "CREATED",
  "createdAt": "2026-03-23T13:01:00Z",
  "fulfillmentDetails": {
    "warehouseId": "WH-EAST-01",
    "expectedShipDate": "2026-03-24T00:00:00Z",
    "shippingMethod": "STANDARD"
  }
}
```

### 4.2 Customer System API

#### Base URL
```
https://api.orderms.com/system/customer/v1
```

#### Validate Customer
```http
GET /customers/{customerId}/validate
```

**Response Schema (200 OK):**
```json
{
  "customerId": "CUST-12345",
  "isValid": true,
  "status": "ACTIVE",
  "creditLimit": 5000.00,
  "availableCredit": 3456.78,
  "riskScore": "LOW",
  "validationResults": {
    "identityVerified": true,
    "addressVerified": true,
    "paymentMethodValid": true
  },
  "restrictions": []
}
```

### 4.3 Inventory System API

#### Base URL
```
https://api.orderms.com/system/inventory/v1
```

#### Check Inventory Availability
```http
POST /availability/check
```

**Request Schema:**
```json
{
  "items": [
    {
      "productId": "P001",
      "quantity": 2,
      "reservationTTL": 900
    }
  ],
  "locationPreferences": ["WH-EAST-01", "WH-WEST-01"],
  "fulfillmentType": "STANDARD | EXPEDITED | SAME_DAY"
}
```

**Response Schema (200 OK):**
```json
{
  "results": [
    {
      "productId": "P001",
      "requestedQuantity": 2,
      "availableQuantity": 150,
      "reservationId": "RES-ABC123",
      "reservationExpiry": "2026-03-23T13:15:00Z",
      "fulfillmentOptions": [
        {
          "locationId": "WH-EAST-01",
          "availableQuantity": 75,
          "estimatedShipDate": "2026-03-24T00:00:00Z"
        },
        {
          "locationId": "WH-WEST-01",
          "availableQuantity": 75,
          "estimatedShipDate": "2026-03-25T00:00:00Z"
        }
      ]
    }
  ],
  "overallStatus": "AVAILABLE | PARTIAL | UNAVAILABLE"
}
```

### 4.4 Payment System API

#### Base URL
```
https://api.orderms.com/system/payment/v1
```

#### Authorize Payment
```http
POST /authorize
```

**Request Schema:**
```json
{
  "orderId": "ORD-2026-001234",
  "amount": 74.77,
  "currency": "USD",
  "paymentMethod": {
    "type": "CREDIT_CARD",
    "token": "tok_1234567890",
    "billingAddress": {/* address */}
  },
  "customerId": "CUST-12345",
  "merchantId": "MERCH-001"
}
```

**Response Schema (200 OK):**
```json
{
  "authorizationId": "AUTH-987654321",
  "status": "AUTHORIZED | DECLINED | ERROR",
  "amount": 74.77,
  "currency": "USD",
  "gatewayResponse": {
    "transactionId": "TXN-GW-123456",
    "approvalCode": "ABC123",
    "avsResult": "Y",
    "cvvResult": "M"
  },
  "riskAssessment": {
    "score": 25,
    "level": "LOW",
    "factors": ["address_match", "cvv_match"]
  },
  "expiresAt": "2026-03-30T13:01:00Z"
}
```

### 4.5 Shipping System API

#### Base URL
```
https://api.orderms.com/system/shipping/v1
```

#### Create Shipment
```http
POST /shipments
```

**Request Schema:**
```json
{
  "orderId": "ORD-2026-001234",
  "items": [
    {
      "productId": "P001",
      "quantity": 2,
      "weight": 1.5,
      "dimensions": {
        "length": 10,
        "width": 8,
        "height": 6,
        "unit": "INCHES"
      }
    }
  ],
  "origin": {
    "warehouseId": "WH-EAST-01",
    "address": {/* warehouse address */}
  },
  "destination": {
    "address": {/* shipping address */}
  },
  "preferences": {
    "carrier": "FEDEX | UPS | DHL | USPS",
    "serviceLevel": "STANDARD | EXPEDITED | OVERNIGHT",
    "signatureRequired": false,
    "insuranceAmount": 100.00
  }
}
```

**Response Schema (201 Created):**
```json
{
  "shipmentId": "SHIP-456789",
  "orderId": "ORD-2026-001234",
  "trackingNumber": "TRK-ABC123DEF456",
  "carrier": "FEDEX",
  "serviceLevel": "STANDARD",
  "estimatedDelivery": "2026-03-28T00:00:00Z",
  "shippingLabel": {
    "url": "https://labels.shipping.com/label/456789.pdf",
    "format": "PDF"
  },
  "cost": {
    "amount": 9.99,
    "currency": "USD"
  },
  "status": "CREATED"
}
```

## Error Handling Specifications

### HTTP Status Codes

| Status Code | Description | Usage |
|-------------|-------------|--------|
| 200 | OK | Successful GET, PATCH requests |
| 201 | Created | Successful POST requests creating resources |
| 202 | Accepted | Async operations accepted for processing |
| 400 | Bad Request | Invalid request syntax or validation errors |
| 401 | Unauthorized | Missing or invalid authentication |
| 403 | Forbidden | Valid auth but insufficient permissions |
| 404 | Not Found | Requested resource does not exist |
| 409 | Conflict | Resource conflict (duplicate, state mismatch) |
| 422 | Unprocessable Entity | Valid syntax but business rule violation |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Unexpected server error |
| 502 | Bad Gateway | Upstream service error |
| 503 | Service Unavailable | Service temporarily unavailable |

### Error Response Schema

```json
{
  "error": {
    "code": "string (required)",
    "message": "string (required)",
    "details": "string (optional)",
    "field": "string (optional, for validation errors)",
    "timestamp": "string (ISO 8601, required)",
    "requestId": "string (required)",
    "moreInfo": "string (optional, documentation URL)"
  },
  "validationErrors": [
    {
      "field": "items[0].quantity",
      "code": "MIN_VALUE",
      "message": "Quantity must be at least 1"
    }
  ]
}
```

### Standard Error Codes

| Error Code | HTTP Status | Description |
|------------|-------------|-------------|
| VALIDATION_ERROR | 400 | Request validation failed |
| AUTHENTICATION_REQUIRED | 401 | Valid authentication required |
| AUTHORIZATION_FAILED | 403 | Insufficient permissions |
| RESOURCE_NOT_FOUND | 404 | Resource does not exist |
| DUPLICATE_RESOURCE | 409 | Resource already exists |
| BUSINESS_RULE_VIOLATION | 422 | Business rule validation failed |
| RATE_LIMIT_EXCEEDED | 429 | Too many requests |
| SERVICE_UNAVAILABLE | 503 | Service temporarily down |
| UPSTREAM_SERVICE_ERROR | 502 | Backend service error |

## Security Specifications

### Authentication & Authorization

#### OAuth 2.0 Flow
1. **Client Credentials Grant**: For server-to-server communication
2. **Authorization Code Grant**: For user-facing applications
3. **JWT Token Format**: RS256 signed tokens with claims

#### Required Claims in JWT
```json
{
  "sub": "user-id-or-client-id",
  "iss": "https://auth.orderms.com",
  "aud": "order-management-api",
  "exp": 1640995200,
  "iat": 1640991600,
  "scope": ["orders:read", "orders:write", "customers:read"],
  "client_id": "client-app-123",
  "user_id": "user-456" // for user context
}
```

#### API Scopes

| Scope | Description | Permissions |
|-------|-------------|-------------|
| orders:read | Read order data | GET /orders, GET /orders/{id} |
| orders:write | Create/modify orders | POST /orders, PATCH /orders/{id} |
| orders:delete | Cancel/delete orders | DELETE /orders/{id} |
| customers:read | Read customer data | GET /customers/{id} |
| customers:write | Modify customer data | PUT /customers/{id} |
| inventory:read | Read inventory data | GET /inventory |
| payments:process | Process payments | POST /payments/authorize |

### Rate Limiting

| Client Type | Rate Limit | Window | Burst |
|-------------|------------|--------|-------|
| Web Application | 1000 req/hour | 1 hour | 50 req/minute |
| Mobile Application | 500 req/hour | 1 hour | 25 req/minute |
| B2B Integration | 5000 req/hour | 1 hour | 200 req/minute |
| Internal Services | 10000 req/hour | 1 hour | 500 req/minute |

### Data Security & Privacy

#### PII Data Masking
- **Credit Card Numbers**: Show only last 4 digits
- **Email Addresses**: Mask middle portion (j***@example.com)
- **Phone Numbers**: Mask middle digits (+1-555-***-4567)
- **Addresses**: Full address only for authorized users

#### Encryption Standards
- **TLS**: 1.3 for all external communications
- **Data at Rest**: AES-256 encryption
- **Key Management**: AWS KMS or Azure Key Vault
- **Token Storage**: Secure vault with TTL

This comprehensive API specification provides the foundation for consistent, secure, and well-documented interfaces across the entire Order Management System integration ecosystem.
