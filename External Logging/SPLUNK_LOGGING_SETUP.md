# Splunk External Logging Configuration

## Overview
This document describes the Splunk HTTP Event Collector (HEC) integration that has been added to the Product Catalog API for external logging capabilities.

## Components Added

### 1. Maven Dependencies (pom.xml)
- `org.apache.logging.log4j:log4j-core:2.17.2` - Enhanced Log4j2 support
- `org.apache.httpcomponents:httpclient:4.5.13` - HTTP client for Splunk communication

### 2. Log4j2 Configuration (log4j2.xml)
- **Splunk HTTP Appender**: Sends logs directly to Splunk HEC endpoint
- **Async Wrapper**: Improves performance by using asynchronous logging
- **JSON Template Layout**: Structures log data in Splunk-friendly JSON format

### 3. Configuration Files
Environment-specific Splunk settings in:
- `config-dev.yaml` - Development environment
- `config-staging.yaml` - Staging environment  
- `config-prod.yaml` - Production environment

### 4. JSON Layout Template (SplunkJsonLayout.json)
Custom JSON structure for optimal Splunk indexing with:
- Timestamp formatting
- Log level and logger information
- Message content
- Thread details
- MDC (Mapped Diagnostic Context) data
- Exception stack traces
- Environment metadata

## Configuration Properties

### Required Splunk Settings
```yaml
splunk:
  url: "https://your-splunk-server:8088"  # Splunk HEC endpoint
  token: "your_hec_token"                 # HEC authentication token
  log:
    level: "INFO"                         # Minimum log level to send
  enabled: true                           # Enable/disable Splunk logging
  index: "main"                           # Target Splunk index
  sourcetype: "mule:log4j"               # Splunk sourcetype
```

### Environment-Specific Configurations

#### Development
- **URL**: `http://localhost:8088` (Local Splunk instance)
- **Log Level**: `DEBUG` (Verbose logging)
- **Index**: `main`

#### Staging
- **URL**: `https://staging-splunk.company.com:8088`
- **Log Level**: `INFO` (Standard logging)
- **Index**: `staging`

#### Production
- **URL**: `https://prod-splunk.company.com:8088`
- **Log Level**: `WARN` (Error and warning only)
- **Index**: `production`

## Setup Instructions

### 1. Splunk Configuration
1. Enable HTTP Event Collector in Splunk
2. Create a new HEC token with appropriate permissions
3. Configure the target index (create if it doesn't exist)
4. Note the HEC endpoint URL

### 2. Application Configuration
1. Update the environment-specific YAML files with your Splunk details:
   ```yaml
   splunk:
     url: "https://your-splunk-server:8088"
     token: "your-actual-hec-token"
   ```

### 3. Environment Variables (Alternative)
You can also configure via environment variables:
- `splunk.url` - Splunk HEC URL
- `splunk.token` - HEC authentication token
- `splunk.log.level` - Minimum log level

### 4. Deployment
Deploy the application with the updated configuration.

## Log Structure in Splunk

Each log entry will contain:
```json
{
  "timestamp": "2026-04-02T15:00:00.123Z",
  "level": "INFO",
  "logger": "com.example.ProductCatalog",
  "message": "Processing product request",
  "thread": "http-nio-8081-exec-1",
  "mdc": {
    "correlationId": "abc-123-def",
    "processorPath": "product-catalog-flow"
  },
  "source": {
    "host": "app-server-01",
    "sourcetype": "mule:log4j",
    "source": "product-catalog-imp",
    "index": "main"
  },
  "fields": {
    "application": "product-catalog-imp",
    "environment": "dev",
    "correlationId": "abc-123-def",
    "processorPath": "product-catalog-flow"
  }
}
```

## Features

### Dual Logging
- **File Logging**: Continues to write to local log files
- **Splunk Logging**: Simultaneously sends logs to Splunk HEC
- Both can be configured independently

### Asynchronous Processing
- Uses async appenders to prevent logging from blocking application performance
- Buffer size of 1024 events for optimal throughput

### Environment Awareness
- Automatically includes environment information in log metadata
- Different log levels per environment
- Environment-specific Splunk indexes

### Mule Context Integration
- Captures Mule-specific MDC data (correlationId, processorPath)
- Includes thread information for debugging
- Preserves exception stack traces

## Monitoring and Troubleshooting

### Health Check
Monitor the application logs for Splunk connectivity issues:
- Connection timeouts
- Authentication failures
- HTTP errors

### Performance Impact
- Async logging minimizes performance impact
- Monitor buffer overflow warnings
- Adjust buffer size if needed

### Common Issues
1. **Connection Refused**: Check Splunk URL and network connectivity
2. **401 Unauthorized**: Verify HEC token is valid and has proper permissions
3. **403 Forbidden**: Check HEC token permissions and index access
4. **Logs Not Appearing**: Verify index configuration and search timeframe

## Security Considerations

- HEC tokens should be stored securely (consider using encryption)
- Use HTTPS for production Splunk endpoints
- Limit HEC token permissions to required indexes only
- Consider implementing log data masking for sensitive information

## Support and Maintenance

### Regular Tasks
- Monitor HEC token expiration
- Review and rotate authentication tokens
- Monitor Splunk index capacity
- Adjust log levels based on operational needs

### Performance Tuning
- Adjust buffer sizes based on log volume
- Configure appropriate timeout values
- Monitor network latency to Splunk

### Updates
When updating Log4j2 or HTTP client versions:
1. Test in development environment first
2. Verify Splunk connectivity after updates
3. Monitor for any configuration compatibility issues