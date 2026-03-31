# Order Management API Fragments

This repository contains reusable RAML fragments for Order Management APIs, designed to support Experience, Process, and System layer APIs in a MuleSoft API-Led Connectivity architecture.

## Overview

The fragments follow MuleSoft best practices and provide standardized data types, security traits, and error handling patterns that can be reused across multiple API specifications.

## Structure

```
order-management-api-fragments/
├── src/main/resources/api/
│   ├── datatypes/                 # Data type definitions
│   │   ├── order-types.raml       # Order and OrderItem types
│   │   ├── customer-types.raml    # Customer and related types
│   │   ├── payment-types.raml     # Payment and transaction types
│   │   ├── shipment-types.raml    # Shipping and tracking types
│   │   └── error-types.raml       # Error response structures
│   └── traits/                    # Security and behavioral traits
│       └── security-traits.raml   # OAuth 2.0 and security patterns
├── exchange.json                  # Exchange metadata
└── order-management-api-fragments.raml  # Main library file
```

## Data Type Libraries

### 1. Order Types (`order-types.raml`)

Contains comprehensive order management data structures:

- **Order**: Complete order information with customer, items, payment, and shipping
- **OrderItem**: Individual items within an order with product details
- **OrderSummary**: Lightweight order representation for list views
- **OrderRequest**: Request payload for creating orders
- **OrderStatusUpdate**: Request payload for status changes
- **Supporting Types**: Address, PaymentReference, TrackingInfo, Dimensions

**Key Features:**
- Pattern validation for IDs (e.g., `^ORD-[A-Z0-9]{8}$`)
- Comprehensive status enums
- Support for multiple currencies and tax calculations
- Extensible metadata fields

### 2. Customer Types (`customer-types.raml`)

Comprehensive customer management data structures:

- **Customer**: Complete customer profile with preferences and history
- **CustomerSummary**: Lightweight customer representation
- **CustomerAddress**: Extended address information
- **CustomerPreferences**: Communication, shipping, and marketing preferences
- **LoyaltyInfo**: Loyalty program details
- **MarketingConsent**: GDPR-compliant consent tracking

**Key Features:**
- Preference management for personalized experiences
- Consent tracking for compliance
- Support for B2B and B2C customers
- Extensible loyalty and credit systems

### 3. Payment Types (`payment-types.raml`)

Secure payment processing data structures:

- **PaymentInfo**: Complete payment transaction details
- **PaymentDetails**: Masked payment method information
- **ProcessorResponse**: Payment gateway response details
- **RiskAssessment**: Fraud detection and risk analysis
- **RefundRequest/Response**: Refund processing workflows

**Key Features:**
- PCI DSS compliant data masking
- Comprehensive fraud detection support
- Multi-processor support
- Detailed fee tracking

### 4. Shipment Types (`shipment-types.raml`)

Comprehensive shipping and logistics data structures:

- **Shipment**: Complete shipment with tracking and carrier details
- **TrackingInfo**: Real-time tracking information
- **CarrierInfo**: Multi-carrier support with contact information
- **ShipmentItem**: Individual items within shipments
- **PackageDimensions**: Physical package specifications
- **ShippingCosts**: Detailed cost breakdown with discounts
- **CustomsInfo**: International shipping customs data

**Key Features:**
- Multi-carrier tracking integration
- Real-time delivery updates
- International shipping support
- Cost optimization with discount tracking

### 5. Error Types (`error-types.raml`)

Standardized error response structures following RFC 7807:

- **ErrorResponse**: Base error structure for all APIs
- **ValidationErrorResponse**: Field-level validation errors
- **BusinessErrorResponse**: Business rule violations
- **SystemErrorResponse**: System-level failures
- **Layer-specific errors**: Experience, Process, System API errors

**Key Features:**
- RFC 7807 Problem Details compliance
- Consistent error structure across all APIs
- Correlation IDs for debugging
- User-friendly error messages

## Security Traits

### Security Traits Library (`security-traits.raml`)

Comprehensive security patterns for all API layers:

- **oauth2-secured**: OAuth 2.0 authorization with JWT tokens
- **client-credentials**: Server-to-server authentication
- **api-key-secured**: API key authentication for trusted systems
- **rate-limited**: Request rate limiting with headers
- **cors-enabled**: Cross-origin resource sharing
- **audit-logged**: Comprehensive audit logging
- **idempotent**: Idempotency key support

**Pre-configured Combinations:**
- **secured-experience-api**: OAuth + Rate limiting + CORS + Audit
- **secured-process-api**: Client credentials + Rate limiting + Audit
- **secured-system-api**: API key + Rate limiting + Audit

## Usage Examples

### 1. Using Data Types in API Specifications

```yaml
#%RAML 1.0
title: Order Experience API
version: v1
baseUri: https://api.company.com/orders/v1

uses:
  OrderTypes: exchange_modules/order-management-api-fragments/order-types.raml
  ErrorTypes: exchange_modules/order-management-api-fragments/error-types.raml
  SecurityTraits: exchange_modules/order-management-api-fragments/security-traits.raml

/orders:
  post:
    is: [secured-experience-api, idempotent]
    body:
      application/json:
        type: OrderTypes.OrderRequest
    responses:
      201:
        body:
          application/json:
            type: OrderTypes.Order
      400:
        body:
          application/json:
            type: ErrorTypes.ValidationErrorResponse
```

### 2. Using Security Traits

```yaml
#%RAML 1.0
title: Customer System API
version: v1

uses:
  SecurityTraits: exchange_modules/order-management-api-fragments/security-traits.raml

/customers:
  get:
    is: [secured-system-api]
    # Automatically applies: api-key-secured + rate-limited + audit-logged
```

### 3. Extending Data Types

```yaml
#%RAML 1.0
title: Extended Order API

uses:
  OrderTypes: exchange_modules/order-management-api-fragments/order-types.raml

types:
  ExtendedOrder:
    type: OrderTypes.Order
    properties:
      internalNotes:
        type: string
        description: Internal processing notes
        required: false
      riskScore:
        type: number
        description: Fraud risk score
        minimum: 0
        maximum: 100
        required: false
```

## Best Practices

### 1. API Layer Guidelines

**Experience APIs:**
- Use `secured-experience-api` trait
- Include user-friendly error messages
- Implement CORS for browser access
- Apply idempotency for state-changing operations

**Process APIs:**
- Use `secured-process-api` trait
- Include process step tracking in errors
- Implement compensation patterns for failures
- Use correlation IDs for cross-service tracing

**System APIs:**
- Use `secured-system-api` trait
- Include original system error details
- Implement retry logic for transient failures
- Use circuit breakers for resilience

### 2. Data Type Usage

**Required Fields:**
- Always validate required fields at API boundaries
- Use pattern validation for IDs and codes
- Implement proper enum constraints

**Optional Fields:**
- Design for forward compatibility
- Use meaningful defaults where appropriate
- Document field relationships and dependencies

### 3. Error Handling

**Error Responses:**
- Always include correlation IDs
- Use appropriate HTTP status codes
- Provide actionable error messages
- Include retry information when applicable

**Validation Errors:**
- Use field-level error details
- Include the invalid value in error responses
- Specify the location of validation errors

### 4. Security Implementation

**Authentication:**
- Use OAuth 2.0 for user-facing APIs
- Use Client Credentials for system APIs
- Implement proper token validation

**Authorization:**
- Use scope-based access control
- Include required permissions in error responses
- Implement least-privilege principle

## Validation and Testing

### RAML Validation

All fragments are validated against RAML 1.0 specifications:

```bash
# Validate individual fragments
raml-validator src/main/resources/api/datatypes/order-types.raml
raml-validator src/main/resources/api/traits/security-traits.raml

# Validate complete API specifications using fragments
raml-validator my-api.raml
```

### Testing with Examples

Each data type includes comprehensive examples:

```yaml
# Test payload validation
curl -X POST https://api.company.com/orders/v1/orders \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d '{
    "customerId": "CUST-87654321",
    "items": [{
      "productId": "PROD-12345678",
      "quantity": 2
    }],
    "shippingAddress": {
      "firstName": "John",
      "lastName": "Doe",
      "addressLine1": "123 Main St",
      "city": "New York",
      "state": "NY",
      "postalCode": "10001",
      "country": "US"
    },
    "source": "API"
  }'
```

## Version Management

### Fragment Versioning

- **Major Version**: Breaking changes to existing types
- **Minor Version**: New types or optional fields
- **Patch Version**: Bug fixes and documentation updates

### Compatibility

- Backward compatibility maintained within major versions
- Deprecation notices provided before breaking changes
- Migration guides provided for major version upgrades

### Exchange Publishing

```bash
# Publish to Anypoint Exchange
anypoint-cli exchange asset upload \
  --organization-id ${ORG_ID} \
  --group-id ${GROUP_ID} \
  --asset-id order-management-api-fragments \
  --version ${VERSION} \
  --name "Order Management API Fragments" \
  --classifier raml-fragment
```

## Support and Contributions

### Getting Help

- **Documentation**: See individual RAML files for detailed type documentation
- **Examples**: Check the `/examples` directory for usage samples
- **Issues**: Report issues via the project repository

### Contributing

1. Fork the repository
2. Create feature branch (`feature/new-data-type`)
3. Add comprehensive examples and documentation
4. Validate all RAML syntax
5. Submit pull request with detailed description

### Standards Compliance

- **RAML 1.0**: All fragments comply with RAML 1.0 specification
- **RFC 7807**: Error types follow Problem Details standard
- **OAuth 2.0**: Security traits implement standard OAuth flows
- **ISO Standards**: Currency codes (ISO 4217), country codes (ISO 3166)

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Changelog

### Version 1.0.0
- Initial release with complete Order Management data types
- OAuth 2.0 security traits
- RFC 7807 compliant error structures
- Comprehensive customer and payment types
- Multi-carrier shipping support
