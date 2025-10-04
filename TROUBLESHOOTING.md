# Troubleshooting Guide

## Agent Not Talking

If the voice agent isn't speaking when you connect, follow these steps:

### 1. Check All Services Are Running

```bash
# Check LiveKit server
docker-compose ps

# Check token server
curl http://localhost:3001/health
# or for physical device:
curl http://192.168.1.30:3001/health

# Check agent process
ps aux | grep "agent.py" | grep -v grep
```

### 2. Verify Agent Logs

```bash
tail -f agent.log
```

You should see:
- ✅ `registered worker` - Agent connected to LiveKit
- ✅ `Connecting to room` - Agent joining room
- ✅ `Starting voice assistant for participant` - Agent found participant
- ✅ `Voice assistant started successfully` - Agent ready

### 3. Test the Connection Flow

1. **Kill the app** on your device (swipe up and close it completely)
2. **Relaunch the app**
3. **Tap "Start Voice Assistant"**
4. **Watch the agent logs** in real-time:
   ```bash
   tail -f agent.log
   ```

### 4. Common Issues

#### Issue: "Agent registered but never joins room"

**Solution**: The agent needs to accept jobs for rooms. This has been fixed in the latest version.

Restart the agent:
```bash
./stop.sh
./start.sh
```

#### Issue: "No audio from agent"

**Checklist**:
- ✅ OpenAI API key is set in `agent/.env`
- ✅ iPhone volume is turned up
- ✅ App has microphone permissions
- ✅ Not in silent mode on iPhone

**Test**:
```bash
# Check if OpenAI key is set
grep OPENAI_API_KEY agent/.env
```

#### Issue: "Agent joins but immediately disconnects"

**Possible causes**:
1. OpenAI API key is invalid
2. Network connectivity issues
3. OpenAI API rate limits

**Check logs**:
```bash
grep -i "error\|exception" agent.log
```

#### Issue: "Can't hear agent on physical device"

**Solution**: Make sure you're using your Mac's IP address, not localhost.

```bash
# Run the network configuration helper
./configure-network.sh

# Select option 1 (Physical Device)
# Then restart services
./stop.sh
./start.sh
```

### 5. Manual Testing

Test each component individually:

#### Test LiveKit Server
```bash
curl http://localhost:7880
# Should return: OK
```

#### Test Token Server
```bash
curl -X POST http://localhost:3001/token \
  -H "Content-Type: application/json" \
  -d '{"roomName":"test-room","participantName":"test-user"}'
# Should return JSON with token
```

#### Test Agent Connection
```bash
# Agent logs should show:
grep "registered worker" agent.log
# Should show worker ID and connection info
```

### 6. Reset Everything

If nothing works, do a complete reset:

```bash
# Stop all services
./stop.sh

# Kill any remaining processes
pkill -f "node server.js"
pkill -f "agent.py"

# Remove Docker containers
docker-compose down -v

# Clean logs
rm -f *.log *.pid

# Start fresh
./start.sh
```

### 7. Check Network Configuration

For physical device testing:

```bash
# Verify your Mac's IP address
ifconfig | grep "inet " | grep -v 127.0.0.1

# Check .env file
cat .env | grep LIVEKIT_URL

# Check connection details hook
grep "localTokenServerUrl" hooks/useConnectionDetails.ts
```

Both should use your Mac's IP (e.g., 192.168.1.30), not localhost.

### 8. Verify OpenAI API Key

```bash
# Check if key is set
cat agent/.env | grep OPENAI_API_KEY

# Test the key (optional - requires curl and jq)
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer $(grep OPENAI_API_KEY agent/.env | cut -d'=' -f2)" \
  | jq '.data[0].id'
# Should return a model name like "gpt-4o-mini"
```

### 9. Debug Mode

Enable verbose logging:

```bash
# Stop the agent
kill $(cat agent.pid)

# Start with debug logging
cd agent
source venv/bin/activate
LIVEKIT_LOG_LEVEL=debug python agent.py start
```

Watch for detailed connection and audio processing logs.

### 10. App-Side Debugging

In the React Native app:

1. **Check Metro bundler logs** - Look for connection errors
2. **Check device console** - Use Xcode or Android Studio to view native logs
3. **Reload the app** - Press `r` in Metro bundler terminal

### Expected Flow

When everything works correctly:

1. **App starts** → Requests token from token server
2. **Token received** → App connects to LiveKit room
3. **Room joined** → Agent worker receives job assignment
4. **Agent joins** → Agent connects to same room
5. **Agent detects participant** → Agent starts voice assistant
6. **Greeting sent** → You hear: "Hello! I'm your voice assistant..."
7. **Ready** → Agent listens for your voice

### Still Not Working?

Check these files for configuration:

- `agent/agent.py` - Agent code
- `token-server/server.js` - Token generation
- `hooks/useConnectionDetails.ts` - App connection logic
- `.env` - Environment variables
- `agent/.env` - Agent environment variables

### Get Help

If you're still stuck:

1. **Check agent logs**: `tail -100 agent.log`
2. **Check token server logs**: `tail -100 token-server.log`
3. **Check LiveKit logs**: `docker-compose logs --tail=100 livekit-server`
4. **Check app logs**: Look at Metro bundler output

Share these logs when asking for help!

## Performance Issues

### Agent Response is Slow

**Possible causes**:
1. Network latency
2. OpenAI API latency
3. Large audio chunks

**Solutions**:
- Use WiFi 5GHz instead of 2.4GHz
- Move closer to WiFi router
- Check OpenAI API status: https://status.openai.com

### Audio Quality Issues

**Solutions**:
- Ensure good network connection
- Reduce background noise
- Speak clearly and at normal volume
- Check microphone permissions

### App Crashes

**Solutions**:
1. Check device logs in Xcode/Android Studio
2. Ensure all dependencies are installed
3. Try rebuilding the app:
   ```bash
   npx expo run:ios --device --clean
   ```

## Production Checklist

Before deploying to production:

- [ ] Use production LiveKit server (not localhost)
- [ ] Enable SSL/TLS (wss:// instead of ws://)
- [ ] Secure token server with authentication
- [ ] Set proper CORS policies
- [ ] Use environment-specific API keys
- [ ] Enable error tracking (Sentry, etc.)
- [ ] Set up monitoring and alerts
- [ ] Test on multiple devices
- [ ] Load test the agent
- [ ] Set up proper logging

