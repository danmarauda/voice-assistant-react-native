# Testing Guide - Voice Agent

## Quick Test

The agent is now configured and ready to test! Here's how:

### 1. Services Are Running

All services should already be running from `./start.sh`:

```bash
# Verify services
docker-compose ps                    # LiveKit server
curl http://localhost:3001/health    # Token server
tail -5 agent.log                    # Agent logs
```

### 2. Test on Your iPhone

**Important**: Make sure you're using the physical device configuration:

```bash
# Check your configuration
grep LIVEKIT_URL .env
# Should show: LIVEKIT_URL=ws://192.168.1.30:7880

grep localTokenServerUrl hooks/useConnectionDetails.ts
# Should show: const localTokenServerUrl = 'http://192.168.1.30:3001/token';
```

### 3. Launch the App

**Option A: From start.sh (Recommended)**
```bash
./start.sh
# When prompted, select option 2 (iOS Physical Device)
```

**Option B: Manual Launch**
```bash
npx expo run:ios --device
```

### 4. Test the Voice Assistant

1. **Close the app completely** on your iPhone (swipe up and kill it)
2. **Relaunch** the app
3. **Tap "Start Voice Assistant"**
4. **Listen** for the greeting: *"Hello! I'm your voice assistant. How can I help you today?"*
5. **Start talking!** Try saying:
   - "What's the weather like?"
   - "Tell me a joke"
   - "What can you help me with?"

### 5. Monitor the Agent

In a separate terminal, watch the agent logs in real-time:

```bash
tail -f agent.log
```

**Expected log sequence:**
1. `registered worker` - Agent connected to LiveKit ✅
2. `Connecting to room: voice-assistant-room` - Agent joining ✅
3. `Starting voice assistant for participant: user-xxxxx` - Agent found you ✅
4. `Voice assistant started successfully` - Ready! ✅

## What Was Fixed

### The Problem
The agent was running and registered with LiveKit, but it wasn't automatically joining rooms when participants connected.

### The Solution
Updated `agent/agent.py` to accept all room jobs:

```python
cli.run_app(
    WorkerOptions(
        entrypoint_fnc=entrypoint,
        request_fnc=lambda _: True,  # Accept jobs for any room
    ),
)
```

This tells the agent worker to automatically accept job assignments for all rooms.

## Troubleshooting

### Agent Not Speaking

**Check 1: Agent Logs**
```bash
tail -20 agent.log
```

Look for:
- ✅ `registered worker` - Agent is connected
- ✅ `Connecting to room` - Agent is joining
- ❌ No room connection? Agent might not be receiving jobs

**Check 2: OpenAI API Key**
```bash
grep OPENAI_API_KEY agent/.env
```

Make sure it's set and valid.

**Check 3: Network Configuration**
```bash
# For physical device, use your Mac's IP
./configure-network.sh
# Select option 1 (Physical Device)
```

### App Can't Connect

**Check 1: Token Server**
```bash
curl -X POST http://192.168.1.30:3001/token \
  -H "Content-Type: application/json" \
  -d '{"roomName":"test","participantName":"test"}'
```

Should return JSON with `url` and `token`.

**Check 2: LiveKit Server**
```bash
curl http://localhost:7880
# Should return: OK
```

**Check 3: Network**
```bash
# Verify your Mac's IP
ifconfig | grep "inet " | grep -v 127.0.0.1
```

Make sure your iPhone and Mac are on the same WiFi network.

### "Address Already in Use" Error

This is now fixed in `start.sh`, but if you see it:

```bash
# Kill all services
./stop.sh

# Or manually:
pkill -f "node.*server.js"
pkill -f "python.*agent.py"
docker-compose down

# Then restart
./start.sh
```

## Testing Checklist

Before testing, verify:

- [ ] All services running (`docker-compose ps`, `curl http://localhost:3001/health`)
- [ ] Agent registered (`grep "registered worker" agent.log`)
- [ ] OpenAI API key set (`grep OPENAI_API_KEY agent/.env`)
- [ ] Network configured for device (`.env` and `hooks/useConnectionDetails.ts`)
- [ ] iPhone and Mac on same WiFi
- [ ] App has microphone permissions
- [ ] iPhone volume is up

## Expected Behavior

### Successful Connection Flow

1. **App Launch** → Tap "Start Voice Assistant"
2. **Token Request** → App requests token from `http://192.168.1.30:3001/token`
3. **Token Received** → App gets LiveKit URL and JWT token
4. **Room Join** → App connects to `ws://192.168.1.30:7880` and joins room
5. **Agent Dispatch** → LiveKit dispatches agent to room
6. **Agent Join** → Agent connects to same room
7. **Participant Detection** → Agent detects you as participant
8. **Greeting** → Agent says: "Hello! I'm your voice assistant..."
9. **Ready** → Agent listens for your voice input
10. **Conversation** → You can now talk to the agent!

### What You Should See

**In agent.log:**
```json
{"message": "registered worker", "level": "INFO", ...}
{"message": "Connecting to room: voice-assistant-room", "level": "INFO", ...}
{"message": "Starting voice assistant for participant: user-abc123", "level": "INFO", ...}
{"message": "Voice assistant started successfully", "level": "INFO", ...}
```

**In the app:**
- Connection indicator shows "Connected"
- Audio waveform visualization appears
- You hear the greeting message
- Agent responds to your voice

## Performance Tips

### For Best Results

1. **Use WiFi 5GHz** instead of 2.4GHz
2. **Stay close to router** for testing
3. **Quiet environment** reduces background noise
4. **Speak clearly** at normal volume
5. **Wait for response** before speaking again

### If Agent is Slow

- Check OpenAI API status: https://status.openai.com
- Check network latency: `ping 192.168.1.30`
- Reduce background noise
- Ensure good WiFi signal

## Advanced Testing

### Test with Multiple Participants

The agent can handle multiple participants in the same room:

1. Open app on multiple devices
2. All join the same room
3. Agent will interact with all participants

### Test Different Prompts

Try various conversation types:
- Questions: "What's the capital of France?"
- Commands: "Tell me a story"
- Casual chat: "How are you today?"
- Follow-ups: Ask related questions

### Test Interruptions

The agent supports interruptions:
- Start speaking while agent is talking
- Agent should stop and listen to you

### Test Error Handling

- Disconnect WiFi mid-conversation
- Kill the agent process
- Invalid OpenAI API key
- Network latency

## Next Steps

Once basic testing works:

1. **Customize the agent** - Edit `agent/agent.py` to change personality
2. **Add features** - Implement custom functions/tools
3. **Improve UI** - Customize the React Native app
4. **Deploy** - Move to production LiveKit server
5. **Monitor** - Set up logging and analytics

## Getting Help

If you're stuck:

1. Check **TROUBLESHOOTING.md** for common issues
2. Review **agent.log**, **token-server.log**, and Docker logs
3. Verify all configuration files
4. Try a complete reset: `./stop.sh && ./start.sh`

## Success Criteria

✅ **You know it's working when:**

1. Agent logs show "Voice assistant started successfully"
2. You hear the greeting message on your iPhone
3. Agent responds to your voice input
4. Conversation flows naturally
5. No errors in logs

🎉 **Congratulations!** Your LiveKit voice assistant is working!

## What's Next?

Now that the agent is working, you can:

- **Customize the system prompt** in `agent/agent.py`
- **Add custom functions** for the agent to call
- **Improve the UI** in the React Native app
- **Add conversation history** persistence
- **Implement user authentication**
- **Deploy to production**

Happy building! 🚀

