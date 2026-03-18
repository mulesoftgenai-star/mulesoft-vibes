# Order Management System - RAML Data Types

## Overview

This directory contains comprehensive RAML data type definitions for the Order Management System integration based on the Business Requirements Document (BRD) section 11. The data types follow the API-Led Connectivity architecture pattern with Experience, Process, and System layer APIs.

## Architecture Layers

### Experience Layer APIs
- **File**: `OrderExperienceAPI.raml`
- **Purpose**: Customer-facing APIs for web portals, mobile apps, and external integrations
- **Operations**: Order creation, retrieval, listing, status updates, and price calculations

### Process Layer APIs
- **File**: `OrderProcessAPI.raml` 
- **Purpose**: Business process orchestration and workflow management
- **Operations**: Order processing, validation, status tracking, and retry mechanisms

### System Layer APIs
- **File**: `SystemAPIs.raml`
- **Purpose**: Backend system integrations and data operations
- **Systems**: Customer, Inventory, Payment, and Shipping System APIs

## Core Data Types

### New API Layer Data Types (in this directory)
- `OrderExperienceAPI.raml` - Experience Layer API request/response types
- `OrderProcessAPI.raml` - Process Layer API request/response types
- `SystemAPIs.raml` - System Layer API request/response types

### Base Entity Types (in RAML Fragments/DataTypes/)
- `Order.raml` - Complete order information with lifecycle tracking
- `Customer.raml` - Comprehensive customer profile and account data
- `Payment.raml` - Payment methods and transaction information
- `Address.raml` - Address information for shipping and billing
- `OrderItem.raml` - Individual line items within orders
- `OrderHistory.raml` - Audit trail for order status changes
- `Shipment.raml` - Shipment tracking and delivery information
- `ShipmentItem.raml` - Items within shipments
- `ErrorResponse.raml` - Standardized error handling structure

## Data Type Coverage by API Layer

### Experience Layer Data Types
| Operation | Request Type | Response Type | Purpose |
|-----------|-------------|---------------|---------|
| Create Order | `CreateOrderRequest` | `CreateOrderResponse` | New order creation |
| Get Order | Path Parameter | `GetOrderResponse` | Order retrieval |
| List Orders | `ListOrdersRequest` | `ListOrdersResponse` | Paginated order listing |
| Update Status | `UpdateOrderStatusRequest` | `UpdateOrderStatusResponse` | Order cancellation |
| Calculate Total | `CalculateOrderTotalRequest` | `CalculateOrderTotalResponse` | Price calculation |

### Process Layer Data Types
| Operation | Request Type | Response Type | Purpose |
|-----------|-------------|---------------|---------|
| Process Order | `ProcessOrderRequest` | `ProcessOrderResponse` | End-to-end processing |
| Validate Order | `ValidateOrderRequest` | `ValidateOrderResponse` | Pre-processing validation |
| Update Processing | `UpdateProcessingStatusRequest` | `UpdateProcessingStatusResponse` | Status updates |
| Get Status | `GetProcessingStatusRequest` | `GetProcessingStatusResponse` | Status inquiry |
| Retry Processing | `RetryProcessingRequest` | `RetryProcessingResponse` | Failed order retry |

### System Layer Data Types

#### Customer System API
| Operation | Request Type | Response Type | Purpose |
|-----------|-------------|---------------|---------|
| Get Customer | `GetCustomerRequest` | `GetCustomerResponse` | Customer lookup |
| Validate Customer | `ValidateCustomerRequest` | `ValidateCustomerResponse` | Customer validation |

#### Inventory System API
| Operation | Request Type | Response Type | Purpose |
|-----------|-------------|---------------|---------|
| Check Inventory | `CheckInventoryRequest` | `CheckInventoryResponse` | Availability check |
| Reserve Inventory | `ReserveInventoryRequest` | `ReserveInventoryResponse` | Inventory reservation |

#### Payment System API
| Operation | Request Type | Response Type | Purpose |
|-----------|-------------|---------------|---------|
| Process Payment | `ProcessPaymentRequest` | `ProcessPaymentResponse` | Payment processing |
| Validate Payment Method | `ValidatePaymentMethodRequest` | `ValidatePaymentMethodResponse` | Payment validation |

#### Shipping System API
| Operation | Request Type | Response Type | Purpose |
|-----------|-------------|---------------|---------|
| Create Shipment | `CreateShipmentRequest` | `CreateShipmentResponse` | Shipment creation |
| Get Rates | `GetShippingRatesRequest` | `GetShippingRatesResponse` | Rate calculation |
| Track Shipment | `TrackShipmentRequest` | `TrackShipmentResponse` | Shipment tracking |

## BRD Compliance

### Section 11 Data Model Requirements
The RAML data types implement all fields specified in BRD Section 11:

#### Order Object Fields (BRD Compliance)
- ✅ `orderId` - Unique order identifier  
- ✅ `customerId` - Customer identifier
- ✅ `orderDate` - Order creation date
- ✅ `items` - List of products (array of OrderItem)
- ✅ `productId` - Product identifier (in OrderItem)
- ✅ `quantity` - Quantity ordered (in OrderItem)
- ✅ `price` - Product price (in OrderItem)
- ✅ `totalAmount` - Total order amount
- ✅ `paymentStatus` - Payment status
- ✅ `shipmentStatus` - Shipping status (as shipmentId/trackingNumber)
- ✅ `orderStatus` - Overall order lifecycle status

#### Enhanced Data Model
Beyond BRD requirements, the data types include:
- **Audit Fields**: createdBy, lastUpdatedBy, timestamps
- **Address Management**: Comprehensive shipping/billing addresses
- **Payment Details**: Multiple payment methods, transaction data
- **Shipping Integration**: Carrier selection, tracking, delivery estimates  
- **Customer Profile**: Demographics, preferences, loyalty programs
- **Inventory Management**: Reservations, alternative products
- **Error Handling**: Standardized error responses with detailed context
- **Process Tracking**: Workflow status, step-by-step processing results

## Key Features

### Data Validation
- **Pattern Matching**: ID fields use regex patterns (e.g., `^ORD[0-9]{6,12}$`)
- **Range Validation**: Numeric fields with min/max constraints
- **Required Fields**: Explicit required/optional field specifications
- **Enum Values**: Controlled vocabularies for status fields
- **Format Validation**: Date, currency, and other format specifications

### Error Handling
- **Standardized Structure**: Consistent error response format across all APIs
- **Error Categories**: Authentication, validation, business logic, system errors
- **Field-Level Errors**: Detailed validation error information
- **Contextual Information**: Trace IDs, timestamps, suggested actions

### Extensibility
- **Metadata Fields**: Support for additional context information
- **Optional Properties**: Flexible data structures for future enhancements
- **Nested Objects**: Hierarchical data organization
- **Array Support**: Multiple items, addresses, payment methods

### Integration Support
- **HATEOAS Links**: Hypermedia navigation support
- **Pagination**: Cursor and page-based pagination
- **Filtering**: Multi-criteria search and filtering
- **Sorting**: Configurable sort options

## Usage Guidelines

### Including Data Types
```yaml
#%RAML 1.0
title: Order Management API
uses:
  experience: !include RAML DataTypes/OrderExperienceAPI.raml
  process: !include RAML DataTypes/OrderProcessAPI.raml  
  systems: !include RAML DataTypes/SystemAPIs.raml
  common: !include RAML Fragments/DataTypes/Order.raml
  errors: !include RAML Fragments/DataTypes/ErrorResponse.raml
```

### Example Usage
```yaml
/orders:
  post:
    body:
      application/json:
        type: experience.CreateOrderRequest
    responses:
      201:
        body:
          application/json:
            type: experience.CreateOrderResponse
      400:
        body:
          application/json:
            type: errors.ErrorResponse
```

## Validation Checklist

### Completeness ✅
- [x] All BRD Section 11 fields implemented
- [x] Experience API operations covered
- [x] Process API operations covered  
- [x] Customer System API operations covered
- [x] Inventory System API operations covered
- [x] Payment System API operations covered
- [x] Shipping System API operations covered
- [x] Error handling for all scenarios
- [x] Request/response pairs for all operations

### Consistency ✅
- [x] Naming conventions standardized
- [x] ID patterns consistent across all types
- [x] Status enumerations aligned
- [x] Date/time formats standardized (RFC3339)
- [x] Currency and monetary formats consistent
- [x] Error structures uniform across APIs

### Quality ✅
- [x] Comprehensive field documentation
- [x] Realistic example values provided
- [x] Proper type definitions (string, number, boolean, etc.)
- [x] Validation constraints defined
- [x] Optional vs required fields clearly marked
- [x] RAML syntax validated
- [x] No circular dependencies

## File Structure
```
RAML DataTypes/                      # New API Layer Data Types
├── README.md                        # This documentation
├── OrderExperienceAPI.raml          # Experience Layer APIs
├── OrderProcessAPI.raml             # Process Layer APIs  
└── SystemAPIs.raml                  # System Layer APIs

RAML Fragments/                      # Original Base Entity Types
├── DataTypes/
│   ├── Order.raml                   # Core order entity
│   ├── Customer.raml                # Customer entity
│   ├── Payment.raml                 # Payment entity
│   ├── Address.raml                 # Address entity
│   ├── OrderItem.raml               # Order item entity
│   ├── OrderHistory.raml            # Order history entity
│   ├── Shipment.raml                # Shipment entity
│   ├── ShipmentItem.raml            # Shipment item entity
│   └── ErrorResponse.raml           # Error response structure
└── Traits/
    └── SecurityTraits.raml          # Security-related traits
```

## Next Steps

1. **API Specification Creation**: Use these data types to create complete RAML API specifications
2. **Code Generation**: Generate client SDKs and server stubs from RAML definitions
3. **Testing**: Create comprehensive test suites using the defined data structures
4. **Documentation**: Generate API documentation from RAML specifications
5. **Validation**: Implement server-side validation using the defined constraints

## Maintenance Notes

- **Version Control**: All changes should maintain backward compatibility
- **Documentation**: Update this README when adding new data types
- **Validation**: Test RAML syntax before committing changes
- **Dependencies**: Monitor for changes in referenced base types
- **Standards**: Follow established naming and structure conventions
