# Setup Guide for React Native Voice Assistant

This guide will help you set up everything needed to run the voice assistant app.

## Prerequisites

- Docker and Docker Compose installed
- Node.js 18+ installed
- Python 3.11+ (for running the agent locally)
- OpenAI API key (for the voice assistant agent)
- iOS Simulator or Android Emulator (or physical device)

## Step 1: Set Up LiveKit Token Server

The token server runs in Docker and provides authentication for the app.

### 1.1 Configure Environment Variables

Copy the example environment file:

```bash
cp .env.example .env.local
```

The default values in `.env.local` are suitable for local development:
- `LIVEKIT_API_KEY=devkey`
- `LIVEKIT_API_SECRET=secret`
- `LIVEKIT_URL=ws://localhost:7880`

**For production**, generate secure random values:

```bash
# Generate secure API key and secret
echo "LIVEKIT_API_KEY=$(openssl rand -base64 32)" >> .env.local
echo "LIVEKIT_API_SECRET=$(openssl rand -base64 32)" >> .env.local
```

### 1.2 Start the LiveKit Server

Start the LiveKit server using Docker Compose:

```bash
docker-compose up -d
```

Verify it's running:

```bash
docker-compose ps
```

You should see the `livekit-token-server` container running.

Check the logs:

```bash
docker-compose logs -f token-server
```

The server will be available at:
- WebSocket: `ws://localhost:7880`
- HTTP: `http://localhost:7880`

## Step 2: Set Up the Voice Assistant Agent

The agent is a Python program that handles voice interactions.

### 2.1 Configure Agent Environment

Navigate to the agent directory and set up environment variables:

```bash
cd agent
cp .env.example .env
```

Edit `agent/.env` and add your OpenAI API key:

```bash
LIVEKIT_URL=ws://localhost:7880
LIVEKIT_API_KEY=devkey
LIVEKIT_API_SECRET=secret
OPENAI_API_KEY=your_actual_openai_api_key_here
```

### 2.2 Option A: Run Agent Locally (Recommended for Development)

Install Python dependencies:

```bash
# Create a virtual environment (recommended)
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

Run the agent:

```bash
python agent.py start
```

The agent will connect to your LiveKit server and wait for participants to join.

### 2.3 Option B: Run Agent in Docker

Build the Docker image:

```bash
docker build -t voice-assistant-agent .
```

Run the agent container:

```bash
docker run --env-file .env --network host voice-assistant-agent
```

## Step 3: Configure the React Native App

### 3.1 Install Dependencies

From the project root:

```bash
npm install
```

### 3.2 Configure Connection Details

You have two options for connecting the app:

#### Option A: Use Local Token Server (Recommended)

Edit `hooks/useConnectionDetails.ts` and update the hardcoded values:

```typescript
const hardcodedUrl = 'ws://localhost:7880';
const hardcodedToken = ''; // Leave empty, we'll generate tokens
```

Or better yet, implement a simple token generation endpoint. For local development, you can use the LiveKit CLI to generate tokens:

```bash
# Install LiveKit CLI
brew install livekit  # macOS
# or download from https://github.com/livekit/livekit-cli/releases

# Generate a token
lk token create \
  --api-key devkey \
  --api-secret secret \
  --join --room test-room \
  --identity user123 \
  --valid-for 24h
```

#### Option B: Use LiveKit Cloud Sandbox

If you prefer to use LiveKit Cloud:

1. Create a LiveKit Cloud account at https://cloud.livekit.io
2. Create a new Sandbox Token Server
3. Copy your Sandbox ID
4. Update `hooks/useConnectionDetails.ts`:

```typescript
const sandboxID = 'your_sandbox_id_here';
```

## Step 4: Run the React Native App

### For iOS:

```bash
npx expo run:ios
```

### For Android:

```bash
npx expo run:android
```

### For Web (testing only):

```bash
npm run web
```

## Step 5: Test the Voice Assistant

1. Launch the app on your device/simulator
2. The app should connect to the LiveKit server
3. The agent should join the room automatically
4. You should hear a greeting: "Hello! I'm your voice assistant. How can I help you today?"
5. Start speaking to interact with the assistant

## Troubleshooting

### Token Server Issues

**Problem**: Can't connect to LiveKit server

**Solution**:
- Check if Docker container is running: `docker-compose ps`
- Check logs: `docker-compose logs -f token-server`
- Verify port 7880 is not in use: `lsof -i :7880`

### Agent Issues

**Problem**: Agent not responding

**Solution**:
- Check agent logs for errors
- Verify OpenAI API key is valid
- Ensure LIVEKIT_URL, API_KEY, and API_SECRET match the server configuration
- Check that the agent successfully connected to the room

### Mobile App Issues

**Problem**: App can't connect to server

**Solution**:
- For iOS Simulator/Android Emulator: Use `ws://localhost:7880`
- For physical devices: Use your computer's local IP address (e.g., `ws://192.168.1.100:7880`)
- Check that your firewall allows connections on port 7880

**Problem**: No audio/microphone not working

**Solution**:
- Check app permissions for microphone access
- On iOS: Settings > Privacy > Microphone
- On Android: Settings > Apps > Permissions

## Production Deployment

For production deployment:

1. **Use secure credentials**: Generate strong API keys and secrets
2. **Use HTTPS/WSS**: Set up SSL certificates for secure connections
3. **Deploy LiveKit server**: Use LiveKit Cloud or self-host on a VM
4. **Implement proper token generation**: Create a backend service to generate tokens
5. **Environment variables**: Never commit `.env.local` or `.env` files to version control

## Additional Resources

- [LiveKit Documentation](https://docs.livekit.io/)
- [LiveKit Agents Framework](https://docs.livekit.io/agents/)
- [LiveKit React Native SDK](https://github.com/livekit/client-sdk-react-native)
- [OpenAI API Documentation](https://platform.openai.com/docs)

## Support

- LiveKit Community Slack: https://livekit.io/join-slack
- GitHub Issues: https://github.com/livekit-examples/agent-starter-react-native/issues

