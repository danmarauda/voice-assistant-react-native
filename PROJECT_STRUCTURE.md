# Project Structure

This document explains the organization of the LiveKit Voice Assistant project.

## Directory Structure

```
agent-starter-react-native/
├── agent/                      # Python voice assistant agent
│   ├── agent.py               # Main agent code
│   ├── requirements.txt       # Python dependencies
│   ├── Dockerfile            # Docker configuration for agent
│   ├── .env.example          # Example environment variables
│   └── .env                  # Your environment variables (not in git)
│
├── token-server/              # Node.js token generation server
│   ├── server.js             # Express server for token generation
│   ├── package.json          # Node.js dependencies
│   └── README.md             # Token server documentation
│
├── app/                       # React Native app screens
│   ├── (start)/              # Start screen
│   ├── assistant/            # Voice assistant screen
│   │   ├── index.tsx         # Main assistant component
│   │   └── ui/               # UI components
│   └── _layout.tsx           # App layout
│
├── hooks/                     # React hooks
│   ├── useConnectionDetails.ts  # LiveKit connection management
│   └── ...                   # Other hooks
│
├── constants/                 # App constants
├── assets/                    # Images and other assets
│
├── docker-compose.yml         # Docker Compose configuration
├── livekit.yaml              # LiveKit server configuration
├── .env.local                # Environment variables (not in git)
├── .env.example              # Example environment variables
│
├── start.sh                  # Quick start script
├── stop.sh                   # Stop all services script
│
├── QUICKSTART.md             # Quick start guide
├── SETUP.md                  # Detailed setup guide
├── PROJECT_STRUCTURE.md      # This file
└── README.md                 # Original project README
```

## Key Components

### 1. LiveKit Server (Docker)

**Location**: Runs in Docker container  
**Configuration**: `docker-compose.yml`, `livekit.yaml`  
**Purpose**: WebRTC media server for real-time audio/video

**Ports**:
- 7880: WebSocket/HTTP
- 7881: TURN server
- 7882: UDP media

### 2. Token Server (Node.js)

**Location**: `token-server/`  
**Port**: 3001  
**Purpose**: Generates JWT tokens for client authentication

**Endpoints**:
- `POST /token` - Generate token with room and participant name
- `GET /token` - Generate token with query parameters
- `GET /health` - Health check

### 3. Voice Assistant Agent (Python)

**Location**: `agent/`  
**Purpose**: AI-powered voice assistant using OpenAI

**Features**:
- Voice Activity Detection (VAD)
- Speech-to-Text (STT)
- Language Model (LLM)
- Text-to-Speech (TTS)

**Dependencies**:
- livekit-agents
- OpenAI plugins
- Silero VAD
- Deepgram (optional)

### 4. React Native App

**Location**: `app/`, `hooks/`, `constants/`  
**Framework**: Expo + React Native  
**Purpose**: Mobile client for voice interaction

**Key Files**:
- `app/assistant/index.tsx` - Main assistant UI
- `hooks/useConnectionDetails.ts` - Connection management
- `app.json` - Expo configuration

## Environment Variables

### Root `.env.local`

Used by Docker Compose and token server:

```env
LIVEKIT_API_KEY=devkey
LIVEKIT_API_SECRET=secret
LIVEKIT_URL=ws://localhost:7880
```

### Agent `.env`

Used by the Python agent:

```env
LIVEKIT_URL=ws://localhost:7880
LIVEKIT_API_KEY=devkey
LIVEKIT_API_SECRET=secret
OPENAI_API_KEY=sk-...
```

## Data Flow

```
┌─────────────────┐
│  React Native   │
│      App        │
└────────┬────────┘
         │
         │ 1. Request token
         ▼
┌─────────────────┐
│  Token Server   │
│   (Node.js)     │
└────────┬────────┘
         │
         │ 2. Return token + URL
         ▼
┌─────────────────┐
│  React Native   │
│      App        │
└────────┬────────┘
         │
         │ 3. Connect with token
         ▼
┌─────────────────┐
│ LiveKit Server  │
│    (Docker)     │
└────────┬────────┘
         │
         │ 4. Join room
         │
         ├──────────────────┐
         │                  │
         ▼                  ▼
┌─────────────────┐  ┌─────────────────┐
│  React Native   │  │  Voice Agent    │
│      App        │  │    (Python)     │
└─────────────────┘  └─────────────────┘
         │                  │
         │                  │
         └──────────────────┘
              5. Audio stream
```

## Service Dependencies

```
LiveKit Server (Docker)
    ↓
Token Server (Node.js) ← depends on LiveKit Server
    ↓
React Native App ← depends on Token Server
    ↓
Voice Agent (Python) ← depends on LiveKit Server
```

## Development Workflow

1. **Start LiveKit Server**: `docker-compose up -d`
2. **Start Token Server**: `cd token-server && npm start`
3. **Start Agent**: `cd agent && python agent.py start`
4. **Run App**: `npx expo run:ios` or `npx expo run:android`

Or use the automated script:
```bash
./start.sh
```

## Production Considerations

### Security
- Use strong API keys and secrets
- Enable HTTPS/WSS
- Implement rate limiting on token server
- Validate token requests

### Scalability
- Deploy LiveKit server on dedicated infrastructure
- Use LiveKit Cloud for managed hosting
- Scale token server horizontally
- Deploy agents on worker nodes

### Monitoring
- Monitor LiveKit server metrics
- Track token generation rates
- Monitor agent performance
- Set up error logging and alerts

## Customization Points

### Agent Behavior
Edit `agent/agent.py`:
- Change system prompt
- Modify voice settings
- Add custom functions
- Change LLM model

### UI/UX
Edit `app/assistant/`:
- Customize colors and styling
- Add new UI components
- Modify animations
- Add features

### Token Generation
Edit `token-server/server.js`:
- Add authentication
- Implement custom room logic
- Add participant metadata
- Integrate with your auth system

## Testing

### Test Token Server
```bash
curl http://localhost:3001/health
curl -X POST http://localhost:3001/token \
  -H "Content-Type: application/json" \
  -d '{"roomName":"test","participantName":"user1"}'
```

### Test LiveKit Server
```bash
docker-compose logs -f livekit-server
```

### Test Agent
```bash
cd agent
python agent.py start
# Check logs for connection status
```

## Troubleshooting

See [QUICKSTART.md](QUICKSTART.md#troubleshooting) for common issues and solutions.

## Additional Resources

- [LiveKit Documentation](https://docs.livekit.io/)
- [LiveKit Agents Framework](https://docs.livekit.io/agents/)
- [Expo Documentation](https://docs.expo.dev/)
- [OpenAI API Reference](https://platform.openai.com/docs)

