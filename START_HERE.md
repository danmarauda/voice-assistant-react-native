# 🎯 START HERE - Complete Automated Setup

## Everything in One Command! 🚀

Your LiveKit Voice Assistant is now **fully automated**. Just run one command and everything will be set up for you!

---

## ⚡ Quick Start (30 seconds)

### 1. Run the Setup Script

```bash
./start.sh
```

### 2. When Prompted, Enter Your OpenAI API Key

```
Please enter your OpenAI API key (or press Enter to skip):
sk-your-api-key-here
```

### 3. Run the App

```bash
npx expo run:ios  # or npx expo run:android
```

**That's it!** 🎉

---

## 📋 What You Need

Before running `./start.sh`, make sure you have:

- [ ] **Docker Desktop** - Running
- [ ] **Node.js 18+** - Installed
- [ ] **Python 3.11+** - Installed  
- [ ] **OpenAI API Key** - Ready to paste ([Get one here](https://platform.openai.com/api-keys))

---

## 🤖 What the Script Does

The `start.sh` script automatically:

1. ✅ Checks prerequisites (Docker, Node.js, Python)
2. ✅ Creates environment files
3. ✅ Starts LiveKit server (Docker)
4. ✅ Installs & starts token server (Node.js)
5. ✅ Creates Python virtual environment
6. ✅ Installs Python dependencies
7. ✅ Asks for your OpenAI API key
8. ✅ Starts the voice agent
9. ✅ Installs React Native dependencies

**All services will be running when it completes!**

---

## 🎬 What You'll See

```
========================================
LiveKit Voice Assistant Setup
========================================

Checking prerequisites...

✓ Docker is running
✓ Node.js is installed (v20.x.x)
✓ Python is installed (Python 3.11.x)

========================================
Step 1: Starting LiveKit Server
========================================

✓ LiveKit server is running
✓ LiveKit server is responding

========================================
Step 2: Setting Up Token Server
========================================

✓ Token server is running (PID: 12345)
✓ Token server is responding

========================================
Step 3: Setting Up Voice Agent
========================================

Please enter your OpenAI API key (or press Enter to skip):
█
```

**👆 Paste your OpenAI API key here**

```
✓ OpenAI API key saved
✓ Virtual environment created
✓ Python dependencies installed
✓ Voice agent is running (PID: 12346)

========================================
Step 4: Setting Up React Native App
========================================

✓ React Native dependencies installed

========================================
Setup Complete! 🎉
========================================

Services Status:
  • LiveKit Server: ✓ Running (ws://localhost:7880)
  • Token Server: ✓ Running (http://localhost:3001)
  • Voice Agent: ✓ Running

Next Steps:
  1. Run the app:
     npx expo run:ios  # or npx expo run:android
```

---

## 🛑 Stopping Everything

When you're done:

```bash
./stop.sh
```

This stops:
- Voice agent
- Token server  
- LiveKit server
- Cleans up logs

---

## 📱 Running the App

After setup completes:

### iOS
```bash
npx expo run:ios
```

### Android
```bash
npx expo run:android
```

### Web (for testing)
```bash
npm run web
```

---

## 🔧 If Something Goes Wrong

### Check Service Status

```bash
# All services
docker-compose ps

# View logs
docker-compose logs -f livekit-server  # LiveKit
tail -f token-server.log               # Token server
tail -f agent.log                      # Agent
```

### Restart Everything

```bash
./stop.sh
./start.sh
```

### Common Issues

**"Docker is not running"**
- Start Docker Desktop
- Run `./start.sh` again

**"Port already in use"**
- Stop conflicting services
- Or run `./stop.sh` first

**"Agent failed to start"**
- Check your OpenAI API key in `agent/.env`
- View logs: `tail -f agent.log`

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| **START_HERE.md** | 👈 You are here! Quick overview |
| **README_AUTOMATED_SETUP.md** | Detailed automated setup guide |
| **QUICKSTART.md** | 5-minute manual setup |
| **SETUP.md** | Complete setup documentation |
| **STATUS.md** | Current system status |
| **PROJECT_STRUCTURE.md** | Architecture overview |

---

## 🎨 Customization

### Change Agent Personality

Edit `agent/agent.py`:

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

In `agent/agent.py`:

```python
tts=openai.TTS(voice="alloy"),  
# Options: alloy, echo, fable, onyx, nova, shimmer
```

### Change AI Model

In `agent/agent.py`:

```python
llm=openai.LLM(model="gpt-4o"),  
# Options: gpt-4o, gpt-4o-mini, gpt-4-turbo
```

---

## 🌐 Using on Physical Device

For physical devices (not simulator), you need your computer's IP:

1. **Find your IP**:
   ```bash
   # macOS/Linux
   ifconfig | grep "inet " | grep -v 127.0.0.1
   
   # Windows
   ipconfig
   ```

2. **Update configuration**:
   
   Edit `hooks/useConnectionDetails.ts`:
   ```typescript
   const localTokenServerUrl = 'http://YOUR_IP:3001/token';
   ```
   
   Edit `.env`:
   ```
   LIVEKIT_URL=ws://YOUR_IP:7880
   ```

3. **Restart services**:
   ```bash
   ./stop.sh
   ./start.sh
   ```

---

## ✨ Features

- 🎤 **Voice Input** - Speak naturally to the assistant
- 🤖 **AI Responses** - Powered by OpenAI GPT-4
- 🔊 **Voice Output** - Natural text-to-speech
- 💬 **Chat Interface** - See conversation history
- 📱 **Mobile First** - iOS and Android support
- 🐳 **Docker** - Easy deployment
- 🔐 **Secure** - Token-based authentication

---

## 🚀 Next Steps

1. ✅ Run `./start.sh`
2. ✅ Enter your OpenAI API key
3. ✅ Run `npx expo run:ios` or `npx expo run:android`
4. ✅ Talk to your assistant!
5. 🎨 Customize the agent personality
6. 🎨 Modify the UI
7. 🚀 Deploy to production

---

## 💡 Pro Tips

- Use `gpt-4o-mini` for faster/cheaper responses during development
- Use `gpt-4o` for better quality in production
- Check logs if something doesn't work: `tail -f agent.log`
- The agent learns from conversation context
- You can interrupt the agent while it's speaking

---

## 🆘 Need Help?

- **LiveKit Community**: https://livekit.io/join-slack
- **OpenAI Support**: https://help.openai.com
- **Expo Forums**: https://forums.expo.dev
- **Documentation**: See [SETUP.md](SETUP.md)

---

## 🎉 You're Ready!

Just run:

```bash
./start.sh
```

And start building your voice assistant! 🚀

---

**Made with ❤️ using LiveKit, OpenAI, and React Native**

