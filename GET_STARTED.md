# 🚀 Get Started with Your Voice Assistant

Everything is set up! Here's what you need to do to get your voice assistant running.

## ✅ What's Been Set Up

Your project now includes:

1. **LiveKit Server** (Docker) - WebRTC media server
2. **Token Server** (Node.js) - Authentication service
3. **Voice Agent** (Python) - AI-powered voice assistant
4. **React Native App** - Mobile client

## 📋 Prerequisites Checklist

Before starting, make sure you have:

- [ ] Docker Desktop installed and running
- [ ] Node.js 18+ installed
- [ ] Python 3.11+ installed
- [ ] OpenAI API key ([Get one here](https://platform.openai.com/api-keys))
- [ ] iOS Simulator or Android Emulator set up

## 🎯 Quick Start (5 Minutes)

### Step 1: Start Services

Run the automated setup script:

```bash
./start.sh
```

This starts:
- ✅ LiveKit server (Docker)
- ✅ Token server (Node.js)

### Step 2: Add Your OpenAI API Key

Edit the agent configuration:

```bash
nano agent/.env
```

Add your OpenAI API key:
```
OPENAI_API_KEY=sk-your-actual-api-key-here
```

Save and exit (Ctrl+X, then Y, then Enter).

### Step 3: Start the Agent

```bash
cd agent

# Create and activate virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Start the agent
python agent.py start
```

Keep this terminal open. You should see:
```
INFO:voice-assistant:Connecting to room: ...
```

### Step 4: Run the App

Open a new terminal and run:

```bash
# For iOS
npx expo run:ios

# For Android
npx expo run:android
```

### Step 5: Test It! 🎉

1. The app launches on your device
2. You hear: "Hello! I'm your voice assistant. How can I help you today?"
3. Start talking!

## 🛑 Stopping Services

When you're done:

```bash
./stop.sh
```

## 📱 Using on a Physical Device

If testing on a physical device (not simulator/emulator):

1. Find your computer's IP address:
   ```bash
   # macOS/Linux
   ifconfig | grep "inet " | grep -v 127.0.0.1
   
   # Windows
   ipconfig
   ```

2. Update `hooks/useConnectionDetails.ts`:
   ```typescript
   const localTokenServerUrl = 'http://YOUR_IP:3001/token';
   ```

3. Update `.env.local`:
   ```
   LIVEKIT_URL=ws://YOUR_IP:7880
   ```

4. Restart the token server:
   ```bash
   cd token-server
   npm start
   ```

## 🔧 Customization

### Change Agent Personality

Edit `agent/agent.py` and modify the system prompt:

```python
chat_ctx=llm.ChatContext().append(
    role="system",
    text=(
        "You are a helpful voice assistant. "
        "Your custom personality here..."
    ),
),
```

### Change Voice

In `agent/agent.py`, change the TTS voice:

```python
tts=openai.TTS(voice="alloy"),  # Options: alloy, echo, fable, onyx, nova, shimmer
```

### Change AI Model

In `agent/agent.py`, change the LLM model:

```python
llm=openai.LLM(model="gpt-4o"),  # Options: gpt-4o, gpt-4o-mini, gpt-4-turbo
```

### Customize UI

Edit files in `app/assistant/` to modify the app's appearance and behavior.

## 📚 Documentation

- **Quick Start**: [QUICKSTART.md](QUICKSTART.md) - Fast setup guide
- **Detailed Setup**: [SETUP.md](SETUP.md) - Comprehensive instructions
- **Project Structure**: [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) - Architecture overview
- **Original README**: [README.md](README.md) - Template information

## 🐛 Troubleshooting

### "Docker is not running"
Start Docker Desktop and try again.

### "Token server failed to start"
Check if port 3001 is available:
```bash
lsof -i :3001
```

### "Agent not responding"
1. Check your OpenAI API key is correct
2. Verify all services are running
3. Check agent logs for errors

### "Cannot connect to LiveKit server"
```bash
docker-compose ps  # Check if running
docker-compose logs livekit-server  # Check logs
```

### More Help
See [QUICKSTART.md](QUICKSTART.md#troubleshooting) for detailed troubleshooting.

## 🎓 Next Steps

Once everything is working:

1. **Explore the code**
   - Check out `agent/agent.py` for agent logic
   - Look at `app/assistant/index.tsx` for UI code
   - Review `token-server/server.js` for authentication

2. **Add features**
   - Implement custom voice commands
   - Add conversation history
   - Integrate with your backend
   - Add user authentication

3. **Deploy to production**
   - Use LiveKit Cloud or self-host
   - Set up proper authentication
   - Configure SSL/TLS
   - Monitor performance

## 💡 Tips

- **Development**: Use `gpt-4o-mini` for faster/cheaper responses
- **Production**: Use `gpt-4o` for better quality
- **Testing**: Use the web version (`npm run web`) for quick testing
- **Debugging**: Check logs in all three services (LiveKit, token server, agent)

## 🆘 Getting Help

- **LiveKit Community**: https://livekit.io/join-slack
- **OpenAI Support**: https://help.openai.com
- **Expo Forums**: https://forums.expo.dev

## 🎉 You're All Set!

Run `./start.sh` and start building your voice assistant!

---

**Happy coding! 🚀**

