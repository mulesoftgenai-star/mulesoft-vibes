# MuleSoft Flow Design for Order Management System

## Overview
This document provides detailed MuleSoft flow designs for the Order Management System based on the business requirements and API specifications. The design follows the API-Led Connectivity approach with Experience, Process, and System API layers.

## Architecture Overview

### API Layers
1. **Experience API**: Order Experience API - Customer-facing interface
2. **Process API**: Order Process API - Orchestrates business processes
3. **System APIs**: Customer, Inventory, Payment, and Shipping APIs - Backend system integrations

## 1. Order Experience API Flows

### 1.1 Create Order Flow (`create-order-flow`)

**Trigger**: HTTP POST `/orders`

**Flow Steps**:
1. **Validate Request** - Validate incoming order request payload
2. **Transform Request** - Transform experience layer request to process layer format
3. **Call Order Process API** - HTTP Request to Order Process API `/orders`
4. **Handle Response** - Process response from Order Process API
5. **Transform Response** - Transform process layer response to experience layer format
6. **Error Handling** - Handle any errors and return appropriate HTTP status

```xml
<flow name="post:\orders:application\json:order-experience-api-config">
    <!-- Validate incoming request -->
    <ee:transform>
        <ee:message>
            <ee:set-payload><![CDATA[%dw 2.0
output application/json
---
// Validation logic here
payload
]]></ee:set-payload>
        </ee:message>
    </ee:transform>
    
    <!-- Transform to Process API format -->
    <ee:transform>
        <ee:message>
            <ee:set-payload><![CDATA[%dw 2.0
output application/json
---
{
    customerId: payload.customerId,
    orderItems: payload.items map {
        productId: $.productId,
        quantity: $.quantity,
        unitPrice: $.price
    },
    shippingAddress: payload.shippingAddress,
    billingAddress: payload.billingAddress,
    paymentMethod: payload.payment
}
]]></ee:set-payload>
        </ee:message>
    </ee:transform>
    
    <!-- Call Order Process API -->
    <http:request method="POST" url="${order.process.api.url}/orders" config-ref="Order_Process_API_Config">
        <http:headers>
            <http:header name="Content-Type" value="application/json" />
            <http:header name="client_id" value="${order.process.api.client.id}" />
            <http:header name="client_secret" value="${order.process.api.client.secret}" />
        </http:headers>
    </http:request>
    
    <!-- Transform response -->
    <ee:transform>
        <ee:message>
            <ee:set-payload><![CDATA[%dw 2.0
output application/json
---
{
    orderId: payload.orderId,
    status: payload.orderStatus,
    totalAmount: payload.totalAmount,
    estimatedDelivery: payload.estimatedDeliveryDate,
    orderNumber: payload.orderNumber
}
]]></ee:set-payload>
        </ee:message>
    </ee:transform>
    
    <error-handler>
        <on-error-continue type="HTTP:CONNECTIVITY">
            <ee:transform>
                <ee:message>
                    <ee:set-payload><![CDATA[%dw 2.0
output application/json
---
{
    error: "SERVICE_UNAVAILABLE",
    message: "Order processing service is temporarily unavailable"
}
]]></ee:set-payload>
                </ee:message>
                <ee:variables>
                    <ee:set-variable name="httpStatus" value="503" />
                </ee:variables>
            </ee:transform>
        </on-error-continue>
        <on-error-continue type="HTTP:BAD_REQUEST">
            <ee:transform>
                <ee:message>
                    <ee:set-payload><![CDATA[%dw 2.0
output application/json
---
{
    error: "INVALID_REQUEST",
    message: "Invalid order request"
}
]]></ee:set-payload>
                </ee:message>
                <ee:variables>
                    <ee:set-variable name="httpStatus" value="400" />
                </ee:variables>
            </ee:transform>
        </on-error-continue>
    </error-handler>
</flow>
```

### 1.2 Get Order Flow (`get-order-flow`)

**Trigger**: HTTP GET `/orders/{orderId}`

**Flow Steps**:
1. **Extract Path Parameter** - Extract orderId from URI
2. **Call Order Process API** - HTTP Request to get order details
3. **Transform Response** - Transform to experience layer format
4. **Error Handling** - Handle not found and other errors

### 1.3 Update Order Flow (`update-order-flow`)

**Trigger**: HTTP PUT `/orders/{orderId}`

**Flow Steps**:
1. **Validate Request** - Validate update request
2. **Transform Request** - Transform to process layer format
3. **Call Order Process API** - HTTP Request to update order
4. **Transform Response** - Transform response
5. **Error Handling** - Handle validation and business errors

### 1.4 Cancel Order Flow (`cancel-order-flow`)

**Trigger**: HTTP DELETE `/orders/{orderId}`

**Flow Steps**:
1. **Extract Path Parameter** - Extract orderId
2. **Call Order Process API** - HTTP Request to cancel order
3. **Handle Response** - Process cancellation response
4. **Error Handling** - Handle cancellation errors

## 2. Order Process API Flows

### 2.1 Process Order Creation Flow (`process-order-creation-flow`)

**Trigger**: HTTP POST `/orders`

**Flow Steps**:
1. **Validate Order Request** - Business validation
2. **Customer Validation** - Call Customer System API to validate customer
3. **Inventory Check** - Call Inventory System API to check availability
4. **Reserve Inventory** - Reserve items in inventory
5. **Payment Processing** - Call Payment System API for payment
6. **Create Order Record** - Store order in database
7. **Shipping Setup** - Call Shipping System API to setup delivery
8. **Send Confirmations** - Send order confirmation to customer
9. **Error Handling** - Rollback transactions on failure

```xml
<flow name="post:\orders:application\json:order-process-api-config">
    <!-- Validate business rules -->
    <flow-ref name="validate-order-business-rules" />
    
    <!-- Validate customer -->
    <flow-ref name="validate-customer-subflow" />
    
    <!-- Check inventory availability -->
    <flow-ref name="check-inventory-availability-subflow" />
    
    <!-- Reserve inventory -->
    <flow-ref name="reserve-inventory-subflow" />
    
    <!-- Process payment -->
    <flow-ref name="process-payment-subflow" />
    
    <!-- Create order record -->
    <flow-ref name="create-order-record-subflow" />
    
    <!-- Setup shipping -->
    <flow-ref name="setup-shipping-subflow" />
    
    <!-- Send confirmation -->
    <flow-ref name="send-order-confirmation-subflow" />
    
    <error-handler>
        <on-error-propagate type="CUSTOMER:INVALID">
            <flow-ref name="rollback-order-transaction" />
            <raise-error type="ORDER:CUSTOMER_INVALID" description="Invalid customer information" />
        </on-error-propagate>
        <on-error-propagate type="INVENTORY:INSUFFICIENT">
            <flow-ref name="rollback-order-transaction" />
            <raise-error type="ORDER:INSUFFICIENT_INVENTORY" description="Insufficient inventory" />
        </on-error-propagate>
        <on-error-propagate type="PAYMENT:FAILED">
            <flow-ref name="rollback-inventory-reservation" />
            <raise-error type="ORDER:PAYMENT_FAILED" description="Payment processing failed" />
        </on-error-propagate>
    </error-handler>
</flow>
```

### 2.2 Order Status Update Flow (`order-status-update-flow`)

**Trigger**: HTTP PUT `/orders/{orderId}/status`

**Flow Steps**:
1. **Extract Order ID** - Get orderId from path
2. **Validate Status Transition** - Check if status change is valid
3. **Update Order Status** - Update in database
4. **Notify Stakeholders** - Send notifications based on status
5. **Update External Systems** - Sync status with relevant systems

### 2.3 Order Fulfillment Flow (`order-fulfillment-flow`)

**Trigger**: HTTP POST `/orders/{orderId}/fulfill`

**Flow Steps**:
1. **Get Order Details** - Retrieve order information
2. **Inventory Fulfillment** - Update inventory with fulfilled quantities
3. **Generate Shipping Label** - Create shipping documentation
4. **Update Order Status** - Mark as fulfilled
5. **Send Tracking Information** - Provide tracking details to customer

## 3. Customer System API Flows

### 3.1 Validate Customer Flow (`validate-customer-flow`)

**Trigger**: HTTP GET `/customers/{customerId}/validate`

**Flow Steps**:
1. **Extract Customer ID** - Get customerId from path
2. **Database Query** - Query customer database
3. **Validate Customer Status** - Check if customer is active
4. **Check Credit Limit** - Validate credit worthiness
5. **Return Validation Result** - Provide validation response

```xml
<flow name="get:\customers\{customerId}\validate:customer-system-api-config">
    <set-variable name="customerId" value="#[attributes.uriParams.customerId]" />
    
    <!-- Query customer database -->
    <db:select config-ref="Customer_Database_Config">
        <db:sql>
            SELECT customer_id, status, credit_limit, credit_used, account_type
            FROM customers 
            WHERE customer_id = :customerId AND status = 'ACTIVE'
        </db:sql>
        <db:input-parameters>
            <db:input-parameter key="customerId" value="#[vars.customerId]" />
        </db:input-parameters>
    </db:select>
    
    <!-- Transform and validate -->
    <ee:transform>
        <ee:message>
            <ee:set-payload><![CDATA[%dw 2.0
output application/json
---
if (sizeOf(payload) > 0)
    {
        isValid: true,
        customerId: payload[0].customer_id,
        status: payload[0].status,
        creditAvailable: payload[0].credit_limit - payload[0].credit_used,
        accountType: payload[0].account_type
    }
else
    {
        isValid: false,
        customerId: vars.customerId,
        error: "Customer not found or inactive"
    }
]]></ee:set-payload>
        </ee:message>
    </ee:transform>
    
    <error-handler>
        <on-error-continue type="DB:CONNECTIVITY">
            <ee:transform>
                <ee:message>
                    <ee:set-payload><![CDATA[%dw 2.0
output application/json
---
{
    isValid: false,
    error: "Database connectivity error"
}
]]></ee:set-payload>
                </ee:message>
            </ee:transform>
        </on-error-continue>
    </error-handler>
</flow>
```

### 3.2 Get Customer Details Flow (`get-customer-details-flow`)

**Trigger**: HTTP GET `/customers/{customerId}`

**Flow Steps**:
1. **Extract Customer ID** - Get customerId from path
2. **Database Query** - Retrieve customer information
3. **Transform Response** - Format customer data
4. **Error Handling** - Handle not found cases

### 3.3 Update Customer Flow (`update-customer-flow`)

**Trigger**: HTTP PUT `/customers/{customerId}`

**Flow Steps**:
1. **Validate Update Request** - Validate incoming data
2. **Database Update** - Update customer information
3. **Audit Log** - Log the changes
4. **Return Updated Customer** - Provide updated information

## 4. Inventory System API Flows

### 4.1 Check Availability Flow (`check-availability-flow`)

**Trigger**: HTTP GET `/inventory/availability`

**Flow Steps**:
1. **Parse Query Parameters** - Extract product IDs and quantities
2. **Database Query** - Check available quantities
3. **Calculate Availability** - Determine if sufficient stock exists
4. **Return Availability Status** - Provide availability information

```xml
<flow name="get:\inventory\availability:inventory-system-api-config">
    <!-- Parse query parameters -->
    <set-variable name="productIds" value="#[attributes.queryParams.productIds]" />
    <set-variable name="quantities" value="#[attributes.queryParams.quantities]" />
    
    <!-- Query inventory database -->
    <db:select config-ref="Inventory_Database_Config">
        <db:sql>
            SELECT product_id, available_quantity, reserved_quantity 
            FROM inventory 
            WHERE product_id IN (:productIds)
        </db:sql>
        <db:input-parameters>
            <db:input-parameter key="productIds" value="#[vars.productIds splitBy ',']" />
        </db:input-parameters>
    </db:select>
    
    <!-- Transform and check availability -->
    <ee:transform>
        <ee:message>
            <ee:set-payload><![CDATA[%dw 2.0
output application/json
var requestedItems = vars.quantities splitBy ',' 
var requestedProductIds = vars.productIds splitBy ','
var requestedQuantities = requestedItems map $ as Number
---
{
    availability: (requestedProductIds zip requestedQuantities) map {
        productId: $[0],
        requestedQuantity: $[1],
        availableQuantity: (payload filter ($.product_id == $[0]))[0].available_quantity default 0,
        isAvailable: ((payload filter ($.product_id == $[0]))[0].available_quantity default 0) >= $[1]
    }
}
]]></ee:set-payload>
        </ee:message>
    </ee:transform>
</flow>
```

### 4.2 Reserve Inventory Flow (`reserve-inventory-flow`)

**Trigger**: HTTP POST `/inventory/reserve`

**Flow Steps**:
1. **Validate Reserve Request** - Check request format
2. **Check Current Availability** - Verify stock levels
3. **Create Reservation** - Reserve inventory items
4. **Update Inventory Records** - Adjust available quantities
5. **Return Reservation Details** - Provide reservation confirmation

### 4.3 Release Inventory Flow (`release-inventory-flow`)

**Trigger**: HTTP POST `/inventory/release`

**Flow Steps**:
1. **Validate Release Request** - Check reservation details
2. **Find Reservation** - Locate existing reservation
3. **Release Reserved Items** - Return items to available inventory
4. **Update Inventory Records** - Adjust inventory quantities
5. **Return Release Confirmation** - Provide release status

```xml
<flow name="post:\inventory\release:inventory-system-api-config">
    <!-- Validate release request -->
    <ee:transform>
        <ee:message>
            <ee:set-payload><![CDATA[%dw 2.0
output application/json
---
payload
]]></ee:set-payload>
        </ee:message>
    </ee:transform>
    
    <!-- Find and release reservations -->
    <db:update config-ref="Inventory_Database_Config">
        <db:sql>
            UPDATE inventory_reservations 
            SET status = 'RELEASED', released_date = NOW()
            WHERE reservation_id IN (:reservationIds) 
            AND status = 'ACTIVE'
        </db:sql>
        <db:input-parameters>
            <db:input-parameter key="reservationIds" value="#[payload.reservationIds]" />
        </db:input-parameters>
    </db:update>
    
    <!-- Update inventory quantities -->
    <db:update config-ref="Inventory_Database_Config">
        <db:sql>
            UPDATE inventory i
            SET available_quantity = available_quantity + r.quantity,
                reserved_quantity = reserved_quantity - r.quantity
            FROM inventory_reservations r
            WHERE i.product_id = r.product_id 
            AND r.reservation_id IN (:reservationIds)
        </db:sql>
        <db:input-parameters>
            <db:input-parameter key="reservationIds" value="#[payload.reservationIds]" />
        </db:input-parameters>
    </db:update>
    
    <!-- Return confirmation -->
    <ee:transform>
        <ee:message>
            <ee:set-payload><![CDATA[%dw 2.0
output application/json
---
{
    requestId: payload.requestId,
    status: "SUCCESS",
    message: "Inventory reservations released successfully",
    releasedCount: payload.reservationIds sizeOf,
    timestamp: now()
}
]]></ee:set-payload>
        </ee:message>
    </ee:transform>
</flow>
```

### 4.4 Update Inventory Flow (`update-inventory-flow`)

**Trigger**: HTTP PUT `/inventory/{productId}`

**Flow Steps**:
1. **Extract Product ID** - Get productId from path
2. **Validate Update Request** - Check adjustment data
3. **Record Transaction** - Log inventory transaction
4. **Update Inventory Levels** - Apply quantity adjustment
5. **Return Updated Inventory** - Provide current inventory status

## 5. Payment System API Flows

### 5.1 Process Payment Flow (`process-payment-flow`)

**Trigger**: HTTP POST `/payments`

**Flow Steps**:
1. **Validate Payment Request** - Validate payment data
2. **Check Fraud Rules** - Apply fraud detection
3. **Authorize Payment** - Call payment gateway for authorization
4. **Store Payment Record** - Save payment information
5. **Return Authorization Result** - Provide payment response

```xml
<flow name="post:\payments:application\json:payment-system-api-config">
    <!-- Validate payment request -->
    <flow-ref name="validate-payment-request-subflow" />
    
    <!-- Fraud check -->
    <flow-ref name="fraud-check-subflow" />
    
    <!-- Process authorization -->
    <choice>
        <when expression="#[payload.paymentMethod.type == 'CREDIT_CARD']">
            <flow-ref name="process-credit-card-payment-subflow" />
        </when>
        <when expression="#[payload.paymentMethod.type == 'PAYPAL']">
            <flow-ref name="process-paypal-payment-subflow" />
        </when>
        <otherwise>
            <flow-ref name="process-alternative-payment-subflow" />
        </otherwise>
    </choice>
    
    <!-- Store payment record -->
    <flow-ref name="store-payment-record-subflow" />
    
    <!-- Transform response -->
    <ee:transform>
        <ee:message>
            <ee:set-payload><![CDATA[%dw 2.0
output application/json
---
{
    transactionId: payload.transactionId,
    authorizationStatus: payload.authorizationStatus,
    authorizationCode: payload.authorizationCode,
    amount: payload.amount,
    currency: payload.currency,
    processorTransactionId: payload.processorTransactionId,
    authorizationDate: payload.authorizationDate
}
]]></ee:set-payload>
        </ee:message>
    </ee:transform>
    
    <error-handler>
        <on-error-continue type="PAYMENT:DECLINED">
            <ee:transform>
                <ee:message>
                    <ee:set-payload><![CDATA[%dw 2.0
output application/json
---
{
    error: "PAYMENT_DECLINED",
    message: "Payment was declined by the issuing bank",
    declineReason: payload.declineReason default "GENERIC_DECLINE"
}
]]></ee:set-payload>
                </ee:message>
                <ee:variables>
                    <ee:set-variable name="httpStatus" value="402" />
                </ee:variables>
            </ee:transform>
        </on-error-continue>
        <on-error-continue type="PAYMENT:FRAUD">
            <ee:transform>
                <ee:message>
                    <ee:set-payload><![CDATA[%dw 2.0
output application/json
---
{
    error: "FRAUD_DETECTED",
    message: "Transaction flagged for potential fraud"
}
]]></ee:set-payload>
                </ee:message>
                <ee:variables>
                    <ee:set-variable name="httpStatus" value="403" />
                </ee:variables>
            </ee:transform>
        </on-error-continue>
    </error-handler>
</flow>
```

### 5.2 Capture Payment Flow (`capture-payment-flow`)

**Trigger**: HTTP POST `/payments/{paymentId}/capture`

**Flow Steps**:
1. **Extract Payment ID** - Get paymentId from path
2. **Validate Capture Request** - Check capture amount and status
3. **Call Payment Gateway** - Execute capture transaction
4. **Update Payment Status** - Mark payment as captured
5. **Return Capture Result** - Provide capture confirmation

### 5.3 Refund Payment Flow (`refund-payment-flow`)

**Trigger**: HTTP POST `/payments/{paymentId}/refund`

**Flow Steps**:
1. **Extract Payment ID** - Get paymentId from path
2. **Validate Refund Request** - Check refund eligibility
3. **Process Refund** - Call payment gateway for refund
4. **Update Records** - Update payment and refund records
5. **Return Refund Status** - Provide refund confirmation

## 6. Shipping System API Flows

### 6.1 Create Shipment Flow (`create-shipment-flow`)

**Trigger**: HTTP POST `/shipments`

**Flow Steps**:
1. **Validate Shipment Request** - Check shipment data
2. **Calculate Shipping Rates** - Get rates from carriers
3. **Select Best Rate** - Choose optimal carrier and service
4. **Create Shipping Label** - Generate shipping label
5. **Store Shipment Record** - Save shipment information
6. **Return Shipment Details** - Provide tracking information

```xml
<flow name="post:\shipments:application\json:shipping-system-api-config">
    <!-- Validate shipment request -->
    <flow-ref name="validate-shipment-request-subflow" />
    
    <!-- Calculate rates from multiple carriers -->
    <scatter-gather>
        <route>
            <flow-ref name="get-ups-rates-subflow" />
        </route>
        <route>
            <flow-ref name="get-fedex-rates-subflow" />
        </route>
        <route>
            <flow-ref name="get-usps-rates-subflow" />
        </route>
    </scatter-gather>
    
    <!-- Select best rate -->
    <flow-ref name="select-best-shipping-rate-subflow" />
    
    <!-- Create shipping label -->
    <flow-ref name="create-shipping-label-subflow" />
    
    <!-- Store shipment record -->
    <flow-ref name="store-shipment-record-subflow" />
    
    <!-- Transform response -->
    <ee:transform>
        <ee:message>
            <ee:set-payload><![CDATA[%dw 2.0
output application/json
---
{
    shipmentId: payload.shipmentId,
    trackingNumber: payload.trackingNumber,
    carrier: payload.carrier,
    shippingLabel: payload.shippingLabel,
    estimatedDelivery: payload.estimatedDelivery,
    shippingCost: payload.shippingCost,
    status: "CREATED"
}
]]></ee:set-payload>
        </ee:message>
    </ee:transform>
    
    <error-handler>
        <on-error-continue type="SHIPPING:ADDRESS_INVALID">
            <ee:transform>
                <ee:message>
                    <ee:set-payload><![CDATA[%dw 2.0
output application/json
---
{
    error: "INVALID_ADDRESS",
    message: "Shipping address validation failed"
}
]]></ee:set-payload>
                </ee:message>
                <ee:variables>
                    <ee:set-variable name="httpStatus" value="400" />
                </ee:variables>
            </ee:transform>
        </on-error-continue>
    </error-handler>
</flow>
```

### 6.2 Track Shipment Flow (`track-shipment-flow`)

**Trigger**: HTTP GET `/shipments/{shipmentId}/tracking`

**Flow Steps**:
1. **Extract Shipment ID** - Get shipmentId from path
2. **Get Carrier Info** - Retrieve carrier and tracking number
3. **Call Carrier API** - Get tracking updates from carrier
4. **Update Shipment Status** - Update internal tracking status
5. **Return Tracking Info** - Provide tracking details

### 6.3 Update Shipment Status Flow (`update-shipment-status-flow`)

**Trigger**: HTTP PUT `/shipments/{shipmentId}`

**Flow Steps**:
1. **Extract Shipment ID** - Get shipmentId from path
2. **Validate Status Update** - Check status transition validity
3. **Update Shipment Record** - Save status change
4. **Send Notifications** - Notify interested parties
5. **Return Updated Status** - Provide confirmation

## 7. Integration Orchestration Flows

### 7.1 Order Processing Orchestration Flow

**Purpose**: Coordinates the complete order processing workflow across all systems

```xml
<flow name="order-processing-orchestration-flow">
    <!-- Set correlation ID for tracking -->
    <set-variable name="correlationId" value="#[uuid()]" />
    <logger message="Starting order processing orchestration for correlation ID: #[vars.correlationId]" />
    
    <!-- Step 1: Customer Validation -->
    <try>
        <http:request config-ref="Customer_System_API_Config" path="/customers/{customerId}/validate" method="GET">
            <http:uri-params>
                <http:uri-param paramName="customerId" value="#[payload.customerId]" />
            </http:uri-params>
        </http:request>
        <error-handler>
            <on-error-propagate>
                <logger message="Customer validation failed for correlation ID: #[vars.correlationId]" level="ERROR" />
                <raise-error type="ORCHESTRATION:CUSTOMER_VALIDATION_FAILED" />
            </on-error-propagate>
        </error-handler>
    </try>
    
    <!-- Step 2: Inventory Check and Reserve -->
    <try>
        <http:request config-ref="Inventory_System_API_Config" path="/inventory/check" method="POST" />
        <choice>
            <when expression="#[payload.overallStatus == 'AVAILABLE']">
                <http:request config-ref="Inventory_System_API_Config" path="/inventory/reserve" method="POST" />
            </when>
            <otherwise>
                <raise-error type="ORCHESTRATION:INSUFFICIENT_INVENTORY" />
            </otherwise>
        </choice>
        <error-handler>
            <on-error-propagate>
                <logger message="Inventory operations failed for correlation ID: #[vars.correlationId]" level="ERROR" />
                <raise-error type="ORCHESTRATION:INVENTORY_FAILED" />
            </on-error-propagate>
        </error-handler>
    </try>
    
    <!-- Step 3: Payment Processing -->
    <try>
        <http:request config-ref="Payment_System_API_Config" path="/payments" method="POST" />
        <choice>
            <when expression="#[payload.authorizationStatus != 'APPROVED']">
                <!-- Release inventory if payment fails -->
                <flow-ref name="release-inventory-compensation-subflow" />
                <raise-error type="ORCHESTRATION:PAYMENT_FAILED" />
            </when>
        </choice>
        <error-handler>
            <on-error-propagate>
                <logger message="Payment processing failed for correlation ID: #[vars.correlationId]" level="ERROR" />
                <flow-ref name="release-inventory-compensation-subflow" />
                <raise-error type="ORCHESTRATION:PAYMENT_FAILED" />
            </on-error-propagate>
        </error-handler>
    </try>
    
    <!-- Step 4: Create Shipment -->
    <try>
        <http:request config-ref="Shipping_System_API_Config" path="/shipments" method="POST" />
        <error-handler>
            <on-error-propagate>
                <logger message="Shipment creation failed for correlation ID: #[vars.correlationId]" level="ERROR" />
                <!-- Note: Shipment failure doesn't require rollback of payment/inventory at this point -->
            </on-error-propagate>
        </error-handler>
    </try>
    
    <!-- Step 5: Finalize Order -->
    <flow-ref name="finalize-order-subflow" />
    
    <logger message="Order processing orchestration completed successfully for correlation ID: #[vars.correlationId]" />
</flow>
```

### 7.2 Error Handling and Compensation Flows

**Purpose**: Handle errors and implement compensation patterns for distributed transactions

```xml
<sub-flow name="release-inventory-compensation-subflow">
    <logger message="Executing inventory release compensation for correlation ID: #[vars.correlationId]" />
    <try>
        <http:request config-ref="Inventory_System_API_Config" path="/inventory/release" method="POST">
            <http:body><![CDATA[
                {
                    "requestId": "#[vars.correlationId]",
                    "reservationIds": #[vars.reservationIds],
                    "reason": "ORDER_FAILED",
                    "releasedBy": "ORDER_ORCHESTRATION"
                }
            ]]></http:body>
        </http:request>
        <error-handler>
            <on-error-continue>
                <logger message="Failed to release inventory in compensation flow for correlation ID: #[vars.correlationId]" level="ERROR" />
            </on-error-continue>
        </error-handler>
    </try>
</sub-flow>

<sub-flow name="void-payment-compensation-subflow">
    <logger message="Executing payment void compensation for correlation ID: #[vars.correlationId]" />
    <try>
        <http:request config-ref="Payment_System_API_Config" path="/payments/{paymentId}/void" method="POST">
            <http:uri-params>
                <http:uri-param paramName="paymentId" value="#[vars.paymentId]" />
            </http:uri-params>
        </http:request>
        <error-handler>
            <on-error-continue>
                <logger message="Failed to void payment in compensation flow for correlation ID: #[vars.correlationId]" level="ERROR" />
            </on-error-continue>
        </error-handler>
    </try>
</sub-flow>
```

## 8. Data Transformation Examples

### 8.1 Order Creation Request Transformation

**From Experience API to Process API**

```dataweave
%dw 2.0
output application/json
---
{
    // Transform experience layer order request to process layer format
    customerId: payload.customerId,
    orderType: payload.orderType default "STANDARD",
    priority: payload.priority default "MEDIUM",
    source: payload.source default "API",
    
    // Transform items array
    items: payload.items map {
        productId: $.productId,
        quantity: $.quantity,
        unitPrice: $.unitPrice,
        specialInstructions: $.specialInstructions
    },
    
    // Transform addresses
    shippingAddress: {
        firstName: payload.shippingAddress.firstName,
        lastName: payload.shippingAddress.lastName,
        company: payload.shippingAddress.company,
        addressLine1: payload.shippingAddress.addressLine1,
        addressLine2: payload.shippingAddress.addressLine2,
        city: payload.shippingAddress.city,
        state: payload.shippingAddress.state,
        postalCode: payload.shippingAddress.postalCode,
        country: payload.shippingAddress.country,
        phoneNumber: payload.shippingAddress.phoneNumber
    },
    
    // Transform payment information (sensitive data handling)
    paymentInfo: {
        paymentMethod: payload.paymentInfo.method,
        // Only pass token/reference, not actual card data
        cardToken: payload.paymentInfo.cardToken,
        billingAddress: payload.billingAddress
    },
    
    // Additional processing fields
    requestedDeliveryDate: payload.requestedDeliveryDate,
    specialInstructions: payload.specialInstructions,
    
    // Metadata
    requestId: uuid(),
    timestamp: now(),
    apiVersion: "v1.0"
}
```

### 8.2 Customer Validation Response Transformation

**From System API to Process API**

```dataweave
%dw 2.0
output application/json
---
{
    // Transform customer validation response
    customerId: payload.customerId,
    validationStatus: if (payload.isValid) "VALID" else "INVALID",
    
    // Customer profile information
    customerProfile: if (payload.isValid) {
        customerId: payload.customerId,
        customerType: payload.customerType,
        status: payload.status,
        creditAvailable: payload.creditAvailable,
        accountType: payload.accountType,
        registrationDate: payload.registrationDate,
        lastLoginDate: payload.lastLoginDate
    } else null,
    
    // Validation details
    validationDetails: {
        creditCheckPassed: payload.creditAvailable > 0,
        accountActive: payload.status == "ACTIVE",
        validationTimestamp: now()
    },
    
    // Error information if validation failed
    validationErrors: if (payload.isValid) [] else [
        {
            code: "CUSTOMER_INVALID",
            message: payload.error default "Customer validation failed"
        }
    ]
}
```

### 8.3 Inventory Check Response Transformation

**From System API to Process API**

```dataweave
%dw 2.0
output application/json
---
{
    requestId: payload.requestId,
    overallStatus: if (payload.items all $.availableQuantity >= $.requestedQuantity) "AVAILABLE" else "INSUFFICIENT",
    
    itemAvailability: payload.items map {
        itemId: $.itemId,
        productId: $.productId,
        sku: $.sku,
        requestedQuantity: $.requestedQuantity,
        availableQuantity: $.availableQuantity,
        isAvailable: $.availableQuantity >= $.requestedQuantity,
        shortfall: if ($.availableQuantity < $.requestedQuantity) ($.requestedQuantity - $.availableQuantity) else 0,
        estimatedRestockDate: $.estimatedRestockDate,
        alternativeProducts: $.alternativeProducts default []
    },
    
    reservationInfo: if (payload.reservationId != null) {
        reservationId: payload.reservationId,
        reservationExpiry: payload.reservationExpiry,
        reservedUntil: payload.reservedUntil
    } else null,
    
    checkTimestamp: payload.checkTimestamp default now(),
    warehouseAllocations: payload.warehouseAllocations default []
}
```

## 9. Configuration and Error Handling

### 9.1 Global Configuration

```xml
<!-- HTTP Listener Configuration -->
<http:listener-config name="order-experience-api-httpListenerConfig">
    <http:listener-connection host="0.0.0.0" port="8081" />
</http:listener-config>

<!-- HTTP Request Configurations for System APIs -->
<http:request-config name="Customer_System_API_Config" basePath="/api/v1">
    <http:request-connection host="${customer.api.host}" port="${customer.api.port}" protocol="HTTPS" />
</http:request-config>

<http:request-config name="Inventory_System_API_Config" basePath="/api/v1">
    <http:request-connection host="${inventory.api.host}" port="${inventory.api.port}" protocol="HTTPS" />
</http:request-config>

<http:request-config name="Payment_System_API_Config" basePath="/api/v1">
    <http:request-connection host="${payment.api.host}" port="${payment.api.port}" protocol="HTTPS" />
</http:request-config>

<http:request-config name="Shipping_System_API_Config" basePath="/api/v1">
    <http:request-connection host="${shipping.api.host}" port="${shipping.api.port}" protocol="HTTPS" />
</http:request-config>

<!-- Database Configuration -->
<db:config name="Order_Database_Config">
    <db:my-sql-connection host="${order.db.host}" port="${order.db.port}" 
                         user="${order.db.user}" password="${order.db.password}" 
                         database="${order.db.name}" />
</db:config>

<!-- JMS Configuration for Async Processing -->
<jms:config name="Order_Events_Config">
    <jms:active-mq-connection>
        <jms:factory-configuration brokerUrl="${activemq.broker.url}" />
    </jms:active-mq-connection>
</jms:config>
```

### 9.2 Global Error Handler

```xml
<error-handler name="global-order-management-error-handler">
    <on-error-continue type="HTTP:TIMEOUT">
        <logger message="HTTP timeout error occurred - Request ID: #[correlationId]" level="ERROR" />
        <ee:transform>
            <ee:message>
                <ee:set-payload><![CDATA[%dw 2.0
output application/json
---
{
    type: "https://api.orderexperience.com/problems/timeout-error",
    title: "Request Timeout",
    status: 504,
    detail: "The request timed out while processing",
    timestamp: now(),
    correlationId: correlationId,
    retryable: true,
    retryAfter: 30
}
]]></ee:set-payload>
            </ee:message>
            <ee:variables>
                <ee:set-variable name="httpStatus" value="504" />
            </ee:variables>
        </ee:transform>
    </on-error-continue>
    
    <on-error-continue type="HTTP:CONNECTIVITY">
        <logger message="HTTP connectivity error occurred - Request ID: #[correlationId]" level="ERROR" />
        <ee:transform>
            <ee:message>
                <ee:set-payload><![CDATA[%dw 2.0
output application/json
---
{
    type: "https://api.orderexperience.com/problems/service-unavailable",
    title: "Service Unavailable",
    status: 503,
    detail: "Downstream service is temporarily unavailable",
    timestamp: now(),
    correlationId: correlationId,
    retryable: true,
    retryAfter: 60
}
]]></ee:set-payload>
            </ee:message>
            <ee:variables>
                <ee:set-variable name="httpStatus" value="503" />
            </ee:variables>
        </ee:transform>
    </on-error-continue>
    
    <on-error-continue type="DB:CONNECTIVITY">
        <logger message="Database connectivity error occurred - Request ID: #[correlationId]" level="ERROR" />
        <ee:transform>
            <ee:message>
                <ee:set-payload><![CDATA[%dw 2.0
output application/json
---
{
    type: "https://api.orderexperience.com/problems/database-error",
    title: "Database Error",
    status: 500,
    detail: "Database connection failed",
    timestamp: now(),
    correlationId: correlationId,
    retryable: false
}
]]></ee:set-payload>
            </ee:message>
            <ee:variables>
                <ee:set-variable name="httpStatus" value="500" />
            </ee:variables>
        </ee:transform>
    </on-error-continue>
    
    <on-error-continue type="ANY">
        <logger message="Unexpected error occurred - Request ID: #[correlationId], Error: #[error.description]" level="ERROR" />
        <ee:transform>
            <ee:message>
                <ee:set-payload><![CDATA[%dw 2.0
output application/json
---
{
    type: "https://api.orderexperience.com/problems/internal-error",
    title: "Internal Server Error",
    status: 500,
    detail: "An unexpected error occurred while processing the request",
    timestamp: now(),
    correlationId: correlationId,
    retryable: false
}
]]></ee:set-payload>
            </ee:message>
            <ee:variables>
                <ee:set-variable name="httpStatus" value="500" />
            </ee:variables>
        </ee:transform>
    </on-error-continue>
</error-handler>
```

### 9.3 Circuit Breaker Configuration

```xml
<!-- Circuit Breaker for Customer System API -->
<ee:object-store-caching-strategy name="customer-api-circuit-breaker" objectStore="customerApiCircuitBreakerStore">
    <ee:max-entries>1000</ee:max-entries>
    <ee:entry-ttl>300</ee:entry-ttl>
</ee:object-store-caching-strategy>

<!-- Circuit Breaker Logic Flow -->
<flow name="customer-api-with-circuit-breaker">
    <set-variable name="circuitBreakerKey" value="customer-api-circuit-breaker" />
    
    <!-- Check circuit breaker state -->
    <ee:cache cachingStrategy-ref="customer-api-circuit-breaker" key="#[vars.circuitBreakerKey]">
        <logger message="Circuit breaker is CLOSED - allowing request" />
        
        <try>
            <http:request config-ref="Customer_System_API_Config" path="/customers/{customerId}/validate" method="GET">
                <http:uri-params>
                    <http:uri-param paramName="customerId" value="#[vars.customerId]" />
                </http:uri-params>
            </http:request>
            
            <error-handler>
                <on-error-propagate>
                    <!-- Open circuit breaker on consecutive failures -->
                    <ee:transform>
                        <ee:message>
                            <ee:set-payload><![CDATA[%dw 2.0
output application/json
---
{
    circuitState: "OPEN",
    timestamp: now(),
    errorCount: (vars.errorCount default 0) + 1
}
]]></ee:set-payload>
                        </ee:message>
                    </ee:transform>
                    <raise-error type="CIRCUIT_BREAKER:OPEN" description="Circuit breaker opened due to failures" />
                </on-error-propagate>
            </error-handler>
        </try>
    </ee:cache>
    
    <error-handler>
        <on-error-continue type="CIRCUIT_BREAKER:OPEN">
            <logger message="Circuit breaker is OPEN - failing fast" level="WARN" />
            <ee:transform>
                <ee:message>
                    <ee:set-payload><![CDATA[%dw 2.0
output application/json
---
{
    error: "CIRCUIT_BREAKER_OPEN",
    message: "Customer service is currently unavailable"
}
]]></ee:set-payload>
                </ee:message>
                <ee:variables>
                    <ee:set-variable name="httpStatus" value="503" />
                </ee:variables>
            </ee:transform>
        </on-error-continue>
    </error-handler>
</flow>
```

## 10. Monitoring and Observability

### 10.1 Metrics Collection Flow

```xml
<flow name="metrics-collection-flow">
    <!-- Collect API metrics -->
    <ee:transform>
        <ee:message>
            <ee:set-payload><![CDATA[%dw 2.0
output application/json
---
{
    timestamp: now(),
    apiName: vars.apiName,
    operation: vars.operation,
    responseTime: vars.responseTime,
    statusCode: vars.httpStatus,
    correlationId: vars.correlationId,
    customerId: vars.customerId,
    orderId: vars.orderId
}
]]></ee:set-payload>
        </ee:message>
    </ee:transform>
    
    <!-- Send metrics to monitoring system -->
    <async>
        <jms:publish config-ref="Order_Events_Config" destination="metrics.queue" />
    </async>
</flow>
```

### 10.2 Health Check Flows

```xml
<flow name="health-check-flow">
    <http:listener config-ref="order-experience-api-httpListenerConfig" path="/health" allowedMethods="GET" />
    
    <!-- Check downstream dependencies -->
    <scatter-gather>
        <route>
            <flow-ref name="check-customer-api-health" />
        </route>
        <route>
            <flow-ref name="check-inventory-api-health" />
        </route>
        <route>
            <flow-ref name="check-payment-api-health" />
        </route>
        <route>
            <flow-ref name="check-shipping-api-health" />
        </route>
        <route>
            <flow-ref name="check-database-health" />
        </route>
    </scatter-gather>
    
    <!-- Aggregate health status -->
    <ee:transform>
        <ee:message>
            <ee:set-payload><![CDATA[%dw 2.0
output application/json
---
{
    status: if ((payload..status) contains "DOWN") "DOWN" else "UP",
    timestamp: now(),
    version: "1.0.0",
    checks: {
        customerAPI: payload[0].status,
        inventoryAPI: payload[1].status,
        paymentAPI: payload[2].status,
        shippingAPI: payload[3].status,
        database: payload[4].status
    },
    dependencies: payload..dependencies reduce ($$ ++ $)
}
]]></ee:set-payload>
        </ee:message>
        <ee:variables>
            <ee:set-variable name="httpStatus" value="#[if (payload.status == 'DOWN') 503 else 200]" />
        </ee:variables>
    </ee:transform>
</flow>

<sub-flow name="check-customer-api-health">
    <try>
        <http:request config-ref="Customer_System_API_Config" path="/health" method="GET" responseTimeout="5000" />
        <ee:transform>
            <ee:message>
                <ee:set-payload><![CDATA[%dw 2.0
output application/json
---
{
    status: "UP",
    service: "Customer API",
    responseTime: vars.responseTime
}
]]></ee:set-payload>
            </ee:message>
        </ee:transform>
        <error-handler>
            <on-error-continue>
                <ee:transform>
                    <ee:message>
                        <ee:set-payload><![CDATA[%dw 2.0
output application/json
---
{
    status: "DOWN",
    service: "Customer API",
    error: error.description
}
]]></ee:set-payload>
                    </ee:message>
                </ee:transform>
            </on-error-continue>
        </error-handler>
    </try>
</sub-flow>
```

## 11. Asynchronous Processing and Events

### 11.1 Event Publishing Flow

```xml
<flow name="order-event-publisher-flow">
    <!-- Transform order data to event format -->
    <ee:transform>
        <ee:message>
            <ee:set-payload><![CDATA[%dw 2.0
output application/json
---
{
    eventType: vars.eventType,
    eventVersion: "1.0",
    eventId: uuid(),
    timestamp: now(),
    source: "order-management-system",
    data: {
        orderId: payload.orderId,
        customerId: payload.customerId,
        orderStatus: payload.orderStatus,
        totalAmount: payload.totalAmount,
        items: payload.items
    },
    metadata: {
        correlationId: vars.correlationId,
        causationId: vars.causationId,
        userId: vars.userId
    }
}
]]></ee:set-payload>
        </ee:message>
    </ee:transform>
    
    <!-- Publish to event queue -->
    <choice>
        <when expression="#[vars.eventType == 'ORDER_CREATED']">
            <jms:publish config-ref="Order_Events_Config" destination="order.created" />
        </when>
        <when expression="#[vars.eventType == 'ORDER_UPDATED']">
            <jms:publish config-ref="Order_Events_Config" destination="order.updated" />
        </when>
        <when expression="#[vars.eventType == 'ORDER_CANCELLED']">
            <jms:publish config-ref="Order_Events_Config" destination="order.cancelled" />
        </when>
        <otherwise>
            <jms:publish config-ref="Order_Events_Config" destination="order.events" />
        </otherwise>
    </choice>
    
    <logger message="Published event: #[vars.eventType] for order: #[payload.data.orderId]" />
</flow>
```

### 11.2 Event Listener Flows

```xml
<flow name="order-created-event-listener">
    <jms:listener config-ref="Order_Events_Config" destination="order.created" />
    
    <logger message="Received ORDER_CREATED event for order: #[payload.data.orderId]" />
    
    <!-- Process order created event -->
    <scatter-gather>
        <route>
            <!-- Send welcome email to customer -->
            <flow-ref name="send-order-confirmation-email" />
        </route>
        <route>
            <!-- Update customer order history -->
            <flow-ref name="update-customer-order-history" />
        </route>
        <route>
            <!-- Trigger inventory allocation -->
            <flow-ref name="trigger-inventory-allocation" />
        </route>
    </scatter-gather>
    
    <error-handler>
        <on-error-continue>
            <logger message="Failed to process ORDER_CREATED event for order: #[payload.data.orderId]" level="ERROR" />
            <!-- Send to dead letter queue -->
            <jms:publish config-ref="Order_Events_Config" destination="order.events.dlq" />
        </on-error-continue>
    </error-handler>
</flow>

<flow name="order-status-update-event-listener">
    <jms:listener config-ref="Order_Events_Config" destination="order.updated" />
    
    <logger message="Received ORDER_UPDATED event for order: #[payload.data.orderId]" />
    
    <!-- Route based on status change -->
    <choice>
        <when expression="#[payload.data.orderStatus == 'SHIPPED']">
            <flow-ref name="send-shipping-notification" />
        </when>
        <when expression="#[payload.data.orderStatus == 'DELIVERED']">
            <flow-ref name="send-delivery-confirmation" />
        </when>
        <when expression="#[payload.data.orderStatus == 'CANCELLED']">
            <flow-ref name="process-order-cancellation" />
        </when>
        <otherwise>
            <logger message="Status update processed for order: #[payload.data.orderId] - Status: #[payload.data.orderStatus]" />
        </otherwise>
    </choice>
</flow>
```

## 12. Security Implementation

### 12.1 OAuth 2.0 Token Validation

```xml
<flow name="oauth-token-validation-flow">
    <!-- Extract Bearer token from Authorization header -->
    <set-variable name="bearerToken" value="#[attributes.headers.authorization replace 'Bearer ' with '']" />
    
    <!-- Validate token with OAuth provider -->
    <http:request method="POST" url="${oauth.introspection.url}" config-ref="OAuth_Provider_Config">
        <http:headers>
            <http:header name="Content-Type" value="application/x-www-form-urlencoded" />
            <http:header name="Authorization" value="Basic ${oauth.client.credentials}" />
        </http:headers>
        <http:body><![CDATA[token=#[vars.bearerToken]]]></http:body>
    </http:request>
    
    <!-- Process token validation response -->
    <choice>
        <when expression="#[payload.active == true]">
            <set-variable name="tokenValid" value="true" />
            <set-variable name="clientId" value="#[payload.client_id]" />
            <set-variable name="scopes" value="#[payload.scope]" />
            <set-variable name="userId" value="#[payload.sub]" />
        </when>
        <otherwise>
            <raise-error type="SECURITY:INVALID_TOKEN" description="Token validation failed" />
        </otherwise>
    </choice>
    
    <error-handler>
        <on-error-propagate>
            <logger message="Token validation failed for token: #[vars.bearerToken]" level="WARN" />
            <ee:transform>
                <ee:message>
                    <ee:set-payload><![CDATA[%dw 2.0
output application/json
---
{
    error: "INVALID_TOKEN",
    message: "The provided token is invalid or expired"
}
]]></ee:set-payload>
                </ee:message>
                <ee:variables>
                    <ee:set-variable name="httpStatus" value="401" />
                </ee:variables>
            </ee:transform>
        </on-error-propagate>
    </error-handler>
</flow>
```

### 12.2 Rate Limiting Implementation

```xml
<flow name="rate-limiting-flow">
    <!-- Extract client identifier -->
    <set-variable name="rateLimitKey" value="#[vars.clientId ++ ':' ++ attributes.requestPath]" />
    
    <!-- Check current rate limit -->
    <ee:cache cachingStrategy-ref="rate-limit-cache" key="#[vars.rateLimitKey]">
        <ee:transform>
            <ee:message>
                <ee:set-payload><![CDATA[%dw 2.0
output application/json
---
{
    requestCount: 1,
    windowStart: now(),
    lastRequest: now()
}
]]></ee:set-payload>
            </ee:message>
        </ee:transform>
    </ee:cache>
    
    <!-- Update request count -->
    <ee:transform>
        <ee:message>
            <ee:set-payload><![CDATA[%dw 2.0
output application/json
---
{
    requestCount: payload.requestCount + 1,
    windowStart: payload.windowStart,
    lastRequest: now()
}
]]></ee:set-payload>
        </ee:message>
    </ee:transform>
    
    <!-- Check if rate limit exceeded -->
    <choice>
        <when expression="#[payload.requestCount > p('api.rate.limit.requests.per.minute')]">
            <raise-error type="SECURITY:RATE_LIMIT_EXCEEDED" description="Rate limit exceeded" />
        </when>
        <otherwise>
            <logger message="Rate limit check passed for client: #[vars.clientId]" />
        </otherwise>
    </choice>
    
    <error-handler>
        <on-error-propagate type="SECURITY:RATE_LIMIT_EXCEEDED">
            <ee:transform>
                <ee:message>
                    <ee:set-payload><![CDATA[%dw 2.0
output application/json
---
{
    error: "RATE_LIMIT_EXCEEDED",
    message: "Too many requests. Please try again later.",
    retryAfter: 60
}
]]></ee:set-payload>
                </ee:message>
                <ee:variables>
                    <ee:set-variable name="httpStatus" value="429" />
                </ee:variables>
            </ee:transform>
        </on-error-propagate>
    </error-handler>
</flow>
```

## 13. Deployment Configuration

### 13.1 Environment-Specific Properties

**Development Environment (dev.properties)**:
```properties
# API Configuration
customer.api.host=dev-customer-api.internal.com
customer.api.port=443
inventory.api.host=dev-inventory-api.internal.com
inventory.api.port=443
payment.api.host=dev-payment-api.internal.com
payment.api.port=443
shipping.api.host=dev-shipping-api.internal.com
shipping.api.port=443

# Database Configuration
order.db.host=dev-orderdb.internal.com
order.db.port=3306
order.db.name=order_management_dev
order.db.user=${secure::order.db.username}
order.db.password=${secure::order.db.password}

# Message Queue Configuration
activemq.broker.url=tcp://dev-activemq.internal.com:61616

# OAuth Configuration
oauth.introspection.url=https://dev-auth.internal.com/oauth/introspect
oauth.client.credentials=${secure::oauth.client.credentials}

# Rate Limiting
api.rate.limit.requests.per.minute=100

# Circuit Breaker Configuration
circuit.breaker.failure.threshold=5
circuit.breaker.timeout.seconds=300
```

**Production Environment (prod.properties)**:
```properties
# API Configuration
customer.api.host=customer-api.internal.com
customer.api.port=443
inventory.api.host=inventory-api.internal.com
inventory.api.port=443
payment.api.host=payment-api.internal.com
payment.api.port=443
shipping.api.host=shipping-api.internal.com
shipping.api.port=443

# Database Configuration
order.db.host=prod-orderdb.internal.com
order.db.port=3306
order.db.name=order_management
order.db.user=${secure::order.db.username}
order.db.password=${secure::order.db.password}

# Message Queue Configuration
activemq.broker.url=failover:(tcp://prod-activemq1.internal.com:61616,tcp://prod-activemq2.internal.com:61616)

# OAuth Configuration
oauth.introspection.url=https://auth.internal.com/oauth/introspect
oauth.client.credentials=${secure::oauth.client.credentials}

# Rate Limiting
api.rate.limit.requests.per.minute=1000

# Circuit Breaker Configuration
circuit.breaker.failure.threshold=10
circuit.breaker.timeout.seconds=300
```

### 13.2 CI/CD Pipeline Configuration

**Jenkinsfile for Automated Deployment**:
```groovy
pipeline {
    agent any
    
    environment {
        ANYPOINT_USERNAME = credentials('anypoint-username')
        ANYPOINT_PASSWORD = credentials('anypoint-password')
        ANYPOINT_ORG_ID = credentials('anypoint-org-id')
        ANYPOINT_ENV_ID = credentials('anypoint-env-id')
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/company/order-management-mule.git'
            }
        }
        
        stage('Build and Test') {
            steps {
                sh 'mvn clean compile'
                sh 'mvn test'
                sh 'mvn munit:test'
            }
            post {
                always {
                    publishTestResults testResultsPattern: 'target/surefire-reports/*.xml'
                    publishHTML([
                        allowMissing: false,
                        alwaysLinkToLastBuild: false,
                        keepAll: true,
                        reportDir: 'target/site/munit/coverage',
                        reportFiles: 'summary.html',
                        reportName: 'MUnit Coverage Report'
                    ])
                }
            }
        }
        
        stage('Package') {
            steps {
                sh 'mvn clean package'
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }
        
        stage('Deploy to Dev') {
            when { branch 'develop' }
            steps {
                sh '''
                    mvn deploy -DmuleDeploy \
                    -Danypoint.username=${ANYPOINT_USERNAME} \
                    -Danypoint.password=${ANYPOINT_PASSWORD} \
                    -DorganizationId=${ANYPOINT_ORG_ID} \
                    -DenvironmentId=${ANYPOINT_ENV_ID} \
                    -DapplicationName=order-management-dev \
                    -Dworkers
