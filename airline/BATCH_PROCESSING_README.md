# American Airlines API - Batch Processing Enhancement

## Overview
This enhancement adds batch processing capabilities to the American Airlines API for handling large volumes of flight records efficiently.

## Features

### 1. Batch Processing Flow
- **File-based trigger**: Monitors `/tmp/flights/input` directory for JSON files
- **API endpoint**: `POST /api/flights/batch` for direct batch processing
- **Independent record processing**: Each record is processed individually
- **Fault tolerance**: Failed records don't affect successful ones

### 2. Database Storage
- Automatic table creation for flight records
- Dedicated batch database configuration (H2 in-memory for testing)
- Separate from existing MySQL database to avoid conflicts

### 3. Error Handling
- **Validation errors**: Missing required fields (code, destination, price)
- **Database errors**: Connection issues, constraint violations
- **Processing errors**: Transformation or other runtime errors
- **Error collection**: All failed records collected with detailed error information

### 4. Email Notifications
- **Comprehensive summary**: Total, successful, and failed record counts
- **Processing duration**: Track batch processing time
- **Success rate**: Percentage calculation
- **Failed record details**: Complete error information for troubleshooting
- **HTML and text formats**: Rich email content with formatted tables

## API Usage

### Batch Processing Endpoint
```
POST /api/flights/batch
Content-Type: application/json

[
  {
    "code": "AA001",
    "destination": "LAX", 
    "departureDate": "2024-04-15",
    "price": 299.99,
    "planeType": "Boeing 737"
  },
  {
    "code": "AA002",
    "destination": "SFO",
    "departureDate": "2024-04-16", 
    "price": 449.50,
    "planeType": "Airbus A320"
  }
]
```

### Response Format
```json
{
  "message": "Batch processing completed",
  "summary": {
    "totalRecords": 2,
    "successfulRecords": 2,
    "failedRecords": 0,
    "processedAt": "2024-04-15 14:30:00"
  }
}
```

## Configuration

### Application Properties
```properties
# Batch Processing Configuration
batch.input.directory=/tmp/flights
batch.notification.email=admin@company.com

# Email Configuration  
email.user=your-email@gmail.com
email.password=your-app-password
```

### Required Fields
Each flight record must contain:
- `code`: Flight code (String, not null/empty)
- `destination`: Destination airport (String, not null/empty) 
- `price`: Flight price (Number, not null)

### Optional Fields
- `departureDate`: Date of departure (defaults to current date)
- `planeType`: Type of aircraft (defaults to "Unknown")

## File-based Processing

### File Location
Place JSON files in: `/tmp/flights/input/`

The file listener monitors this directory every 30 seconds for new `.json` files.

### File Format
Files should contain an array of flight objects:
```json
[
  {
    "code": "AA001",
    "destination": "LAX",
    "departureDate": "2024-04-15",
    "price": 299.99,
    "planeType": "Boeing 737"
  }
]
```

## Error Scenarios

### Validation Failures
Records missing required fields will be:
- Added to failed records collection
- Logged with WARNING level
- Included in email summary with error details

### Database Errors
Database connection or constraint failures:
- Caught and handled gracefully
- Logged with ERROR level
- Added to failed records with error details

### Email Failures
If email notification fails:
- Logged with ERROR level
- Does not affect batch processing success
- Uses `on-error-continue` to prevent flow failure

## Testing

### Sample Data
Use the provided `sample-flight-data.json` file which contains:
- 3 valid records
- 2 invalid records (missing required fields)

### Test Steps
1. **Start the application**:
   ```bash
   mvn clean compile
   mvn mule:run
   ```

2. **Test API endpoint**:
   ```bash
   curl -X POST http://localhost:8083/api/flights/batch \
     -H "Content-Type: application/json" \
     -d @sample-flight-data.json
   ```

3. **Test file-based processing**:
   - Create directory: `/tmp/flights/input/`
   - Copy `sample-flight-data.json` to the input directory
   - Monitor logs for processing activity

### Expected Results
- **Total Records**: 5
- **Successful Records**: 3
- **Failed Records**: 2
- **Email Summary**: Detailed report with failed record information

## Architecture Details

### Components Used
- **File Connector**: For monitoring input directory
- **Database Connector**: For H2 in-memory database
- **Email Connector**: For sending summary notifications
- **DataWeave**: For data transformations
- **Foreach Loop**: For individual record processing
- **Try-Catch**: For error handling per record

### Flow Structure
1. **File Trigger**: `flight-batch-processing-trigger`
2. **Main Processing**: `process-flight-batch`
3. **Record Storage**: `store-flight-record`
4. **Email Notification**: `send-batch-summary-email`
5. **API Endpoint**: `batch-flights-processing-api`

### Error Handling Strategy
- **Record Level**: Each record processed in try-catch block
- **Flow Level**: Email failures handled with `on-error-continue`
- **Database Level**: Connection errors propagated with details
- **Validation Level**: Missing fields logged and collected

## Performance Considerations

### Scalability
- Uses `foreach` for sequential processing
- Configurable batch size through application properties
- In-memory error collection suitable for moderate volumes
- Consider database persistence for large-scale operations

### Memory Management
- Records processed individually to avoid memory issues
- Failed records collection grows with failures
- Consider cleanup mechanisms for production use

## Production Deployment

### Configuration Updates
1. **Database**: Replace H2 with production database
2. **Email**: Configure SMTP settings for production
3. **File System**: Set appropriate directory permissions
4. **Monitoring**: Add application monitoring and alerts

### Security Considerations
- Secure email credentials using encryption
- Implement file system access controls
- Add authentication for batch API endpoint
- Consider data encryption for sensitive flight information

## Troubleshooting

### Common Issues
1. **File Permission Errors**: Ensure application has read/write access to batch directories
2. **Database Connection**: Verify database configuration and connectivity
3. **Email Authentication**: Check SMTP credentials and server settings
4. **Memory Issues**: Monitor heap usage for large batch files

### Log Monitoring
- **INFO Level**: Batch processing progress and completion
- **DEBUG Level**: Individual record processing details
- **WARN Level**: Validation failures and recoverable errors
- **ERROR Level**: Database errors and critical failures

## Future Enhancements

### Potential Improvements
1. **Batch Resume**: Implement checkpointing for interrupted processing
2. **Parallel Processing**: Add multi-threading for improved performance
3. **File Archive**: Move processed files to archive directory
4. **Real-time Monitoring**: Add metrics and dashboard
5. **Dead Letter Queue**: Implement retry mechanism for failed records
6. **Data Validation**: Add more sophisticated validation rules
7. **Audit Trail**: Complete processing history and audit logs
