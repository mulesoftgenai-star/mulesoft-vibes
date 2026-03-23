# Sample Payloads for Order Management System Integration

## Overview
This document provides comprehensive sample payloads for all API endpoints and system integrations in the Order Management System.

---

# Experience Layer Payloads

## 1. Create Order (POST /orders)

### Request Payload
```json
{
  "customerId": "CUST-12345",
  "orderItems": [
    {
      "productId": "PROD-001",
      "productName": "Wireless Bluetooth Headphones",
      "quantity": 2,
      "price": 79.99,
      "currency": "USD"
    },
    {
      "productId": "PROD-002",
      "productName": "USB-C Charging Cable",
      "quantity": 3,
      "price": 19.99,
      "currency": "USD"
    }
  ],
  "shippingAddress": {
    "recipientName": "John Doe",
    "addressLine1": "123 Main Street",
    "addressLine2": "Apartment 4B",
    "city": "San Francisco",
    "state": "CA",
    "zipCode": "94105",
    "country": "US"
  },
  "billingAddress": {
    "recipientName": "John Doe", 
    "addressLine1": "123 Main Street",
    "addressLine2": "Apartment 4B",
    "city": "San Francisco",
    "state": "CA",
    "zipCode": "94105",
    "country": "US"
  },
  "paymentMethod": {
    "type": "CREDIT_CARD",
    "cardToken": "tok_1234567890abcdef",
    "lastFourDigits": "4242",
    "expiryMonth": "12",
    "expiryYear": "2027",
    "cardType": "VISA"
  },
  "shippingMethod": "STANDARD",
  "orderNotes": "Please handle with care - fragile items",
  "marketingOptIn": true,
  "termsAccepted": true
}
```

### Success Response (201 Created)
```json
{
  "orderId": "ORD-2026-001234",
  "orderNumber": "ORD001234",
  "status": "CREATED",
  "customerId": "CUST-12345",
  "customerName": "John Doe",
  "orderDate": "2026-03-23T12:49:27.123Z",
  "currency": "USD",
  "orderItems": [
    {
      "itemId": "ITEM-001",
      "productId": "PROD-001",
      "productName": "Wireless Bluetooth Headphones",
      "quantity": 2,
      "unitPrice": 79.99,
      "totalPrice": 159.98,
      "inventoryStatus": "RESERVED",
      "reservationId": "RES-789123"
    },
    {
      "itemId": "ITEM-002", 
      "productId": "PROD-002",
      "productName": "USB-C Charging Cable",
      "quantity": 3,
      "unitPrice": 19.99,
      "totalPrice": 59.97,
      "inventoryStatus": "RESERVED",
      "reservationId": "RES-789124"
    }
  ],
  "pricing": {
    "subtotal": 219.95,
    "tax": 17.60,
    "shipping": 9.99,
    "discount": 0.00,
    "totalAmount": 247.54
  },
  "shippingAddress": {
    "recipientName": "John Doe",
    "addressLine1": "123 Main Street",
    "addressLine2": "Apartment 4B", 
    "city": "San Francisco",
    "state": "CA",
    "zipCode": "94105",
    "country": "US"
  },
  "estimatedDeliveryDate": "2026-03-28T00:00:00Z",
  "trackingUrl": "https://tracking.company.com/ORD-2026-001234",
  "_links": {
    "self": {
      "href": "/orders/ORD-2026-001234"
    },
    "status": {
      "href": "/orders/ORD-2026-001234/status"
    },
    "customer": {
      "href": "/customers/CUST-12345"
    }
  }
}
```

### Error Response - Invalid Customer (400 Bad Request)
```json
{
  "error": {
    "code": "INVALID_CUSTOMER",
    "message": "Customer ID CUST-12345 not found or inactive",
    "correlationId": "corr-abc123def456",
    "timestamp": "2026-03-23T12:49:27.123Z",
    "path": "/orders",
    "validationErrors": [
      {
        "field": "customerId",
        "message": "Customer must exist and be active"
      }
    ]
  }
}
```

### Error Response - Insufficient Inventory (400 Bad Request)
```json
{
  "error": {
    "code": "INSUFFICIENT_INVENTORY",
    "message": "Insufficient inventory for one or more products",
    "correlationId": "corr-abc123def456",
    "timestamp": "2026-03-23T12:49:27.123Z",
    "path": "/orders",
    "details": [
      {
        "productId": "PROD-001",
        "requestedQuantity": 2,
        "availableQuantity": 1,
        "estimatedRestockDate": "2026-03-25T00:00:00Z"
      }
    ]
  }
}
```

---

## 2. Retrieve Order (GET /orders/{orderId})

### Success Response (200 OK)
```json
{
  "orderId": "ORD-2026-001234",
  "orderNumber": "ORD001234", 
  "status": "SHIPPED",
  "customerId": "CUST-12345",
  "customerName": "John Doe",
  "customerEmail": "john.doe@email.com",
  "orderDate": "2026-03-23T12:49:27.123Z",
  "currency": "USD",
  "orderItems": [
    {
      "itemId": "ITEM-001",
      "productId": "PROD-001",
      "productName": "Wireless Bluetooth Headphones",
      "productDescription": "High-quality wireless headphones with noise cancellation",
      "quantity": 2,
      "unitPrice": 79.99,
      "totalPrice": 159.98,
      "inventoryStatus": "FULFILLED"
    },
    {
      "itemId": "ITEM-002",
      "productId": "PROD-002",
      "productName": "USB-C Charging Cable",
      "productDescription": "Fast charging USB-C cable, 6 feet",
      "quantity": 3,
      "unitPrice": 19.99,
      "totalPrice": 59.97,
      "inventoryStatus": "FULFILLED"
    }
  ],
  "pricing": {
    "subtotal": 219.95,
    "tax": 17.60,
    "shipping": 9.99,
    "discount": 0.00,
    "totalAmount": 247.54
  },
  "addresses": {
    "shipping": {
      "recipientName": "John Doe",
      "addressLine1": "123 Main Street",
      "addressLine2": "Apartment 4B",
      "city": "San Francisco",
      "state": "CA",
      "zipCode": "94105",
      "country": "US"
    },
    "billing": {
      "recipientName": "John Doe",
      "addressLine1": "123 Main Street", 
      "addressLine2": "Apartment 4B",
      "city": "San Francisco",
      "state": "CA",
      "zipCode": "94105",
      "country": "US"
    }
  },
  "payment": {
    "paymentId": "PAY-789123456",
    "status": "PAID",
    "method": "CREDIT_CARD",
    "lastFourDigits": "4242",
    "amount": 247.54,
    "currency": "USD",
    "paidDate": "2026-03-23T13:15:30.456Z",
    "transactionId": "TXN-987654321"
  },
  "shipping": {
    "shipmentId": "SHIP-456789",
    "trackingNumber": "1Z999AA1234567890",
    "carrier": "UPS",
    "method": "STANDARD",
    "status": "IN_TRANSIT",
    "shippedDate": "2026-03-24T10:00:00.000Z",
    "estimatedDeliveryDate": "2026-03-28T00:00:00.000Z",
    "trackingUrl": "https://ups.com/track?tracknum=1Z999AA1234567890"
  },
  "statusHistory": [
    {
      "status": "CREATED",
      "timestamp": "2026-03-23T12:49:27.123Z",
      "note": "Order created successfully"
    },
    {
      "status": "PAYMENT_AUTHORIZED",
      "timestamp": "2026-03-23T12:50:15.789Z",
      "note": "Payment authorized"
    },
    {
      "status": "PAYMENT_CAPTURED",
      "timestamp": "2026-03-23T13:15:30.456Z",
      "note": "Payment captured successfully"
    },
    {
      "status": "FULFILLED",
      "timestamp": "2026-03-24T09:30:00.000Z",
      "note": "Order fulfilled and ready for shipment"
    },
    {
      "status": "SHIPPED",
      "timestamp": "2026-03-24T10:00:00.000Z",
      "note": "Order shipped via UPS"
    }
  ],
  "orderNotes": "Please handle with care - fragile items",
  "_links": {
    "self": {
      "href": "/orders/ORD-2026-001234"
    },
    "status": {
      "href": "/orders/ORD-2026-001234/status"
    },
    "tracking": {
      "href": "https://ups.com/track?tracknum=1Z999AA1234567890"
    }
  }
}
```

### Error Response - Order Not Found (404 Not Found)
```json
{
  "error": {
    "code": "ORDER_NOT_FOUND",
    "message": "Order with ID ORD-2026-001234 not found",
    "correlationId": "corr-abc123def456",
    "timestamp": "2026-03-23T12:49:27.123Z",
    "path": "/orders/ORD-2026-001234"
  }
}
```

---

## 3. List Orders (GET /orders)

### Success Response (200 OK)
```json
{
  "orders": [
    {
      "orderId": "ORD-2026-001234",
      "orderNumber": "ORD001234",
      "customerId": "CUST-12345",
      "customerName": "John Doe",
      "orderDate": "2026-03-23T12:49:27.123Z",
      "status": "SHIPPED",
      "totalAmount": 247.54,
      "currency": "USD",
      "itemCount": 2,
      "estimatedDeliveryDate": "2026-03-28T00:00:00Z"
    },
    {
      "orderId": "ORD-2026-001235",
      "orderNumber": "ORD001235",
      "customerId": "CUST-12346",
      "customerName": "Jane Smith", 
      "orderDate": "2026-03-23T14:30:00.000Z",
      "status": "CREATED",
      "totalAmount": 89.99,
      "currency": "USD",
      "itemCount": 1,
      "estimatedDeliveryDate": "2026-03-30T00:00:00Z"
    },
    {
      "orderId": "ORD-2026-001236",
      "orderNumber": "ORD001236",
      "customerId": "CUST-12347",
      "customerName": "Bob Johnson",
      "orderDate": "2026-03-22T16:45:00.000Z",
      "status": "DELIVERED",
      "totalAmount": 156.78,
      "currency": "USD",
      "itemCount": 3,
      "deliveredDate": "2026-03-25T14:30:00.000Z"
    }
  ],
  "pagination": {
    "totalCount": 1523,
    "pageSize": 20,
    "currentPage": 1,
    "totalPages": 77,
    "hasNext": true,
    "hasPrevious": false
  },
  "_links": {
    "self": {
      "href": "/orders?page=1&limit=20"
    },
    "next": {
      "href": "/orders?page=2&limit=20"
    },
    "first": {
      "href": "/orders?page=1&limit=20"
    },
    "last": {
      "href": "/orders?page=77&limit=20"
    }
  }
}
```

---

## 4. Update Order Status (PATCH /orders/{orderId}/status)

### Request Payload
```json
{
  "status": "CANCELLED",
  "reason": "Customer requested cancellation",
  "updatedBy": "CUSTOMER_SERVICE_REP_001",
  "notes": "Customer called and requested immediate cancellation due to change of mind"
}
```

### Success Response (200 OK)
```json
{
  "orderId": "ORD-2026-001234",
  "previousStatus": "CREATED",
  "newStatus": "CANCELLED",
  "statusChangeDate": "2026-03-23T15:30:00.000Z",
  "reason": "Customer requested cancellation",
  "updatedBy": "CUSTOMER_SERVICE_REP_001",
  "notes": "Customer called and requested immediate cancellation due to change of mind",
  "refundDetails": {
    "refundId": "REF-123456789",
    "refundAmount": 247.54,
    "currency": "USD",
    "estimatedRefundDate": "2026-03-25T00:00:00Z",
    "refundMethod": "ORIGINAL_PAYMENT_METHOD"
  }
}
```

---

# Process Layer Payloads

## 1. Order Processing - Create Order

### Request to Process Layer
```json
{
  "correlationId": "corr-abc123def456",
  "orderId": "ORD-2026-001234",
  "customerId": "CUST-12345",
  "orderItems": [
    {
      "productId": "PROD-001",
      "quantity": 2,
      "unitPrice": 79.99
    },
    {
      "productId": "PROD-002",
      "quantity": 3,
      "unitPrice": 19.99
    }
  ],
  "shippingAddress": {
    "recipientName": "John Doe",
    "addressLine1": "123 Main Street",
    "addressLine2": "Apartment 4B",
    "city": "San Francisco",
    "state": "CA",
    "zipCode": "94105",
    "country": "US"
  },
  "paymentMethod": {
    "type": "CREDIT_CARD",
    "cardToken": "tok_1234567890abcdef"
  },
  "businessRules": {
    "validateCustomerCredit": true,
    "reserveInventory": true,
    "requirePaymentAuth": true,
    "createShipment": true
  }
}
```

### Process Layer Response
```json
{
  "correlationId": "corr-abc123def456",
  "orderId": "ORD-2026-001234",
  "processStatus": "SUCCESS",
  "executionSteps": [
    {
      "stepName": "CUSTOMER_VALIDATION",
      "status": "SUCCESS",
      "executionTime": "2026-03-23T12:49:28.000Z",
      "duration": 150,
      "result": {
        "customerId": "CUST-12345",
        "customerName": "John Doe",
        "isValid": true,
        "creditLimit": 5000.00,
        "availableCredit": 4752.46
      }
    },
    {
      "stepName": "INVENTORY_VALIDATION",
      "status": "SUCCESS", 
      "executionTime": "2026-03-23T12:49:28.200Z",
      "duration": 300,
      "result": {
        "reservations": [
          {
            "productId": "PROD-001",
            "reservationId": "RES-789123",
            "quantity": 2,
            "expiresAt": "2026-03-23T13:49:28.200Z"
          },
          {
            "productId": "PROD-002",
            "reservationId": "RES-789124",
            "quantity": 3,
            "expiresAt": "2026-03-23T13:49:28.200Z"
          }
        ]
      }
    },
    {
      "stepName": "PAYMENT_AUTHORIZATION",
      "status": "SUCCESS",
      "executionTime": "2026-03-23T12:49:29.000Z",
      "duration": 800,
      "result": {
        "paymentId": "PAY-789123456",
        "authorizationCode": "AUTH-123456",
        "status": "AUTHORIZED",
        "amount": 247.54
      }
    },
    {
      "stepName": "ORDER_CREATION",
      "status": "SUCCESS",
      "executionTime": "2026-03-23T12:49:30.000Z",
      "duration": 200,
      "result": {
        "orderId": "ORD-2026-001234",
        "orderNumber": "ORD001234",
        "status": "CREATED"
      }
    }
  ],
  "totalExecutionTime": 1450
}
```

---

# System Layer Payloads

## 1. Customer System API

### Validate Customer Request
```json
{
  "customerId": "CUST-12345",
  "validationType": "ORDER_PLACEMENT",
  "requestedAmount": 247.54,
  "currency": "USD"
}
```

### Validate Customer Response
```json
{
  "customerId": "CUST-12345",
  "isValid": true,
  "validationResult": "APPROVED",
  "customerDetails": {
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@email.com",
    "phone": "+1-555-123-4567",
    "status": "ACTIVE",
    "registrationDate": "2024-06-15T00:00:00Z",
    "lastOrderDate": "2026-03-15T10:30:00Z",
    "totalOrders": 15,
    "lifetimeValue": 2347.89
  },
  "creditInformation": {
    "creditLimit": 5000.00,
    "availableCredit": 4752.46,
    "creditUtilization": 0.05,
    "creditRating": "EXCELLENT"
  },
  "validationTimestamp": "2026-03-23T12:49:28.000Z"
}
```

---

## 2. Inventory System API

### Check Availability Request
```json
{
  "requestId": "REQ-789123456",
  "products": [
    {
      "productId": "PROD-001",
      "requestedQuantity": 2,
      "location": "WAREHOUSE_WEST_01"
    },
    {
      "productId": "PROD-002",
      "requestedQuantity": 3,
      "location": "WAREHOUSE_WEST_01"
    }
  ],
  "reservationRequired": true,
  "reservationDuration": 3600
}
```

### Check Availability Response
```json
{
  "requestId": "REQ-789123456",
  "timestamp": "2026-03-23T12:49:28.200Z",
  "products": [
    {
      "productId": "PROD-001",
      "productName": "Wireless Bluetooth Headphones",
      "requestedQuantity": 2,
      "availableQuantity": 25,
      "isAvailable": true,
      "location": "WAREHOUSE_WEST_01",
      "reservation": {
        "reservationId": "RES-789123",
        "reservedQuantity": 2,
        "expiresAt": "2026-03-23T13:49:28.200Z",
        "status": "ACTIVE"
      },
      "productDetails": {
        "sku": "WBH-001",
        "category": "Electronics",
        "weight": 0.5,
        "dimensions": {
          "length": 8.0,
          "width": 6.0,
          "height": 3.0,
          "unit": "inches"
        }
      }
    },
    {
      "productId": "PROD-002",
      "productName": "USB-C Charging Cable",
      "requestedQuantity": 3,
      "availableQuantity": 150,
      "isAvailable": true,
      "location": "WAREHOUSE_WEST_01",
      "reservation": {
        "reservationId": "RES-789124",
        "reservedQuantity": 3,
        "expiresAt": "2026-03-23T13:49:28.200Z",
        "status": "ACTIVE"
      },
      "productDetails": {
        "sku": "USBC-001",
        "category": "Accessories",
        "weight": 0.2,
        "dimensions": {
          "length": 6.0,
          "width": 1.0,
          "height": 0.5,
          "unit": "feet"
        }
      }
    }
  ]
}
```

---

## 3. Payment System API

### Process Payment Request
```json
{
  "paymentId": "PAY-789123456",
  "orderId": "ORD-2026-001234",
  "customerId": "CUST-12345",
  "amount": 247.54,
  "currency": "USD",
  "paymentMethod": {
    "type": "CREDIT_CARD",
    "cardToken": "tok_1234567890abcdef",
    "savePaymentMethod": true
  },
  "billingAddress": {
    "recipientName": "John Doe",
    "addressLine1": "123 Main Street",
    "addressLine2": "Apartment 4B",
    "city": "San Francisco",
    "state": "CA",
    "zipCode": "94105",
    "country": "US"
  },
  "transactionType": "AUTHORIZE_AND_CAPTURE",
  "merchantInfo": {
    "merchantId": "MERCH-12345",
    "merchantName": "Company Store",
    "mcc": "5732"
  }
}
```

### Process Payment Response
```json
{
  "paymentId": "PAY-789123456",
  "transactionId": "TXN-987654321",
  "status": "SUCCESS",
  "paymentStatus": "CAPTURED",
  "amount": 247.54,
  "currency": "USD",
  "processedDate": "2026-03-23T13:15:30.456Z",
  "authorizationDetails": {
    "authorizationCode": "AUTH-123456",
    "authorizationDate": "2026-03-23T12:49:29.000Z",
    "expiresAt": "2026-03-30T12:49:29.000Z"
  },
  "captureDetails": {
    "captureId": "CAP-789123456",
    "capturedAmount": 247.54,
    "captureDate": "2026-03-23T13:15:30.456Z"
  },
  "paymentMethod": {
    "type": "CREDIT_CARD",
    "lastFourDigits": "4242",
    "brand": "VISA",
    "expiryMonth": "12",
    "expiryYear": "2027",
    "paymentMethodId": "PM-123456789"
  },
  "fees": {
    "processingFee": 7.19,
    "currency": "USD"
  },
  "riskAssessment": {
    "riskScore": 15,
    "riskLevel": "LOW",
    "fraudCheck": "PASSED"
  }
}
```

---

## 4. Shipping System API

### Create Shipment Request
```json
{
  "shipmentId": "SHIP-456789",
  "orderId": "ORD-2026-001234",
  "customerId": "CUST-12345",
  "shipFrom": {
    "name": "Company Warehouse West",
    "addressLine1": "456 Industrial Blvd",
    "city": "San Jose",
    "state": "CA",
    "zipCode": "95123",
    "country": "US",
    "phone": "+1-555-987-6543"
  },
  "shipTo": {
    "name": "John Doe",
    "addressLine1": "123 Main Street",
    "addressLine2": "Apartment 4B",
    "city": "San Francisco",
    "state": "CA",
    "zipCode": "94105",
    "country": "US",
    "phone": "+1-555-123-4567",
    "email": "john.doe@email.com"
  },
  "items": [
    {
      "itemId": "ITEM-001",
      "productId": "PROD-001",
      "productName": "Wireless Bluetooth Headphones",
      "quantity": 2,
      "weight": 1.0,
      "dimensions": {
        "length": 8.0,
        "width": 6.0,
        "height": 3.0,
        "unit": "inches"
      },
      "value": 159.98,
      "currency": "USD"
    },
    {
      "itemId": "ITEM-002",
      "productId": "PROD-002",
      "productName": "USB-C Charging Cable",
      "quantity": 3,
      "weight": 0.6,
      "dimensions": {
        "length": 72.0,
        "width": 1.0,
        "height": 0.5,
        "unit": "inches"
      },
      "value": 59.97,
      "currency": "USD"
    }
  ],
  "shippingMethod": "STANDARD",
  "shippingPreferences": {
    "signatureRequired": false,
    "leaveAtDoor": true,
    "specialInstructions": "Handle with care - fragile items"
  },
  "insurance": {
    "required": true,
    "declaredValue": 219.95,
    "currency": "USD"
  }
}
```

### Create Shipment Response
```json
{
  "shipmentId": "SHIP-456789",
  "orderId": "ORD-2026-001234",
  "status": "CREATED",
  "createdDate": "2026-03-24T09:30:00.000Z",
  "trackingDetails": {
    "trackingNumber": "1Z999AA1234567890",
    "carrier": "UPS",
    "service": "UPS Ground",
    "trackingUrl": "https://ups.com/track?tracknum=1Z999AA1234567890"
  },
  "shippingLabel": {
    "labelId": "LBL-123456789",
    "labelUrl": "https://labels.company.com/SHIP-456789.pdf",
    "labelFormat": "PDF",
    "createdDate": "2026-03-24T09:30:00.000Z"
  },
  "estimatedDelivery": {
    "estimatedDeliveryDate": "2026-03-28T00:00:00.000Z",
    "businessDays": 4,
    "deliveryWindow": "9:00 AM - 5:00 PM"
  },
  "shippingCost": {
    "baseCost": 8.99,
    "insurance": 2.19,
    "totalCost": 11.18,
    "currency": "USD"
  },
  "packageDetails": {
    "packageCount": 1,
    "totalWeight": 1.6,
    "totalDimensions": {
      "length": 10.0,
      "width": 8.0,
      "height": 4.0,
      "unit": "inches"
    }
  }
}
```

---

# Event Payloads (Anypoint MQ Messages)

## 1. Order Created Event
```json
{
  "eventId": "EVT-2026-789123",
  "eventType": "ORDER_CREATED",
  "timestamp": "2026-03-23T12:49:27.123Z",
  "source": "order-processing-api",
  "version": "1.0",
  "data": {
    "orderId": "ORD-2026-001234",
    "customerId": "CUST-12345",
    "orderTotal": 247.54,
    "currency": "USD",
    "itemCount": 2,
    "status": "CREATED",
    "orderDate": "2026-03-23T12:49:27.123Z"
  },
  "metadata": {
    "correlationId": "corr-abc123def456",
    "requestId": "req-789123456",
    "userId": "USER-001"
  }
}
```

## 2. Payment Processed Event
```json
{
  "eventId": "EVT-2026-789124",
  "eventType": "PAYMENT_PROCESSED",
  "timestamp": "2026-03-23T13:15:30.456Z",
  "source": "payment-processing-api",
  "version": "1.0",
  "data": {
    "orderId": "ORD-2026-001234",
    "paymentId": "PAY-789123456",
    "transactionId": "TXN-987654321",
    "amount": 247.54,
    "currency": "USD",
    "paymentStatus": "CAPTURED",
    "paymentMethod": "CREDIT_CARD",
    "lastFourDigits": "4242"
  },
  "metadata": {
    "correlationId": "corr-abc123def456",
    "processingTime": 800
  }
}
```

## 3. Order Shipped Event
```json
{
  "eventId": "EVT-2026-789125",
  "eventType": "ORDER_SHIPPED",
  "timestamp": "2026-03-24T10:00:00.000Z",
  "source": "shipping-processing-api",
  "version": "1.0",
  "data": {
    "orderId": "ORD-2026-001234",
    "shipmentId": "SHIP-456789",
    "trackingNumber": "1Z999AA1234567890",
    "carrier": "UPS",
    "shippingMethod": "STANDARD",
    "estimatedDeliveryDate": "2026-03-28T00:00:00.000Z"
  },
  "metadata": {
    "correlationId": "corr-abc123def456",
    "warehouseId": "WAREHOUSE_WEST_01"
  }
}
```

## 4. Inventory Reserved Event
```json
{
  "eventId": "EVT-2026-789126",
  "eventType": "INVENTORY_RESERVED",
  "timestamp": "2026-03-23T12:49:28.200Z",
  "source": "inventory-management-api",
  "version": "1.0",
  "data": {
    "orderId": "ORD-2026-001234",
    "reservations": [
      {
        "productId": "PROD-001",
        "reservationId": "RES-789123",
        "quantity": 2,
        "location": "WAREHOUSE_WEST_01",
        "expiresAt": "2026-03-23T13:49:28.200Z"
      },
      {
        "productId": "PROD-002",
        "reservationId": "RES-789124",
        "quantity": 3,
        "location": "WAREHOUSE_WEST_01",
        "expiresAt": "2026-03-23T13:49:28.200Z"
      }
    ]
  },
  "metadata": {
    "correlationId": "corr-abc123def456",
    "warehouseId": "WAREHOUSE_WEST_01"
  }
}
```

---

# Error Payload Examples

## 1. System Layer Error - Database Connection Failure
```json
{
  "error": {
    "code": "DATABASE_CONNECTION_FAILED",
    "message": "Unable to connect to customer database",
    "timestamp": "2026-03-23T12:49:27.123Z",
    "correlationId": "corr-abc123def456",
    "service": "customer-system-api",
    "details": {
      "databaseHost": "customer-db.internal.com",
      "connectionTimeout": 5000,
      "retryAttempts": 3,
      "lastAttempt": "2026-03-23T12:49:26.500Z"
    },
    "suggestedAction": "Check database connectivity and retry"
  }
}
```

## 2. Process Layer Error - Business Rule Violation
```json
{
  "error": {
    "code": "BUSINESS_RULE_VIOLATION",
    "message": "Customer has exceeded daily order limit",
    "timestamp": "2026-03-23T12:49:27.123Z",
    "correlationId": "corr-abc123def456",
    "service": "order-processing-api",
    "businessRule": {
      "ruleName": "DAILY_ORDER_LIMIT",
      "ruleDescription": "Customers can place maximum 10 orders per day",
      "currentValue": 11,
      "allowedValue": 10
    },
    "customerDetails": {
      "customerId": "CUST-12345",
      "todaysOrderCount": 11,
      "lastOrderTime": "2026-03-23T12:30:00.000Z"
    }
  }
}
```

## 3. Experience Layer Error - Rate Limit Exceeded
```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests. Rate limit exceeded.",
    "timestamp": "2026-03-23T12:49:27.123Z",
    "correlationId": "corr-abc123def456",
    "service": "order-experience-api",
    "rateLimitDetails": {
      "limit": 100,
      "windowSeconds": 60,
      "currentCount": 101,
      "resetTime": "2026-03-23T12:50:00.000Z"
    },
    "retryAfterSeconds": 33
  }
}
```

---

# DataWeave Transformation Examples

## 1. Experience to Process Layer Transformation
```dataweave
%dw 2.0
output application/json
---
{
  correlationId: vars.correlationId,
  orderId: uuid(),
  customerId: payload.customerId,
  orderItems: payload.orderItems map (item, index) -> {
    productId: item.productId,
    quantity: item.quantity,
    unitPrice: item.price
  },
  shippingAddress: {
    recipientName: payload.shippingAddress.recipientName,
    addressLine1: payload.shippingAddress.addressLine1,
    addressLine2: payload.shippingAddress.addressLine2 default "",
    city: payload.shippingAddress.city,
    state: payload.shippingAddress.state,
    zipCode: payload.shippingAddress.zipCode,
    country: payload.shippingAddress.country default "US"
  },
  paymentMethod: {
    type: payload.paymentMethod.type,
    cardToken: payload.paymentMethod.cardToken
  },
  businessRules: {
    validateCustomerCredit: true,
    reserveInventory: true,
    requirePaymentAuth: true,
    createShipment: true
  },
  metadata: {
    requestTime: now(),
    source: "order-experience-api",
    version: "1.0"
  }
}
```

## 2. Multiple System Response Aggregation
```dataweave
%dw 2.0
output application/json
var customerData = vars.customerResponse
var inventoryData = vars.inventoryResponse  
var paymentData = vars.paymentResponse
---
{
  orderId: vars.orderId,
  status: "CREATED",
  customerId: customerData.customerId,
  customerName: customerData.customerDetails.firstName ++ " " ++ customerData.customerDetails.lastName,
  orderDate: now(),
  currency: "USD",
  orderItems: payload.orderItems map (item, index) -> {
    itemId: "ITEM-" ++ (index + 1 as String),
    productId: item.productId,
    productName: item.productName,
    quantity: item.quantity,
    unitPrice: item.price,
    totalPrice: item.quantity * item.price,
    inventoryStatus: if(inventoryData.products[index].isAvailable) "RESERVED" else "UNAVAILABLE",
    reservationId: inventoryData.products[index].reservation.reservationId default null
  },
  pricing: {
    subtotal: sum(payload.orderItems map ($.quantity * $.price)),
    tax: sum(payload.orderItems map ($.quantity * $.price)) * 0.08,
    shipping: 9.99,
    discount: 0.00,
    totalAmount: sum(payload.orderItems map ($.quantity * $.price)) + 
                 (sum(payload.orderItems map ($.quantity * $.price)) * 0.08) + 9.99
  },
  payment: {
    paymentId: paymentData.paymentId,
    status: paymentData.paymentStatus,
    authorizationCode: paymentData.authorizationDetails.authorizationCode
  } if (paymentData != null),
  estimatedDeliveryDate: now() + |P5D|,
  _links: {
    self: {
      href: "/orders/" ++ vars.orderId
    },
    status: {
      href: "/orders/" ++ vars.orderId ++ "/status"
    }
  }
}
```

---

# Validation Schema Examples

## 1. Create Order Request Schema
```json
{
  "$schema": "# SECURITY: Remote schema removed (http://json-schema.org/draft-07/schema#)",
  "type": "object",
  "required": ["customerId", "orderItems", "shippingAddress", "paymentMethod"],
  "properties": {
    "customerId": {
      "type": "string",
      "pattern": "^CUST-[0-9]{5}$",
      "description": "Customer identifier in format CUST-12345"
    },
    "orderItems": {
      "type": "array",
      "minItems": 1,
      "maxItems": 50,
      "items": {
        "type": "object",
        "required": ["productId", "quantity", "price"],
        "properties": {
          "productId": {
            "type": "string",
            "pattern": "^PROD-[0-9]{3}$"
          },
          "quantity": {
            "type": "integer",
            "minimum": 1,
            "maximum": 100
          },
          "price": {
            "type": "number",
            "minimum": 0.01,
            "maximum": 10000.00
          }
        }
      }
    },
    "shippingAddress": {
      "type": "object",
      "required": ["recipientName", "addressLine1", "city", "state", "zipCode", "country"],
      "properties": {
        "recipientName": {
          "type": "string",
          "maxLength": 100
        },
        "addressLine1": {
          "type": "string",
          "maxLength": 100
        },
        "city": {
          "type": "string",
          "maxLength": 50
        },
        "state": {
          "type": "string",
          "pattern": "^[A-Z]{2}$"
        },
        "zipCode": {
          "type": "string",
          "pattern": "^[0-9]{5}(-[0-9]{4})?$"
        },
        "country": {
          "type": "string",
          "pattern": "^[A-Z]{2}$"
        }
      }
    },
    "paymentMethod": {
      "type": "object",
      "required": ["type", "cardToken"],
      "properties": {
        "type": {
          "type": "string",
          "enum": ["CREDIT_CARD", "DEBIT_CARD", "PAYPAL"]
        },
        "cardToken": {
          "type": "string",
          "pattern": "^tok_[a-zA-Z0-9]{16}$"
        }
      }
    }
  }
}
```

This comprehensive collection of sample payloads provides developers with concrete examples for implementing the Order Management System integration across all layers of the API-Led Connectivity architecture.
