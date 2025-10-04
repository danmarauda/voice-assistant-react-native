# LiveKit Token Server

A simple Express.js server for generating LiveKit access tokens.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Make sure the `.env.local` file exists in the parent directory with:
```
LIVEKIT_API_KEY=devkey
LIVEKIT_API_SECRET=secret
LIVEKIT_URL=ws://localhost:7880
```

3. Start the server:
```bash
npm start
```

Or for development with auto-reload:
```bash
npm run dev
```

## API Endpoints

### POST /token

Generate a token for a participant to join a room.

**Request Body:**
```json
{
  "roomName": "my-room",
  "participantName": "user123"
}
```

**Response:**
```json
{
  "url": "ws://localhost:7880",
  "token": "eyJhbGc...",
  "roomName": "my-room",
  "participantName": "user123"
}
```

### GET /token

Generate a token using query parameters (for testing).

**Example:**
```
GET /token?room=my-room&participant=user123
```

### GET /health

Health check endpoint.

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2024-01-01T12:00:00.000Z"
}
```

## Testing

Test the server with curl:

```bash
# Health check
curl http://localhost:3001/health

# Generate token
curl -X POST http://localhost:3001/token \
  -H "Content-Type: application/json" \
  -d '{"roomName":"test-room","participantName":"test-user"}'

# Generate token with GET
curl "http://localhost:3001/token?room=test-room&participant=test-user"
```

