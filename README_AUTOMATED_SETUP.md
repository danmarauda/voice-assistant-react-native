# 🚀 Automated Setup Guide

## One-Command Setup

Everything you need is now automated in the `start.sh` script!

### Prerequisites

Before running the script, make sure you have:

- ✅ Docker Desktop installed and running
- ✅ Node.js 18+ installed
- ✅ Python 3.11+ installed
- ✅ OpenAI API key ready ([Get one here](https://platform.openai.com/api-keys))

### Quick Start

Simply run:

```bash
./start.sh
```

The script will automatically:

1. ✅ Check all prerequisites (Docker, Node.js, Python)
2. ✅ Create environment files if needed
3. ✅ Start LiveKit server in Docker
4. ✅ Install and start the token server
5. ✅ Set up Python virtual environment
6. ✅ Install Python dependencies
7. ✅ Prompt for your OpenAI API key
8. ✅ Start the voice agent
9. ✅ Install React Native dependencies

### What Happens During Setup

#### Step 1: Prerequisites Check
The script verifies that Docker, Node.js, and Python are installed and running.

#### Step 2: LiveKit Server
- Starts the LiveKit server in a Docker container
- Waits for it to be healthy
- Tests connectivity

#### Step 3: Token Server
- Installs Node.js dependencies
- Starts the token server on port 3001
- Verifies it's responding

#### Step 4: Voice Agent
- Creates Python virtual environment
- Installs Python dependencies
- Prompts for OpenAI API key (you can paste it or skip)
- Starts the agent if API key is provided

#### Step 5: React Native App
- Installs npm dependencies for the mobile app

### Interactive Setup

When you run `./start.sh`, you'll see:

```
========================================
LiveKit Voice Assistant Setup
========================================

Checking prerequisites...

✓ Docker is running
✓ Node.js is installed (v20.x.x)
✓ Python is installed (Python 3.11.x)

✓ .env already exists

========================================
Step 1: Starting LiveKit Server
========================================

[+] Running 2/2
 ✔ Network agent-starter-react-native_livekit-network  Created
 ✔ Container livekit-server                            Started

Waiting for LiveKit server to be ready...
✓ LiveKit server is running
✓ LiveKit server is responding

========================================
Step 2: Setting Up Token Server
========================================

✓ Token server dependencies already installed

Starting token server...
✓ Token server is running (PID: 12345)
✓ Token server is responding

========================================
Step 3: Setting Up Voice Agent
========================================

✓ agent/.env already exists
⚠ OpenAI API key not configured
Please enter your OpenAI API key (or press Enter to skip):
```

**At this point, paste your OpenAI API key** (starts with `sk-`), or press Enter to skip and add it manually later.

```
✓ OpenAI API key saved

Creating Python virtual environment...
✓ Virtual environment created

Installing Python dependencies...
✓ Python dependencies installed

Starting voice agent...
✓ Voice agent is running (PID: 12346)

========================================
Step 4: Setting Up React Native App
========================================

✓ React Native dependencies already installed

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

Useful Commands:
  • View LiveKit logs: docker-compose logs -f livekit-server
  • View token server logs: tail -f token-server.log
  • View agent logs: tail -f agent.log
  • Stop all services: ./stop.sh
  • Check service status: docker-compose ps

Documentation:
  • Quick Start: QUICKSTART.md
  • Full Setup Guide: SETUP.md
  • Current Status: STATUS.md

Happy coding! 🚀
```

### Running the App

After the setup completes, run:

```bash
# For iOS
npx expo run:ios

# For Android
npx expo run:android
```

### Stopping All Services

To stop everything:

```bash
./stop.sh
```

This will:
- Stop the voice agent
- Stop the token server
- Stop the LiveKit server
- Clean up log files

### Skipping OpenAI API Key During Setup

If you press Enter when prompted for the OpenAI API key, the script will:
- Skip starting the agent
- Show you how to add the key manually
- Tell you how to start the agent later

To start the agent manually:

```bash
cd agent
source venv/bin/activate
python agent.py start
```

### Troubleshooting

#### "Docker is not running"
Start Docker Desktop and run `./start.sh` again.

#### "Token server failed to start"
Check if port 3001 is already in use:
```bash
lsof -i :3001
```

#### "Voice agent failed to start"
Check the logs:
```bash
tail -f agent.log
```

Common issues:
- Invalid OpenAI API key
- Missing Python dependencies
- Port conflicts

#### Services Already Running

If you run `./start.sh` when services are already running, it will:
- Skip creating files that already exist
- Restart Docker containers
- Start new instances of token server and agent

To cleanly restart everything:
```bash
./stop.sh
./start.sh
```

### What Gets Created

After running `./start.sh`, you'll have:

```
✅ .env                          # Environment variables
✅ token-server/node_modules/    # Token server dependencies
✅ token-server.pid              # Token server process ID
✅ token-server.log              # Token server logs
✅ agent/.env                    # Agent environment (with your API key)
✅ agent/venv/                   # Python virtual environment
✅ agent.pid                     # Agent process ID
✅ agent.log                     # Agent logs
✅ node_modules/                 # React Native dependencies
```

### Logs and Monitoring

View real-time logs:

```bash
# LiveKit server
docker-compose logs -f livekit-server

# Token server
tail -f token-server.log

# Voice agent
tail -f agent.log
```

Check service status:

```bash
# Docker containers
docker-compose ps

# Token server
cat token-server.pid && ps aux | grep $(cat token-server.pid)

# Voice agent
cat agent.pid && ps aux | grep $(cat agent.pid)
```

### Re-running Setup

You can run `./start.sh` multiple times. It will:
- ✅ Skip steps that are already complete
- ✅ Restart services that need restarting
- ✅ Preserve your configuration

### Manual Configuration

If you prefer to configure manually instead of using the interactive prompt:

1. Edit `agent/.env`:
   ```bash
   nano agent/.env
   ```

2. Add your OpenAI API key:
   ```
   OPENAI_API_KEY=sk-your-actual-key-here
   ```

3. Run the start script:
   ```bash
   ./start.sh
   ```

### Next Steps

Once setup is complete:

1. **Test the setup**: Run the mobile app and speak to the assistant
2. **Customize the agent**: Edit `agent/agent.py` to change personality
3. **Modify the UI**: Edit files in `app/assistant/`
4. **Deploy**: See [SETUP.md](SETUP.md) for production deployment

### Support

- **Documentation**: See [SETUP.md](SETUP.md) for detailed information
- **Quick Reference**: See [STATUS.md](STATUS.md) for current status
- **Community**: Join [LiveKit Slack](https://livekit.io/join-slack)

---

**That's it! One command to rule them all.** 🚀

