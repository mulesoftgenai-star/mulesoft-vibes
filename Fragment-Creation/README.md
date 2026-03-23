# Order Management System RAML Fragments

This collection provides reusable RAML fragments for building Order Management APIs following API-Led Connectivity principles with standardized data types, security traits, and error handling across Experience, Process, and System layers.

## 📁 Directory Structure

```
Fragment-Creation/
├── data-types/                    # Reusable data type definitions
│   ├── order-data-type.raml      # Complete Order entity
│   ├── customer-data-type.raml   # Customer profile data
│   ├── payment-data-type.raml    # Payment transaction data
│   └── shipment-data-type.raml   # Shipping and logistics data
├── security-traits/               # Authentication and authorization
│   └── oauth2-security-trait.raml # OAuth 2.0 security implementation
├── error-responses/               # Standardized error structures
│   ├── experience-layer-errors.raml  # Consumer-facing error responses
│   ├── process-layer-errors.raml     # Orchestration error responses
│   └── system-layer-errors.raml      # System integration error responses
└── README.md                      # This documentation
```

## 🎯 Purpose

These fragments support the Order Management System integration requirements by providing:

- **Consistent Data Models**: Standardized data types across all API layers
- **Security Standardization**: OAuth 2.0 implementation with comprehensive error handling
- **Error Management**: Layer-specific error responses with appropriate detail levels
- **Reusability**: DRY principle implementation across multiple APIs
- **Maintainability**: Centralized definitions for easy updates and consistency

## 📊 Data Types

### Order Data Type (`order-data-type.raml`)

Comprehensive order structure supporting the complete order lifecycle:

- **Order Identification**: Unique IDs, order numbers, and business references
- **Customer Association**: Customer ID references and validation
- **Line Items**: Product details, quantities, pricing, and discounts
- **Billing & Pricing**: Subtotals, taxes, shipping, and final amounts
- **Shipping Information**: Addresses, methods, tracking, and delivery status
- **Payment Details**: Payment methods, status, and transaction references
- **Audit Trail**: Creation, modification, and version tracking
- **External References**: ERP, CRM, and legacy system mappings

**Key Features:**
- Supports B2B and B2C scenarios
- Flexible order types (Standard, Express, Bulk, Subscription, Gift)
- Multi-channel support (Web, Mobile, Phone, Email, Partner, Store)
- Comprehensive status tracking throughout order lifecycle

### Customer Data Type (`customer-data-type.raml`)

Unified customer profile supporting both individual and business customers:

- **Identity Management**: Customer IDs, numbers, and type classification
- **Personal Information**: Names, demographics, and contact preferences
- **Business Information**: Company details, tax IDs, and D-U-N-S numbers
- **Contact Details**: Multi-channel communication preferences
- **Address Management**: Multiple address types with validation
- **Loyalty Programs**: Membership tiers, points, and benefits
- **Credit Information**: Limits, ratings, and payment terms
- **Preferences**: Communication, shipping, and service preferences

### Payment Data Type (`payment-data-type.raml`)

Complete payment transaction lifecycle management:

- **Payment Methods**: Cards, digital wallets, bank transfers, and alternative payments
- **Transaction Lifecycle**: Authorization, capture, settlement, and reconciliation
- **Security Features**: Tokenization, 3D Secure, fraud detection
- **Refund Management**: Partial and full refunds with reason tracking
- **Fee Tracking**: Processing, gateway, and transaction fees
- **Risk Management**: Fraud scores, CVV/AVS validation, and decision tracking

### Shipment Data Type (`shipment-data-type.raml`)

Comprehensive shipping and logistics data structure:

- **Carrier Integration**: Multiple carrier support with service types
- **Address Management**: Origin and destination with validation
- **Package Details**: Items, dimensions, weights, and special handling
- **Tracking**: Real-time status updates and event history
- **Cost Management**: Shipping costs, insurance, and additional fees
- **Performance Metrics**: Delivery timelines and service quality

## 🔐 Security Traits

### OAuth 2.0 Security Trait (`oauth2-security-trait.raml`)

Standardized authentication and authorization implementation:

- **Bearer Token Authentication**: JWT token validation
- **Client Identification**: Application-level tracking and analytics
- **Request Correlation**: UUID-based request tracing
- **Rate Limiting**: Configurable rate limits with quota management
- **Error Responses**: Comprehensive security error handling
- **Scope-Based Authorization**: Fine-grained permission control

**Usage Example:**
```yaml
#%RAML 1.0
title: Order Management API
version: v1
traits:
  oauth2-secured: !include fragments/security-traits/oauth2-security-trait.raml

/orders:
  get:
    is: [oauth2-secured]
    description: Retrieve orders with OAuth 2.0 authentication
```

## 🚨 Error Response Structures

### Experience Layer Errors (`experience-layer-errors.raml`)

Consumer-facing error responses with user-friendly messaging:

- **User-Friendly Messages**: Clear guidance for end users
- **Validation Details**: Field-level validation errors
- **Actionable Suggestions**: Recovery recommendations
- **Support Integration**: Reference numbers for customer service
- **Context Information**: User session and client application data

### Process Layer Errors (`process-layer-errors.raml`)

Orchestration and workflow error responses for technical teams:

- **Process Context**: Workflow steps and business process information
- **System Failures**: Individual system failure details and retry information
- **Rollback Management**: Transaction compensation and recovery actions
- **Performance Metrics**: Execution times and circuit breaker status
- **Diagnostic Information**: Distributed tracing and troubleshooting guides

### System Layer Errors (`system-layer-errors.raml`)

Low-level system integration errors for infrastructure teams:

- **Technical Details**: Stack traces, error classes, and system metrics
- **Connection Information**: Database pools, timeouts, and resource usage
- **Recoverability**: Retry strategies and estimated recovery times
- **Resource Context**: Database tables, query types, and system operations

## 📝 Usage Examples

### Complete API Specification Example

```yaml
#%RAML 1.0
title: Order Management Experience API
version: v1
baseUri: https://api.company.com/experience/orders/v1

# Import fragments
uses:
  Order: data-types/order-data-type.raml
  Customer: data-types/customer-data-type.raml
  Payment: data-types/payment-data-type.raml
  Shipment: data-types/shipment-data-type.raml
  ExperienceErrors: error-responses/experience-layer-errors.raml

# Import security traits
traits:
  oauth2-secured: !include security-traits/oauth2-security-trait.raml

/orders:
  post:
    is: [oauth2-secured]
    description: Create a new order
    body:
      application/json:
        type: Order
        example: |
          {
            "orderId": "ORD-12345678",
            "customerId": "CUST-87654321",
            "orderDate": "2024-03-23T13:42:27",
            "orderStatus": "PENDING",
            "orderItems": [
              {
                "lineItemId": "LI-11223344",
                "productId": "PROD-55667788",
                "quantity": 2,
                "unitPrice": 199.99,
                "totalPrice": 399.98
              }
            ],
            "billing": {
              "subtotal": 399.98,
              "taxAmount": 32.00,
              "shippingAmount": 9.99,
              "totalAmount": 441.97
            }
          }
    responses:
      201:
        description: Order created successfully
        body:
          application/json:
            type: Order
      400:
        description: Invalid order data
        body:
          application/json:
            type: ExperienceErrors
      401:
        description: Authentication required
      403:
        description: Insufficient permissions
      429:
        description: Rate limit exceeded

  get:
    is: [oauth2-secured]
    description: Retrieve orders with pagination
    queryParameters:
      customerId:
        type: string
        pattern: ^CUST-[0-9]{8}$
        description: Filter by customer ID
        required: false
      status:
        type: string
        enum: ["PENDING", "CONFIRMED", "PROCESSING", "SHIPPED", "DELIVERED", "CANCELLED"]
        description: Filter by order status
        required: false
      limit:
        type: integer
        minimum: 1
        maximum: 100
        default: 20
        description: Number of results per page
      offset:
        type: integer
        minimum: 0
        default: 0
        description: Number of results to skip
    responses:
      200:
        description: Orders retrieved successfully
        body:
          application/json:
            type: object
            properties:
              orders:
                type: array
                items:
                  type: Order
              pagination:
                type: object
                properties:
                  totalCount: integer
                  limit: integer
                  offset: integer
                  hasMore: boolean

  /{orderId}:
    get:
      is: [oauth2-secured]
      description: Retrieve specific order details
      responses:
        200:
          description: Order retrieved successfully
          body:
            application/json:
              type: Order
        404:
          description: Order not found
          body:
            application/json:
              type: ExperienceErrors
```

### Process Layer API Example

```yaml
#%RAML 1.0
title: Order Processing API
version: v1
baseUri: https://internal-api.company.com/process/orders/v1

uses:
  Order: data-types/order-data-type.raml
  ProcessErrors: error-responses/process-layer-errors.raml

/order-processing:
  post:
    description: Process order through orchestration workflow
    body:
      application/json:
        type: Order
    responses:
      200:
        description: Order processed successfully
        body:
          application/json:
            type: object
            properties:
              transactionId: string
              processedOrder: Order
              processingTime: integer
      500:
        description: Orchestration failure
        body:
          application/json:
            type: ProcessErrors
```

### System Layer API Example

```yaml
#%RAML 1.0
title: Customer System API
version: v1
baseUri: https://internal-api.company.com/system/customers/v1

uses:
  Customer: data-types/customer-data-type.raml
  SystemErrors: error-responses/system-layer-errors.raml

/customers:
  /{customerId}:
    get:
      description: Retrieve customer from database
      responses:
        200:
          description: Customer retrieved successfully
          body:
            application/json:
              type: Customer
        404:
          description: Customer not found
          body:
            application/json:
              type: SystemErrors
        503:
          description: Database unavailable
          body:
            application/json:
              type: SystemErrors
```

## 🚀 Implementation Guidelines

### 1. Fragment Import Best Practices

```yaml
# Use consistent naming conventions for imported fragments
uses:
  OrderType: data-types/order-data-type.raml
  CustomerType: data-types/customer-data-type.raml
  PaymentType: data-types/payment-data-type.raml
  ShipmentType: data-types/shipment-data-type.raml

# Apply consistent trait naming
traits:
  secured: !include security-traits/oauth2-security-trait.raml
```

### 2. Error Handling Implementation

```yaml
# Layer-appropriate error responses
responses:
  400:
    body:
      application/json:
        type: !include error-responses/experience-layer-errors.raml
  500:
    body:
      application/json:
        type: !include error-responses/process-layer-errors.raml
  503:
    body:
      application/json:
        type: !include error-responses/system-layer-errors.raml
```

### 3. Data Type Composition

```yaml
# Compose complex types from fragments
type: object
properties:
  order: OrderType
  customer: CustomerType
  payment: PaymentType
  shipment: ShipmentType
```

## 📋 Validation and Testing

All fragments have been designed with comprehensive validation rules:

- **Data Types**: Pattern validation, range constraints, and business rules
- **Security Traits**: Token format validation and correlation ID requirements
- **Error Responses**: Structured error information with appropriate detail levels

## 🔧 Maintenance and Updates

### Version Control
- All fragments follow semantic versioning
- Breaking changes require major version updates
- Backward compatibility maintained for minor updates

### Documentation Updates
- Fragment documentation updated with each release
- Usage examples validated against latest RAML specifications
- Integration patterns documented and tested

## 📚 Reference Documentation

- [RAML 1.0 Specification](https://github.com/raml-org/raml-spec/blob/master/versions/raml-10/raml-10.md)
- [API-Led Connectivity](https://www.mulesoft.com/resources/api-led-connectivity)
- [OAuth 2.0 RFC 6749](https://tools.ietf.org/html/rfc6749)
- [HTTP Status Code Registry](https://www.iana.org/assignments/http-status-codes/http-status-codes.xhtml)

## 📞 Support and Contribution

For questions, issues, or contributions to these fragments:
- Review existing implementations and patterns
- Follow established naming conventions
- Ensure backward compatibility
- Document any breaking changes
- Test fragments with real API implementations

---

**Created**: March 23, 2026  
**Last Updated**: March 23, 2026  
**Version**: 1.0.0  
**Maintainer**: Integration Architecture Team