# Data Flow Diagrams

## Overview

This document presents detailed data flow diagrams for key business processes in the Order Management System integration, showing end-to-end data movement, transformation, and system interactions.

## 1. Order Creation Data Flow

### Complete Order Creation Process

```mermaid
sequenceDiagram
    participant C as Customer (Web/Mobile)
    participant AG as API Gateway
    participant OE as Order Experience API
    participant OP as Order Processing API
    participant CS as Customer System API
    participant IS as Inventory System API
    participant PP as Payment Processing API
    participant OS as OMS System API
    participant SP as Shipping Processing API
    participant NS as Notification Service
    
    C->>AG: POST /orders (Order Request)
    Note over C,AG: Customer initiates order creation
    
    AG->>OE: Validate & Route Request
    Note over AG: Security policies, rate limiting
    
    OE->>OP: Process Order Request
    Note over OE,OP: Transform to canonical format
    
    OP->>CS: Validate Customer
    CS-->>OP: Customer Details & Status
    
    OP->>IS: Check Inventory Availability
    IS-->>OP: Stock Status & Reservation
    
    alt Inventory Available
        OP->>PP: Initiate Payment Authorization
        PP-->>OP: Payment Authorization Response
        
        alt Payment Authorized
            OP->>OS: Create Order in OMS
            OS-->>OP: Order Created (Order ID)
            
            OP->>SP: Create Shipment Request
            SP-->>OP: Shipment Details
            
            OP->>NS: Send Order Confirmation
            NS-->>C: Email/SMS Notification
            
            OP-->>OE: Order Success Response
            OE-->>AG: Transform Response
            AG-->>C: Order Confirmation (Order ID)
            
        else Payment Failed
            OP->>IS: Release Inventory Reservation
            OP-->>OE: Payment Failed Response
            OE-->>AG: Transform Error Response
            AG-->>C: Payment Error Response
        end
        
    else Inventory Not Available
        OP-->>OE: Inventory Error Response
        OE-->>AG: Transform Error Response
        AG-->>C: Out of Stock Response
    end
```

### Order Request Data Transformation

```mermaid
graph LR
    subgraph "Customer Request Format"
        CR[Customer Request<br/>{<br/>  customerId: "12345",<br/>  items: [<br/>    {<br/>      productId: "P001",<br/>      quantity: 2,<br/>      price: 29.99<br/>    }<br/>  ],<br/>  shippingAddress: {...}<br/>}]
    end
    
    subgraph "MuleSoft Transformation"
        DW[DataWeave Transformation<br/>- Validate request structure<br/>- Enrich with customer data<br/>- Calculate totals<br/>- Add timestamps]
    end
    
    subgraph "Canonical Order Format"
        CO[Canonical Order<br/>{<br/>  orderId: "ORD-2026-001",<br/>  customerId: "12345",<br/>  orderDate: "2026-03-23T...",<br/>  items: [...],<br/>  totalAmount: 59.98,<br/>  status: "PENDING",<br/>  workflow: "STANDARD"<br/>}]
    end
    
    subgraph "Backend System Formats"
        OMS_F[OMS Format<br/>Database Schema]
        INV_F[Inventory Format<br/>REST API JSON]
        PAY_F[Payment Format<br/>Gateway Specific]
    end
    
    CR --> DW
    DW --> CO
    CO --> OMS_F
    CO --> INV_F
    CO --> PAY_F
    
    classDef input fill:#e3f2fd
    classDef transform fill:#f3e5f5
    classDef canonical fill:#e8f5e8
    classDef output fill:#fff3e0
    
    class CR input
    class DW transform
    class CO canonical
    class OMS_F,INV_F,PAY_F output
```

## 2. Order Status Update Data Flow

### Real-time Order Status Updates

```mermaid
sequenceDiagram
    participant SS as Shipping System
    participant SA as Shipping System API
    participant MQ as Anypoint MQ
    participant OP as Order Processing API
    participant OS as OMS System API
    participant NS as Notification Service
    participant C as Customer
    
    SS->>SA: Shipment Status Update
    Note over SS,SA: External logistics provider update
    
    SA->>MQ: Publish Status Event
    Note over SA,MQ: Async event publishing
    
    MQ->>OP: Consume Status Event
    Note over MQ,OP: Event-driven processing
    
    OP->>OS: Update Order Status
    OS-->>OP: Status Updated Confirmation
    
    OP->>MQ: Publish Order Updated Event
    
    MQ->>NS: Consume Notification Event
    
    par Customer Notifications
        NS->>C: Email Notification
    and
        NS->>C: SMS Notification
    and
        NS->>C: Push Notification
    end
    
    Note over C: Customer receives multi-channel updates
```

### Event-Driven Status Flow

```mermaid
graph TB
    subgraph "Event Sources"
        SHIP_EVENT[Shipping Status Change]
        PAY_EVENT[Payment Status Change]
        INV_EVENT[Inventory Status Change]
        OMS_EVENT[Order Management Event]
    end
    
    subgraph "Anypoint MQ Event Broker"
        ORDER_TOPIC[order-status-events<br/>Topic Exchange]
        
        subgraph "Event Queues"
            NOTIF_Q[notification-queue]
            AUDIT_Q[audit-queue]
            ANALYTICS_Q[analytics-queue]
        end
    end
    
    subgraph "Event Consumers"
        NOTIF_SVC[Notification Service<br/>Real-time alerts]
        AUDIT_SVC[Audit Service<br/>Compliance logging]
        ANALYTICS_SVC[Analytics Service<br/>Business intelligence]
    end
    
    SHIP_EVENT --> ORDER_TOPIC
    PAY_EVENT --> ORDER_TOPIC
    INV_EVENT --> ORDER_TOPIC
    OMS_EVENT --> ORDER_TOPIC
    
    ORDER_TOPIC --> NOTIF_Q
    ORDER_TOPIC --> AUDIT_Q
    ORDER_TOPIC --> ANALYTICS_Q
    
    NOTIF_Q --> NOTIF_SVC
    AUDIT_Q --> AUDIT_SVC
    ANALYTICS_Q --> ANALYTICS_SVC
    
    classDef eventSource fill:#e3f2fd
    classDef broker fill:#f3e5f5
    classDef queue fill:#fff3e0
    classDef consumer fill:#e8f5e8
    
    class SHIP_EVENT,PAY_EVENT,INV_EVENT,OMS_EVENT eventSource
    class ORDER_TOPIC broker
    class NOTIF_Q,AUDIT_Q,ANALYTICS_Q queue
    class NOTIF_SVC,AUDIT_SVC,ANALYTICS_SVC consumer
```

## 3. Payment Processing Data Flow

### Secure Payment Authorization Flow

```mermaid
sequenceDiagram
    participant OP as Order Processing API
    participant PP as Payment Processing API
    participant VAULT as Token Vault
    participant STRIPE as Stripe Gateway
    participant PAYPAL as PayPal Gateway
    participant BANK as Bank API
    participant FRAUD as Fraud Detection
    
    OP->>PP: Payment Authorization Request
    Note over OP,PP: Contains payment method & amount
    
    PP->>VAULT: Retrieve Payment Token
    VAULT-->>PP: Secure Payment Token
    
    PP->>FRAUD: Risk Assessment
    FRAUD-->>PP: Fraud Score & Decision
    
    alt Low Risk Transaction
        alt Credit Card Payment
            PP->>STRIPE: Process Card Payment
            STRIPE-->>PP: Authorization Response
        else PayPal Payment
            PP->>PAYPAL: Process PayPal Payment
            PAYPAL-->>PP: Authorization Response
        else ACH/Bank Transfer
            PP->>BANK: Process Bank Transfer
            BANK-->>PP: Authorization Response
        end
        
        PP-->>OP: Payment Authorized
        Note over PP,OP: Success with transaction ID
        
    else High Risk Transaction
        PP-->>OP: Payment Declined
        Note over PP,OP: Risk-based decline
    end
```

### Payment Data Security Flow

```mermaid
graph TB
    subgraph "Data Input"
        CC[Credit Card Data<br/>PAN, CVV, Expiry]
        CUSTOMER[Customer Data<br/>Name, Address, Email]
    end
    
    subgraph "Security Layer"
        TOKENIZER[Payment Tokenization<br/>Replace PAN with Token]
        ENCRYPTOR[Field Encryption<br/>AES-256 Encryption]
        VALIDATOR[Data Validation<br/>Format & Checksum]
    end
    
    subgraph "Secure Storage"
        TOKEN_VAULT[Token Vault<br/>PCI Compliant Storage]
        ENCRYPTED_DATA[Encrypted Customer Data<br/>GDPR Compliant]
    end
    
    subgraph "Processing"
        PAYMENT_API[Payment Processing API<br/>Uses Tokens Only]
        GATEWAY_COMM[Gateway Communication<br/>TLS 1.3 + mTLS]
    end
    
    CC --> TOKENIZER
    CUSTOMER --> ENCRYPTOR
    TOKENIZER --> VALIDATOR
    ENCRYPTOR --> VALIDATOR
    
    VALIDATOR --> TOKEN_VAULT
    VALIDATOR --> ENCRYPTED_DATA
    
    TOKEN_VAULT --> PAYMENT_API
    ENCRYPTED_DATA --> PAYMENT_API
    
    PAYMENT_API --> GATEWAY_COMM
    
    classDef input fill:#ffcdd2
    classDef security fill:#c8e6c9
    classDef storage fill:#e1bee7
    classDef processing fill:#b3e5fc
    
    class CC,CUSTOMER input
    class TOKENIZER,ENCRYPTOR,VALIDATOR security
    class TOKEN_VAULT,ENCRYPTED_DATA storage
    class PAYMENT_API,GATEWAY_COMM processing
```

## 4. Inventory Synchronization Data Flow

### Real-time Inventory Updates

```mermaid
sequenceDiagram
    participant WMS as Warehouse Management
    participant IS as Inventory System API
    participant CACHE as Object Store Cache
    participant OP as Order Processing API
    participant MQ as Anypoint MQ
    participant ANALYTICS as Analytics Service
    
    WMS->>IS: Inventory Level Update
    Note over WMS,IS: Real-time stock changes
    
    IS->>CACHE: Update Cached Inventory
    CACHE-->>IS: Cache Updated
    
    IS->>MQ: Publish Inventory Event
    Note over IS,MQ: Event: stock level changed
    
    MQ->>OP: Inventory Change Notification
    Note over MQ,OP: For pending order validation
    
    MQ->>ANALYTICS: Inventory Analytics Event
    Note over MQ,ANALYTICS: For demand forecasting
    
    par Concurrent Inventory Checks
        OP->>CACHE: Check Product Availability
        CACHE-->>OP: Current Stock Levels
    and
        OP->>IS: Reserve Inventory
        IS-->>OP: Reservation Confirmation
    end
```

### Multi-Location Inventory Aggregation

```mermaid
graph TB
    subgraph "Warehouse Locations"
        WH1[Warehouse East<br/>NYC - 150 units]
        WH2[Warehouse West<br/>LA - 200 units]
        WH3[Warehouse Central<br/>CHI - 75 units]
        WH4[Warehouse South<br/>ATL - 125 units]
    end
    
    subgraph "Inventory Aggregation Layer"
        AGG[Inventory Aggregation Service<br/>Real-time Consolidation]
        RULES[Business Rules Engine<br/>- Location preferences<br/>- Shipping costs<br/>- Delivery time]
    end
    
    subgraph "Availability Response"
        TOTAL[Total Available: 550 units]
        ALLOCATION[Optimal Allocation:<br/>Primary: NYC (150)<br/>Secondary: LA (200)<br/>Tertiary: ATL (125)]
    end
    
    subgraph "Caching Layer"
        L1_CACHE[L1 Cache<br/>Individual Locations<br/>TTL: 30 seconds]
        L2_CACHE[L2 Cache<br/>Aggregated View<br/>TTL: 5 minutes]
    end
    
    WH1 --> AGG
    WH2 --> AGG
    WH3 --> AGG
    WH4 --> AGG
    
    AGG --> RULES
    AGG --> L1_CACHE
    
    RULES --> TOTAL
    RULES --> ALLOCATION
    
    L1_CACHE --> L2_CACHE
    L2_CACHE --> ALLOCATION
    
    classDef warehouse fill:#e3f2fd
    classDef aggregation fill:#f3e5f5
    classDef result fill:#e8f5e8
    classDef cache fill:#fff3e0
    
    class WH1,WH2,WH3,WH4 warehouse
    class AGG,RULES aggregation
    class TOTAL,ALLOCATION result
    class L1_CACHE,L2_CACHE cache
```

## 5. Customer Data Synchronization

### Customer Profile Data Flow

```mermaid
sequenceDiagram
    participant CRM as CRM System
    participant CDC as Change Data Capture
    participant CS as Customer System API
    participant CACHE as Customer Cache
    participant DW as Data Warehouse
    participant CE as Customer Experience API
    
    CRM->>CDC: Customer Profile Update
    Note over CRM,CDC: Real-time change detection
    
    CDC->>CS: Profile Change Event
    CS->>CACHE: Update Customer Cache
    
    par Data Distribution
        CS->>DW: Sync to Data Warehouse
        DW-->>CS: Sync Confirmation
    and
        CS->>CE: Profile Update Notification
        CE-->>CS: Update Acknowledged
    end
    
    Note over CACHE: Customer data available<br/>for real-time access
```

### Customer Data Consistency Model

```mermaid
graph TB
    subgraph "Source Systems"
        CRM[CRM System<br/>Master Customer Data]
        ECOM[E-commerce Platform<br/>Shopping Preferences]
        SUPPORT[Support System<br/>Service History]
        LOYALTY[Loyalty Program<br/>Points & Rewards]
    end
    
    subgraph "Integration Layer"
        MDM[Master Data Management<br/>Customer 360 View]
        CONFLICT_RES[Conflict Resolution<br/>Data Quality Rules]
        VERSION_CTRL[Version Control<br/>Change Tracking]
    end
    
    subgraph "Canonical Customer Model"
        PROFILE[Customer Profile<br/>- Demographics<br/>- Contact Info<br/>- Preferences]
        HISTORY[Customer History<br/>- Orders<br/>- Support<br/>- Interactions]
        SEGMENTS[Customer Segments<br/>- VIP Status<br/>- Preferences<br/>- Behavior]
    end
    
    subgraph "Consumer Systems"
        ORDER_SYS[Order Management]
        MARKETING[Marketing Automation]
        ANALYTICS_SYS[Customer Analytics]
    end
    
    CRM --> MDM
    ECOM --> MDM
    SUPPORT --> MDM
    LOYALTY --> MDM
    
    MDM --> CONFLICT_RES
    CONFLICT_RES --> VERSION_CTRL
    
    VERSION_CTRL --> PROFILE
    VERSION_CTRL --> HISTORY
    VERSION_CTRL --> SEGMENTS
    
    PROFILE --> ORDER_SYS
    HISTORY --> MARKETING
    SEGMENTS --> ANALYTICS_SYS
    
    classDef source fill:#e3f2fd
    classDef integration fill:#f3e5f5
    classDef canonical fill:#e8f5e8
    classDef consumer fill:#fff3e0
    
    class CRM,ECOM,SUPPORT,LOYALTY source
    class MDM,CONFLICT_RES,VERSION_CTRL integration
    class PROFILE,HISTORY,SEGMENTS canonical
    class ORDER_SYS,MARKETING,ANALYTICS_SYS consumer
```

## 6. Error Handling & Compensation Flow

### Transaction Compensation Pattern

```mermaid
sequenceDiagram
    participant OP as Order Processing API
    participant IS as Inventory System API
    participant PP as Payment Processing API
    participant OS as OMS System API
    participant COMP as Compensation Handler
    
    OP->>IS: Reserve Inventory
    IS-->>OP: Reservation Success
    
    OP->>PP: Authorize Payment
    PP-->>OP: Payment Success
    
    OP->>OS: Create Order
    OS-->>OP: Order Creation Failed
    Note over OS,OP: Database constraint violation
    
    OP->>COMP: Initiate Compensation
    
    par Compensation Actions
        COMP->>PP: Void Payment Authorization
        PP-->>COMP: Payment Voided
    and
        COMP->>IS: Release Inventory Reservation
        IS-->>COMP: Inventory Released
    end
    
    COMP-->>OP: Compensation Complete
    OP-->>OP: Log Transaction Failure
    
    Note over OP: Return error to client<br/>All changes rolled back
```

### Circuit Breaker Data Flow

```mermaid
stateDiagram-v2
    state "System Health Monitoring" as SHM {
        [*] --> Healthy
        Healthy --> Degraded : Error rate > 10%
        Degraded --> Failed : Error rate > 50%
        Failed --> Recovering : Manual intervention
        Recovering --> Healthy : Error rate < 5%
        Degraded --> Healthy : Error rate < 5%
    }
    
    state "Request Processing" as RP {
        [*] --> Allow_All_Requests
        Allow_All_Requests --> Throttle_Requests : System Degraded
        Throttle_Requests --> Reject_Requests : System Failed
        Reject_Requests --> Test_Requests : System Recovering
        Test_Requests --> Allow_All_Requests : System Healthy
    }
    
    SHM --> RP : State Change Event
```

## Data Quality & Validation

### Input Validation Pipeline

```mermaid
graph TB
    subgraph "Input Data"
        API_REQ[API Request<br/>JSON Payload]
        FILE_INPUT[File Upload<br/>CSV/XML Data]
        EVENT_DATA[Event Message<br/>MQ Payload]
    end
    
    subgraph "Validation Layers"
        SCHEMA_VAL[Schema Validation<br/>JSON Schema/XSD]
        BUSINESS_VAL[Business Rules<br/>Domain Validation]
        DATA_QUALITY[Data Quality Checks<br/>Completeness/Accuracy]
    end
    
    subgraph "Enrichment & Transformation"
        LOOKUP[Reference Data Lookup<br/>Code Translation]
        CALC[Calculated Fields<br/>Totals/Derived Values]
        FORMAT[Format Standardization<br/>Date/Currency/Address]
    end
    
    subgraph "Output Processing"
        CANONICAL[Canonical Format<br/>Standard Schema]
        ROUTING[Data Routing<br/>Target System Selection]
        DELIVERY[Data Delivery<br/>Reliable Transmission]
    end
    
    API_REQ --> SCHEMA_VAL
    FILE_INPUT --> SCHEMA_VAL
    EVENT_DATA --> SCHEMA_VAL
    
    SCHEMA_VAL --> BUSINESS_VAL
    BUSINESS_VAL --> DATA_QUALITY
    
    DATA_QUALITY --> LOOKUP
    LOOKUP --> CALC
    CALC --> FORMAT
    
    FORMAT --> CANONICAL
    CANONICAL --> ROUTING
    ROUTING --> DELIVERY
    
    classDef input fill:#e3f2fd
    classDef validation fill:#f3e5f5
    classDef enrichment fill:#e8f5e8
    classDef output fill:#fff3e0
    
    class API_REQ,FILE_INPUT,EVENT_DATA input
    class SCHEMA_VAL,BUSINESS_VAL,DATA_QUALITY validation
    class LOOKUP,CALC,FORMAT enrichment
    class CANONICAL,ROUTING,DELIVERY output
```

These comprehensive data flow diagrams illustrate the detailed movement and transformation of data throughout the Order Management System integration, providing clear visibility into how information flows between systems, is transformed, validated, and processed to ensure data integrity and business process execution.
