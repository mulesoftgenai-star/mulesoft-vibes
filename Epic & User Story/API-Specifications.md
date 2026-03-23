# Order Management System API Specifications

## Overview
This document defines the API specifications for the Order Management System (OMS) integration based on the API-Led Connectivity architecture with Experience, Process, and System layers.

---

## API Architecture Layers

### Experience Layer
- **Order Experience API** - Consumer-facing API for order operations

### Process Layer  
- **Order Processing API** - Orchestrates business processes across systems

### System Layer
- **Customer System API** - Interfaces with Customer Management System
- **Inventory System API** - Interfaces with Inventory Management System  
- **Payment System API** - Interfaces with Payment Gateway
- **Shipping System API** - Interfaces with Shipping/Logistics System

---

# Experience Layer APIs

## Order Experience API

### Base URL
```
https://api.company.com/experience/orders/v1
```

### Authentication
- **Type:** OAuth 2.0 Bearer Token
- **Header:** `Authorization: Bearer {token}`

---

### 1. Create Order
**Endpoint:** `POST /orders`  
**Description:** Create a new order with customer validation and inventory check

#### Request Headers
```http
Content-Type: application/json
Authorization: Bearer {oauth_token}
X-Correlation-ID: {unique_correlation_id}
```

#### Request Body
```json
{
  "customerId": "CUST-12345",
  "orderItems": [
    {
      "productId": "PROD-001",
      "quantity": 2,
      "price": 29.99
    },
    {
      "productId": "PROD-002", 
      "quantity": 1,
      "price": 49.99
    }
  ],
  "shippingAddress": {
    "street": "123 Main St",
    "city": "Anytown",
    "state": "ST",
    "zipCode": "12345",
    "country": "US"
  },
  "billingAddress": {
    "street": "123 Main St",
    "city": "Anytown", 
    "state": "ST",
    "zipCode": "12345",
    "country": "US"
  },
  "paymentMethod": {
    "type": "CREDIT_CARD",
    "cardToken": "tok_1234567890"
  }
}
```

#### Response (201 Created)
```json
{
  "orderId": "ORD-2026-001234",
  "status": "CREATED",
  "customerId": "CUST-12345",
  "orderDate": "2026-03-23T12:49:27Z",
  "totalAmount": 109.97,
  "currency": "USD",
  "orderItems": [
    {
      "productId": "PROD-001",
      "quantity": 2,
      "unitPrice": 29.99,
      "totalPrice": 59.98,
      "inventoryStatus": "AVAILABLE"
    },
    {
      "productId": "PROD-002",
      "quantity": 1, 
      "unitPrice": 49.99,
      "totalPrice": 49.99,
      "inventoryStatus": "AVAILABLE"
    }
  ],
  "shippingAddress": {
    "street": "123 Main St",
    "city": "Anytown",
    "state": "ST", 
    "zipCode": "12345",
    "country": "US"
  },
  "estimatedDeliveryDate": "2026-03-28T00:00:00Z",
  "_links": {
    "self": {
      "href": "/orders/ORD-2026-001234"
    },
    "status": {
      "href": "/orders/ORD-2026-001234/status"
    }
  }
}
```

#### Error Responses
```json
// 400 Bad Request - Invalid Customer
{
  "error": {
    "code": "INVALID_CUSTOMER",
    "message": "Customer ID CUST-12345 not found",
    "correlationId": "corr-123456789",
    "timestamp": "2026-03-23T12:49:27Z"
  }
}

// 400 Bad Request - Insufficient Inventory
{
  "error": {
    "code": "INSUFFICIENT_INVENTORY", 
    "message": "Insufficient inventory for product PROD-001. Available: 1, Requested: 2",
    "correlationId": "corr-123456789",
    "timestamp": "2026-03-23T12:49:27Z"
  }
}
```

---

### 2. Retrieve Order
**Endpoint:** `GET /orders/{orderId}`  
**Description:** Retrieve order details by order ID

#### Request Headers
```http
Authorization: Bearer {oauth_token}
X-Correlation-ID: {unique_correlation_id}
```

#### Path Parameters
- `orderId` (string, required) - The order identifier

#### Response (200 OK)
```json
{
  "orderId": "ORD-2026-001234",
  "status": "SHIPPED",
  "customerId": "CUST-12345",
  "customerName": "John Doe",
  "orderDate": "2026-03-23T12:49:27Z",
  "totalAmount": 109.97,
  "currency": "USD",
  "orderItems": [
    {
      "productId": "PROD-001",
      "productName": "Widget A",
      "quantity": 2,
      "unitPrice": 29.99,
      "totalPrice": 59.98
    },
    {
      "productId": "PROD-002",
      "productName": "Widget B", 
      "quantity": 1,
      "unitPrice": 49.99,
      "totalPrice": 49.99
    }
  ],
  "paymentStatus": "PAID",
  "paymentDate": "2026-03-23T13:15:00Z",
  "shipmentDetails": {
    "trackingNumber": "1Z999AA1234567890",
    "carrier": "UPS",
    "shipmentDate": "2026-03-24T10:00:00Z",
    "estimatedDeliveryDate": "2026-03-28T00:00:00Z"
  },
  "statusHistory": [
    {
      "status": "CREATED",
      "timestamp": "2026-03-23T12:49:27Z"
    },
    {
      "status": "PAID", 
      "timestamp": "2026-03-23T13:15:00Z"
    },
    {
      "status": "SHIPPED",
      "timestamp": "2026-03-24T10:00:00Z"
    }
  ]
}
```

#### Error Response (404 Not Found)
```json
{
  "error": {
    "code": "ORDER_NOT_FOUND",
    "message": "Order ORD-2026-001234 not found",
    "correlationId": "corr-123456789", 
    "timestamp": "2026-03-23T12:49:27Z"
  }
}
```

---

### 3. List Orders
**Endpoint:** `GET /orders`  
**Description:** Retrieve list of orders with pagination and filtering

#### Request Headers
```http
Authorization: Bearer {oauth_token}
X-Correlation-ID: {unique_correlation_id}
```

#### Query Parameters
- `customerId` (string, optional) - Filter by customer ID
- `status` (string, optional) - Filter by order status (CREATED, PAID, SHIPPED, DELIVERED, CANCELLED)
- `startDate` (string, optional) - Filter orders from date (ISO 8601)
- `endDate` (string, optional) - Filter orders to date (ISO 8601)
- `limit` (integer, optional, default=20, max=100) - Number of results per page
- `offset` (integer, optional, default=0) - Number of results to skip

#### Response (200 OK)
```json
{
  "orders": [
    {
      "orderId": "ORD-2026-001234",
      "customerId": "CUST-12345",
      "customerName": "John Doe",
      "orderDate": "2026-03-23T12:49:27Z",
      "status": "SHIPPED",
      "totalAmount": 109.97,
      "currency": "USD",
      "itemCount": 2
    },
    {
      "orderId": "ORD-2026-001235", 
      "customerId": "CUST-12346",
      "customerName": "Jane Smith",
      "orderDate": "2026-03-23T14:30:00Z",
      "status": "CREATED",
      "totalAmount": 75.50,
      "currency": "USD",
      "itemCount": 1
    }
  ],
  "pagination": {
    "totalCount": 150,
    "limit": 20,
    "offset": 0,
    "hasMore": true
  },
  "_links": {
    "self": {
      "href": "/orders?limit=20&offset=0"
    },
    "next": {
      "href": "/orders?limit=20&offset=20"
    }
  }
}
```

---

### 4. Update Order Status
**Endpoint:** `PATCH /orders/{orderId}/status`  
**Description:** Update the status of an existing order

#### Request Headers
```http
Content-Type: application/json
Authorization: Bearer {oauth_token}
X-Correlation-ID: {unique_correlation_id}
```

#### Path Parameters
- `orderId` (string, required) - The order identifier

#### Request Body
```json
{
  "status": "CANCELLED",
  "reason": "Customer requested cancellation",
  "updatedBy": "CUSTOMER_SERVICE"
}
```

#### Response (200 OK)
```json
{
  "orderId": "ORD-2026-001234",
  "previousStatus": "CREATED",
  "newStatus": "CANCELLED", 
  "updatedDate": "2026-03-23T15:30:00Z",
  "reason": "Customer requested cancellation",
  "updatedBy": "CUSTOMER_SERVICE"
}
```

---

# Process Layer APIs

## Order Processing API

### Base URL
```
https://api-internal.company.com/process/orders/v1
```

### Key Endpoints

#### 1. Process Order Creation
**Endpoint:** `POST /order-processing/create`  
**Description:** Internal API to orchestrate order creation across systems

#### 2. Validate Order Requirements  
**Endpoint:** `POST /order-processing/validate`
**Description:** Validate customer, inventory, and payment requirements

#### 3. Process Payment
**Endpoint:** `POST /order-processing/payment`
**Description:** Orchestrate payment processing workflow

#### 4. Initiate Fulfillment
**Endpoint:** `POST /order-processing/fulfillment`
**Description:** Start order fulfillment process

---

# System Layer APIs

## Customer System API

### Base URL
```
https://api-internal.company.com/system/customers/v1
```

#### Validate Customer
**Endpoint:** `GET /customers/{customerId}/validate`

**Response:**
```json
{
  "customerId": "CUST-12345",
  "isValid": true,
  "customerDetails": {
    "name": "John Doe",
    "email": "john.doe@email.com",
    "status": "ACTIVE",
    "creditLimit": 5000.00,
    "availableCredit": 4500.00
  }
}
```

---

## Inventory System API

### Base URL  
```
https://api-internal.company.com/system/inventory/v1
```

#### Check Product Availability
**Endpoint:** `POST /inventory/check-availability`

**Request:**
```json
{
  "products": [
    {
      "productId": "PROD-001",
      "requestedQuantity": 2
    },
    {
      "productId": "PROD-002", 
      "requestedQuantity": 1
    }
  ]
}
```

**Response:**
```json
{
  "availability": [
    {
      "productId": "PROD-001",
      "requestedQuantity": 2,
      "availableQuantity": 50,
      "isAvailable": true,
      "reservationId": "RES-12345"
    },
    {
      "productId": "PROD-002",
      "requestedQuantity": 1, 
      "availableQuantity": 0,
      "isAvailable": false,
      "expectedRestockDate": "2026-03-25T00:00:00Z"
    }
  ]
}
```

---

## Payment System API

### Base URL
```
https://api-internal.company.com/system/payments/v1
```

#### Process Payment
**Endpoint:** `POST /payments/process`

**Request:**
```json
{
  "orderId": "ORD-2026-001234",
  "amount": 109.97,
  "currency": "USD",
  "paymentMethod": {
    "type": "CREDIT_CARD",
    "cardToken": "tok_1234567890"
  },
  "billingAddress": {
    "street": "123 Main St",
    "city": "Anytown",
    "state": "ST",
    "zipCode": "12345",
    "country": "US"
  }
}
```

**Response:**
```json
{
  "paymentId": "PAY-789123456",
  "status": "SUCCESS",
  "transactionId": "TXN-987654321",
  "amount": 109.97,
  "currency": "USD",
  "processedDate": "2026-03-23T13:15:00Z",
  "authorizationCode": "AUTH123456"
}
```

---

## Shipping System API

### Base URL
```
https://api-internal.company.com/system/shipping/v1
```

#### Create Shipment
**Endpoint:** `POST /shipments/create`

**Request:**
```json
{
  "orderId": "ORD-2026-001234",
  "recipient": {
    "name": "John Doe",
    "address": {
      "street": "123 Main St",
      "city": "Anytown",
      "state": "ST", 
      "zipCode": "12345",
      "country": "US"
    }
  },
  "items": [
    {
      "productId": "PROD-001",
      "quantity": 2,
      "weight": 1.5,
      "dimensions": {
        "length": 10,
        "width": 8,
        "height": 6
      }
    }
  ],
  "shippingMethod": "STANDARD"
}
```

**Response:**
```json
{
  "shipmentId": "SHIP-456789",
  "trackingNumber": "1Z999AA1234567890",
  "carrier": "UPS",
  "shippingMethod": "STANDARD",
  "estimatedDeliveryDate": "2026-03-28T00:00:00Z",
  "shippingCost": 8.99,
  "labelUrl": "https://labels.company.com/SHIP-456789.pdf"
}
```

---

# Error Handling Standards

## Standard Error Response Format
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable error message", 
    "details": "Additional technical details",
    "correlationId": "correlation-id-123",
    "timestamp": "2026-03-23T12:49:27Z",
    "path": "/api/v1/orders",
    "validationErrors": [
      {
        "field": "customerId",
        "message": "Customer ID is required"
      }
    ]
  }
}
```

## HTTP Status Codes
- `200` - OK (Successful GET, PUT, PATCH)
- `201` - Created (Successful POST)
- `400` - Bad Request (Invalid input)
- `401` - Unauthorized (Missing or invalid authentication)
- `403` - Forbidden (Insufficient permissions)
- `404` - Not Found (Resource doesn't exist)
- `409` - Conflict (Resource conflict)
- `422` - Unprocessable Entity (Validation errors)
- `429` - Too Many Requests (Rate limiting)
- `500` - Internal Server Error (Unexpected server error)
- `502` - Bad Gateway (Upstream service error)
- `503` - Service Unavailable (Service temporarily unavailable)

## Common Error Codes
- `INVALID_REQUEST` - Request validation failed
- `INVALID_CUSTOMER` - Customer not found or invalid
- `INSUFFICIENT_INVENTORY` - Not enough inventory available  
- `PAYMENT_FAILED` - Payment processing failed
- `ORDER_NOT_FOUND` - Order doesn't exist
- `UNAUTHORIZED_ACCESS` - Insufficient permissions
- `SERVICE_UNAVAILABLE` - Backend service unavailable
- `RATE_LIMIT_EXCEEDED` - Too many requests

---

# API Security Requirements

## Authentication
- OAuth 2.0 Bearer Token authentication required for all APIs
- Token expiration: 1 hour for access tokens
- Refresh token expiration: 30 days

## Authorization  
- Role-based access control (RBAC)
- Scope-based permissions for different operations
- Customer data access restricted by customer relationship

## Data Protection
- All APIs must use HTTPS/TLS 1.2+
- Sensitive data (payment info) must be tokenized
- PII data must be masked in logs
- API rate limiting: 1000 requests per minute per client

## Headers
- `X-Correlation-ID` - Required for request tracing
- `X-API-Version` - API version specification  
- `X-Client-ID` - Client application identification
- `Authorization` - Bearer token for authentication