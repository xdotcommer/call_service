# Call Service

A Ruby/Sinatra service for processing and managing emergency service calls. This service provides endpoints for logging calls, retrieving call information, and monitoring service health.

## Overview

The Call Service is designed to handle emergency service calls data with features for:
- Logging new calls
- Retrieving call information
- Health monitoring
- Integration with APCO (Association of Public-Safety Communications Officials) services

## Requirements

- Ruby 3.3.0
- Bundler

## Installation

1. Clone the repository:
```bash
git clone https://github.com/xdotcommer/call_service
cd call_service
```

2. Install dependencies:
```bash
bundle install
```

## Configuration

The service requires several environment variables to be set:
- APCO service connection details

Create a `.env` file in the root directory:
```env
APCO_SERVICE_URL=http://apco_service:4000
```

## API Endpoints

### Health Check
```http
GET /health
```
Returns service health status including Redis connection state.

Response:
```json
{
  "status": "ok",
  "redis": "connected"
}
```

### Call Details
```http
POST /call_details
```
Records a new emergency service call.

Request body:
```json
{
  "incident_number": "22BU000002",
  "call_type": "Welfare Check",
  "call_type_group": "Public Service",
  "call_time": "2021-12-31T20:08:55-05:00",
  "call_origin": "911",
  "area": "Downtown",
  "area_name": "Central District",
  "latitude": 44.475410,
  "longitude": -73.197113,
  "priority": "High"
}
```

### Getting Calls
```http
GET /calls
```
Retrieves a list of all calls.

## Models

### Call
The Call model includes:
- Incident tracking
- Location information
- Call type classification
- Time and date details
- Priority handling
- APCO integration

## Development

1. Set up your development environment:
```bash
bundle install
```

2. Run the tests:
```bash
bundle exec rspec
```

3. Start the server:
```bash
bundle exec rackup
```

The service will be available at `http://localhost:9292`

## Testing

The project uses RSpec for testing. Run the test suite:

```bash
bundle exec rspec
```

Tests cover:
- API endpoints
- Call model validations
- Health checks
- APCO service integration

## Error Handling

The service handles various error cases:
- Invalid request data
- Database connection issues
- Redis connection failures
- APCO service integration errors

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Related Services

- [CAD Call Simulator](https://github.com/xdotcommer/cad-call-simulator) - A Python tool for simulating incident data
- [Call Service](https://github.com/xdotcommer/call_service) - Main call processing service
- [APCO Service](https://github.com/xdotcommer/apco_incident_types_service) - APCO code lookup service
- [Call Logger](https://github.com/xdotcommer/call_logger) - Persistent storage service for emergency call data

This microservices ecosystem provides a complete solution for:
- Simulating emergency calls (CAD Call Simulator)
- Processing and routing calls (Call Service)
- Standardizing call types (APCO Service)
- Storing call history (Call Logger)
