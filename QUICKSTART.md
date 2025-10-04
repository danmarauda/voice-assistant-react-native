# Quick Start Guide

Get your LiveKit Voice Assistant running in 5 minutes!

## Prerequisites

- Docker Desktop installed and running
- Node.js 18+ installed
- Python 3.11+ installed
- OpenAI API key ([Get one here](https://platform.openai.com/api-keys))

## Quick Setup (Automated)

### 1. Run the setup script

```bash
./start.sh
```

This will automatically:
- Create environment files
- Start the LiveKit server in Docker
- Install and start the token server
- Set up the agent directory

### 2. Configure OpenAI API Key

Edit `agent/.env` and add your OpenAI API key:

```bash
nano agent/.env  # or use your preferred editor
```

Add this line:
```
OPENAI_API_KEY=sk-your-actual-api-key-here
```

### 3. Start the Agent

```bash
cd agent

# Create virtual environment
python -m venv venv

# Activate it
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Start the agent
python agent.py start
```

You should see output like:
```
INFO:voice-assistant:Connecting to room: ...
```

### 4. Install React Native Dependencies

In a new terminal:

```bash
npm install
```

### 5. Run the App

For iOS:
```bash
npx expo run:ios
```

For Android:
```bash
npx expo run:android
```

### 6. Test It!

1. The app should launch on your device/simulator
2. You'll hear: "Hello! I'm your voice assistant. How can I help you today?"
3. Start talking!

## Stopping Services

```bash
./stop.sh
```

## Troubleshooting

### "Cannot connect to LiveKit server"

Check if Docker is running:
```bash
docker ps
```

You should see `livekit-server` in the list.

### "Token server not responding"

Check if it's running:
```bash
cat token-server.pid
ps aux | grep node
```

Restart it:
```bash
cd token-server
npm start
```

### "Agent not responding"

1. Check your OpenAI API key in `agent/.env`
2. Make sure the agent is running (you should see logs)
3. Check that all three services are running:
   - LiveKit server (Docker)
   - Token server (Node.js)
   - Agent (Python)

### "No audio on physical device"

For physical devices, you need to use your computer's IP address instead of `localhost`.

1. Find your IP address:
   ```bash
   # macOS/Linux
   ifconfig | grep "inet "
   
   # Windows
   ipconfig
   ```

2. Edit `hooks/useConnectionDetails.ts`:
   ```typescript
   const localTokenServerUrl = 'http://YOUR_IP_ADDRESS:3001/token';
   ```

3. Update `.env.local`:
   ```
   LIVEKIT_URL=ws://YOUR_IP_ADDRESS:7880
   ```

4. Restart the token server

## Manual Setup

If you prefer to set up manually, see [SETUP.md](SETUP.md) for detailed instructions.

## Next Steps

- Customize the agent's personality in `agent/agent.py`
- Modify the UI in `app/assistant/index.tsx`
- Add custom voice commands
- Deploy to production

## Resources

- [Full Setup Guide](SETUP.md)
- [LiveKit Documentation](https://docs.livekit.io/)
- [LiveKit Agents](https://docs.livekit.io/agents/)
- [OpenAI API](https://platform.openai.com/docs)

