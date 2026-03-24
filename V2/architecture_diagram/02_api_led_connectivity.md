# API-Led Connectivity Architecture

## Three-Layer API Architecture

```mermaid
graph TB
    subgraph "EXPERIENCE LAYER"
        subgraph "Order Experience API"
            EXP_POST[POST /orders<br/>Create Order]
            EXP_GET[GET /orders/{id}<br/>Get Order]
            EXP_LIST[GET /orders<br/>List Orders]
            EXP_PATCH[PATCH /orders/{id}/status<br/>Update Status]
        end
    end

    subgraph "PROCESS LAYER"
        subgraph "Order Processing API"
            PROC_VALIDATE[Validate Order Flow]
            PROC_ORCHESTRATE[Order Orchestration Flow]
            PROC_COMPENSATION[Compensation Flow]
            PROC_NOTIFICATION[Notification Flow]
        end
    end

    subgraph "SYSTEM LAYER"
        subgraph "Customer System API"
            SYS_CUST_VAL[Customer Validation]
            SYS_CUST_GET[Get Customer Data]
        end
        
        subgraph "Inventory System API"
            SYS_INV_CHECK[Check Inventory]
            SYS_INV_RESERVE[Reserve Stock]
            SYS_INV_RELEASE[Release Stock]
        end
        
        subgraph "Payment System API"
            SYS_PAY_AUTH[Authorize Payment]
            SYS_PAY_CAPTURE[Capture Payment]
            SYS_PAY_REFUND[Refund Payment]
        end
        
        subgraph "Shipping System API"
            SYS_SHIP_CREATE[Create Shipment]
            SYS_SHIP_TRACK[Track Shipment]
            SYS_SHIP_UPDATE[Update Status]
        end
    end

    %% Experience to Process connections
    EXP_POST --> PROC_VALIDATE
    EXP_POST --> PROC_ORCHESTRATE
    EXP_GET --> PROC_ORCHESTRATE
    EXP_LIST --> PROC_ORCHESTRATE
    EXP_PATCH --> PROC_NOTIFICATION

    %% Process to System connections
    PROC_VALIDATE --> SYS_CUST_VAL
    PROC_VALIDATE --> SYS_INV_CHECK
    
    PROC_ORCHESTRATE --> SYS_CUST_GET
    PROC_ORCHESTRATE --> SYS_INV_RESERVE
    PROC_ORCHESTRATE --> SYS_PAY_AUTH
    PROC_ORCHESTRATE --> SYS_SHIP_CREATE
    
    PROC_COMPENSATION --> SYS_INV_RELEASE
    PROC_COMPENSATION --> SYS_PAY_REFUND
    
    PROC_NOTIFICATION --> SYS_SHIP_UPDATE

    style EXP_POST fill:#e1f5fe
    style EXP_GET fill:#e1f5fe
    style EXP_LIST fill:#e1f5fe
    style EXP_PATCH fill:#e1f5fe
    style PROC_VALIDATE fill:#f3e5f5
    style PROC_ORCHESTRATE fill:#f3e5f5
    style PROC_COMPENSATION fill:#f3e5f5
    style PROC_NOTIFICATION fill:#f3e5f5
```

## Layer Responsibilities

### Experience Layer
**Purpose**: Provides consumer-centric APIs optimized for specific channel requirements

**Order Experience API Functions**:
- **POST /orders**: Accept order creation requests from various channels
- **GET /orders/{id}**: Retrieve specific order details with enriched data
- **GET /orders**: List orders with filtering and pagination
- **PATCH /orders/{id}/status**: Update order status from external events

**Key Characteristics**:
- Channel-optimized response formats
- Data aggregation from multiple sources
- Consumer-specific business logic
- Security and rate limiting

### Process Layer
**Purpose**: Orchestrates business processes and implements business logic

**Order Processing API Functions**:
- **Validate Order Flow**: Pre-processing validation logic
- **Order Orchestration Flow**: End-to-end order processing coordination  
- **Compensation Flow**: Rollback logic for failed transactions
- **Notification Flow**: Event handling for status updates

**Key Characteristics**:
- Business process orchestration
- Cross-system transaction coordination
- Error handling and compensation
- Event-driven processing

### System Layer  
**Purpose**: Provides standardized interfaces to enterprise systems

**System APIs Include**:

#### Customer System API
- Customer validation and authentication
- Customer profile retrieval
- Customer preference management

#### Inventory System API  
- Real-time inventory checking
- Stock reservation and release
- Product catalog integration

#### Payment System API
- Payment authorization and capture
- Refund processing
- Payment status tracking

#### Shipping System API
- Shipment creation and scheduling
- Tracking number generation
- Delivery status updates

## API Design Principles

### Reusability
- System APIs designed for multiple consumption patterns
- Standardized data models across layers
- Consistent error handling patterns

### Maintainability  
- Clear separation of concerns between layers
- Modular design allowing independent updates
- Comprehensive API documentation

### Scalability
- Horizontal scaling at each layer
- Caching strategies for frequently accessed data
- Load balancing and traffic distribution

### Security
- Authentication at Experience layer
- Authorization at each API endpoint  
- Encryption in transit and at rest
- API key management and rotation