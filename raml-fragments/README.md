# Order Management System - RAML Fragments

This repository contains reusable RAML fragments for the Order Management System (OMS) integration, organized following API-Led Connectivity principles with Experience, Process, and System layer APIs.

## 📁 Repository Structure

```
raml-fragments/
├── data-types/           # Reusable data type definitions
│   ├── Order.raml       # Complete order data structure
│   ├── Customer.raml    # Customer information structure
│   ├── Payment.raml     # Payment and transaction data
│   ├── Shipment.raml    # Shipping and tracking data
│   └── ErrorResponse.raml # Standardized error responses
├── security-schemes/     # Security and authentication
│   └── oauth2-security.raml # OAuth 2.0 configuration
├── traits/              # Reusable behavior patterns
│   └── common-traits.raml # Common API traits
├── examples/            # Example API implementations
│   └── order-experience-api.raml # Complete Experience API example
└── README.md           # This documentation
```

## 🎯 API-Led Connectivity Architecture

The RAML fragments support a three-layer API architecture:

### Experience Layer
- **Purpose:** Customer-facing interfaces optimized for user experience
- **Audience:** Mobile apps, web applications, partner integrations
- **Characteristics:** Aggregated data, simplified payloads, user-centric design
- **Example:** Order Experience API for customer order management

### Process Layer  
- **Purpose:** Business process orchestration and workflow management
- **Audience:** Experience APIs, business applications
- **Characteristics:** Business logic, multi-system coordination, process flows
- **Example:** Order Processing API for end-to-end order workflows

### System Layer
- **Purpose:** Direct connectivity to backend systems and databases
- **Audience:** Process APIs, system integrations
- **Characteristics:** System-specific operations, data transformation, connectivity
- **Example:** Customer System API, Inventory System API, Payment System API

## 📊 Data Types

### Order (`Order.raml`)
Complete order information including items, customer details, payment, and shipment data.

**Key Properties:**
- `orderId`: Unique order identifier (format: `ORD-YYYYMMDDHHMMSS`)
- `customerId`: Customer reference
- `status`: Order lifecycle status
- `items[]`: Array of ordered products with quantities and pricing
- `totalAmount`: Total order value
- `shippingAddress`: