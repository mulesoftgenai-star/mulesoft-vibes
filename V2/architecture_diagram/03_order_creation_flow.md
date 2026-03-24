# Order Creation Flow - Detailed System Interaction

## Order Creation Sequence Diagram

```mermaid
sequenceDiagram
    participant Client as Client Application
    participant AGW as API Gateway
    participant OEXP as Order Experience API
    participant OPROC as Order Processing API
    participant CSYS as Customer System API
    participant ISYS as Inventory System API
    participant PSYS as Payment System API
    participant OMS as Order Management System
    participant SSYS as Shipping System API
    participant SHIP as Shipping System

    Note over Client, SHIP: Order Creation Flow - Success Scenario

    Client->>+AGW: POST /orders (Order Request)
    Note right of AGW: Security Validation<br/>Rate Limiting<br/>OAuth Token Check
    
    AGW->>+OEXP: POST /orders (Validated Request)
    Note right of OEXP: Request Transformation<br/>Data Enrichment
    
    OEXP->>+OPROC: Process Order Request
    
    %% Customer Validation Phase
    Note over OPROC, CSYS: Phase 1: Customer Validation
    OPROC->>+CSYS: GET /customers/{customerId}
    CSYS->>CSYS: Validate Customer Data
    CSYS-->>-OPROC: Customer Details + Status
    
    alt Customer Invalid
        OPROC-->>OEXP: Customer Validation Failed
        OEXP-->>AGW: 400 Bad Request
        AGW-->>Client: Customer Invalid Error
    else Customer Valid
        
        %% Inventory Validation Phase  
        Note over OPROC, ISYS: Phase 2: Inventory Validation
        OPROC->>+ISYS: POST /inventory/validate
        Note right of ISYS: Check Stock Levels<br/>for All Items
        ISYS->>ISYS: Validate Product Availability
        ISYS-->>-OPROC: Inventory Status + Available Qty
        
        alt Insufficient Inventory
            OPROC-->>OEXP: Inventory Insufficient
            OEXP-->>AGW: 400 Bad Request  
            AGW-->>Client: Inventory Error
        else Inventory Available
            
            %% Payment Authorization Phase
            Note over OPROC, PSYS: Phase 3: Payment Authorization
            OPROC->>+PSYS: POST /payments/authorize
            PSYS->>PSYS: Process Payment Authorization
            PSYS-->>-OPROC: Authorization Response + Token
            
            alt Payment Authorization Failed
                OPROC-->>OEXP: Payment Authorization Failed
                OEXP-->>AGW: 400 Bad Request
                AGW-->>Client: Payment Error
            else Payment Authorized
                
                %% Order Creation Phase
                Note over OPROC, OMS: Phase 4: Order Creation
                OPROC->>+OMS: POST /orders (Create Order)
                OMS->>OMS: Create Order Record<br/>Generate Order ID
                OMS-->>-OPROC: Order Created + Order ID
                
                %% Inventory Reservation
                Note over OPROC, ISYS: Phase 5: Inventory Reservation
                OPROC->>+ISYS: POST /inventory/reserve
                ISYS->>ISYS: Reserve Stock for Order
                ISYS-->>-OPROC: Reservation Confirmation
                
                %% Payment Capture
                Note over OPROC, PSYS: Phase 6: Payment Capture
                OPROC->>+PSYS: POST /payments/capture
                PSYS->>PSYS: Capture Authorized Payment
                PSYS-->>-OPROC: Payment Captured + Transaction ID
                
                %% Shipment Creation
                Note over OPROC, SSYS: Phase 7: Shipment Creation
                OPROC->>+SSYS: POST /shipments
                SSYS->>+SHIP: Create Shipment Request
                SHIP->>SHIP: Generate Tracking Number<br/>Schedule Pickup
                SHIP-->>-SSYS: Shipment Details + Tracking
                SSYS-->>-OPROC: Shipment Created
                
                %% Final Response
                OPROC-->>-OEXP: Order Processing Complete
                Note right of OEXP: Aggregate Response<br/>Format for Channel
                OEXP-->>-AGW: Order Created Successfully
                AGW-->>-Client: 201 Created + Order Details
            end
        end
    end
```

## Error Handling and Compensation Flow

```mermaid
sequenceDiagram
    participant OPROC as Order Processing API
    participant CSYS as Customer System API  
    participant ISYS as Inventory System API
    participant PSYS as Payment System API
    participant OMS as Order Management System
    participant SSYS as Shipping System API

    Note over OPROC, SSYS: Compensation Flow - Failure Scenario

    OPROC->>+CSYS: Validate Customer
    CSYS-->>-OPROC: Customer Valid ✓
    
    OPROC->>+ISYS: Validate & Reserve Inventory  
    ISYS-->>-OPROC: Inventory Reserved ✓
    
    OPROC->>+PSYS: Authorize & Capture Payment
    PSYS-->>-OPROC: Payment Captured ✓
    
    OPROC->>+OMS: Create Order
    OMS-->>-OPROC: Order Created ✓
    
    OPROC->>+SSYS: Create Shipment
    SSYS-->>-OPROC: ❌ Shipment Creation Failed
    
    Note over OPROC: Shipment failed - Start compensation
    
    %% Compensation Actions
    Note over OPROC, SSYS: Compensation Sequence
    
    OPROC->>+PSYS: POST /payments/refund
    Note right of PSYS: Refund captured payment
    PSYS-->>-OPROC: Payment Refunded ✓
    
    OPROC->>+ISYS: POST /inventory/release  
    Note right of ISYS: Release reserved inventory
    ISYS-->>-OPROC: Inventory Released ✓
    
    OPROC->>+OMS: PATCH /orders/{id}/status
    Note right of OMS: Mark order as cancelled
    OMS-->>-OPROC: Order Cancelled ✓
    
    Note over OPROC: Return error to client with<br/>compensation complete status
```

## Business Rules and Validation

### Customer Validation Rules
- Customer must exist in customer system
- Customer must have active status
- Customer credit limit must be sufficient (if applicable)
- Customer address must be complete and valid

### Inventory Validation Rules  
- All products must exist in catalog
- Sufficient quantity must be available
- Products must be active/sellable
- No discontinued or restricted items

### Payment Validation Rules
- Payment method must be valid and active
- Payment amount must match order total
- Payment authorization must be successful
- Fraud check must pass (if enabled)

### Order Creation Rules
- Order total must be calculated correctly
- Tax calculation must be accurate  
- Shipping costs must be determined
- Order must have unique identifier

## Performance Considerations

### Parallel Processing Opportunities
- Customer and inventory validation can run in parallel
- Non-dependent system calls can be executed concurrently
- Caching can be implemented for frequently accessed data

### Timeout Configuration
- Customer validation: 2 seconds timeout
- Inventory check: 3 seconds timeout  
- Payment authorization: 5 seconds timeout
- Order creation: 2 seconds timeout
- Shipment creation: 4 seconds timeout

### Circuit Breaker Configuration
- Failure threshold: 5 consecutive failures
- Recovery timeout: 30 seconds
- Half-open state testing: 10% of requests