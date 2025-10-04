#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}LiveKit Voice Assistant Setup${NC}"
echo -e "${GREEN}========================================${NC}\n"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo -e "${BLUE}Checking prerequisites...${NC}\n"

# Check Docker
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}✗ Docker is not running. Please start Docker and try again.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker is running${NC}"

# Check Node.js
if ! command_exists node; then
    echo -e "${RED}✗ Node.js is not installed. Please install Node.js 18+ and try again.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Node.js is installed ($(node --version))${NC}"

# Check Python
if ! command_exists python3; then
    echo -e "${RED}✗ Python 3 is not installed. Please install Python 3.11+ and try again.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Python is installed ($(python3 --version))${NC}\n"

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}Creating .env from .env.example...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✓ Created .env${NC}\n"
else
    echo -e "${GREEN}✓ .env already exists${NC}\n"
fi

# Start LiveKit server
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Step 1: Starting LiveKit Server${NC}"
echo -e "${BLUE}========================================${NC}\n"

docker-compose up -d

# Wait for LiveKit server to be ready
echo -e "${YELLOW}Waiting for LiveKit server to be ready...${NC}"
sleep 5

# Check if LiveKit server is running
if docker-compose ps | grep -q "livekit-server.*Up"; then
    echo -e "${GREEN}✓ LiveKit server is running${NC}"

    # Test the server
    if curl -s http://localhost:7880 > /dev/null; then
        echo -e "${GREEN}✓ LiveKit server is responding${NC}\n"
    else
        echo -e "${YELLOW}⚠ LiveKit server is running but not responding yet${NC}\n"
    fi
else
    echo -e "${RED}✗ LiveKit server failed to start${NC}"
    echo -e "${YELLOW}Check logs with: docker-compose logs livekit-server${NC}"
    exit 1
fi

# Setup token server
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Step 2: Setting Up Token Server${NC}"
echo -e "${BLUE}========================================${NC}\n"

cd token-server

if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}Installing token server dependencies...${NC}"
    npm install --silent
    echo -e "${GREEN}✓ Token server dependencies installed${NC}\n"
else
    echo -e "${GREEN}✓ Token server dependencies already installed${NC}\n"
fi

# Start token server in background
echo -e "${YELLOW}Starting token server...${NC}"
npm start > ../token-server.log 2>&1 &
TOKEN_SERVER_PID=$!
echo $TOKEN_SERVER_PID > ../token-server.pid

# Wait for token server to be ready
sleep 3

# Check if token server is running
if kill -0 $TOKEN_SERVER_PID 2>/dev/null; then
    echo -e "${GREEN}✓ Token server is running (PID: $TOKEN_SERVER_PID)${NC}"

    # Test the token server
    if curl -s http://localhost:3001/health > /dev/null; then
        echo -e "${GREEN}✓ Token server is responding${NC}\n"
    else
        echo -e "${YELLOW}⚠ Token server is running but not responding yet${NC}\n"
    fi
else
    echo -e "${RED}✗ Token server failed to start${NC}"
    echo -e "${YELLOW}Check logs in token-server.log${NC}"
    exit 1
fi

cd ..

# Setup agent
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Step 3: Setting Up Voice Agent${NC}"
echo -e "${BLUE}========================================${NC}\n"

cd agent

# Create .env if it doesn't exist
if [ ! -f .env ]; then
    echo -e "${YELLOW}Creating agent/.env from .env.example...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✓ Created agent/.env${NC}\n"
else
    echo -e "${GREEN}✓ agent/.env already exists${NC}\n"
fi

# Check if OpenAI API key is set
OPENAI_KEY_SET=false
if grep -q "OPENAI_API_KEY=sk-" .env 2>/dev/null; then
    echo -e "${GREEN}✓ OpenAI API key is configured${NC}\n"
    OPENAI_KEY_SET=true
else
    echo -e "${YELLOW}⚠ OpenAI API key not configured${NC}"
    echo -e "${YELLOW}Please enter your OpenAI API key (or press Enter to skip):${NC}"
    read -r OPENAI_KEY

    if [ ! -z "$OPENAI_KEY" ]; then
        # Update the .env file with the API key
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i "" "s/OPENAI_API_KEY=.*/OPENAI_API_KEY=$OPENAI_KEY/" .env
        else
            sed -i "s/OPENAI_API_KEY=.*/OPENAI_API_KEY=$OPENAI_KEY/" .env
        fi
        echo -e "${GREEN}✓ OpenAI API key saved${NC}\n"
        OPENAI_KEY_SET=true
    else
        echo -e "${YELLOW}⚠ Skipped OpenAI API key setup${NC}"
        echo -e "${YELLOW}  You'll need to add it manually to agent/.env before starting the agent${NC}\n"
    fi
fi

# Setup Python virtual environment
if [ ! -d "venv" ]; then
    echo -e "${YELLOW}Creating Python virtual environment...${NC}"
    python3 -m venv venv
    echo -e "${GREEN}✓ Virtual environment created${NC}\n"
else
    echo -e "${GREEN}✓ Virtual environment already exists${NC}\n"
fi

# Activate virtual environment and install dependencies
echo -e "${YELLOW}Installing Python dependencies...${NC}"
source venv/bin/activate

# Upgrade pip first
pip install --upgrade pip --quiet

# Install requirements
if pip install -r requirements.txt --quiet; then
    echo -e "${GREEN}✓ Python dependencies installed${NC}\n"
else
    echo -e "${RED}✗ Failed to install Python dependencies${NC}"
    echo -e "${YELLOW}Try running manually:${NC}"
    echo -e "${YELLOW}  cd agent${NC}"
    echo -e "${YELLOW}  source venv/bin/activate${NC}"
    echo -e "${YELLOW}  pip install -r requirements.txt${NC}"
    deactivate
    cd ..
    exit 1
fi

# Start the agent if OpenAI key is set
if [ "$OPENAI_KEY_SET" = true ]; then
    echo -e "${YELLOW}Starting voice agent...${NC}"
    python agent.py start > ../agent.log 2>&1 &
    AGENT_PID=$!
    echo $AGENT_PID > ../agent.pid

    # Wait a bit for agent to start
    sleep 3

    # Check if agent is running
    if kill -0 $AGENT_PID 2>/dev/null; then
        echo -e "${GREEN}✓ Voice agent is running (PID: $AGENT_PID)${NC}\n"
    else
        echo -e "${RED}✗ Voice agent failed to start${NC}"
        echo -e "${YELLOW}Check logs in agent.log${NC}"
        echo -e "${YELLOW}Common issues:${NC}"
        echo -e "${YELLOW}  - Invalid OpenAI API key${NC}"
        echo -e "${YELLOW}  - Missing dependencies${NC}\n"
    fi
else
    echo -e "${YELLOW}⚠ Skipping agent startup (OpenAI API key not configured)${NC}\n"
fi

deactivate
cd ..

# Setup React Native app
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Step 4: Setting Up React Native App${NC}"
echo -e "${BLUE}========================================${NC}\n"

if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}Installing React Native dependencies...${NC}"
    echo -e "${YELLOW}This may take a few minutes...${NC}\n"
    npm install
    echo -e "${GREEN}✓ React Native dependencies installed${NC}\n"
else
    echo -e "${GREEN}✓ React Native dependencies already installed${NC}\n"
fi

# Final summary
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Setup Complete! 🎉${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${GREEN}Services Status:${NC}"
echo -e "  • LiveKit Server: ${GREEN}✓ Running${NC} (ws://localhost:7880)"
echo -e "  • Token Server: ${GREEN}✓ Running${NC} (http://localhost:3001)"

if [ "$OPENAI_KEY_SET" = true ]; then
    if [ -f agent.pid ] && kill -0 $(cat agent.pid) 2>/dev/null; then
        echo -e "  • Voice Agent: ${GREEN}✓ Running${NC}"
    else
        echo -e "  • Voice Agent: ${YELLOW}⚠ Check agent.log${NC}"
    fi
else
    echo -e "  • Voice Agent: ${YELLOW}⚠ Not started (needs OpenAI API key)${NC}"
fi

echo -e ""

# Ask if user wants to start the React Native app
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Step 5: Starting React Native App${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e ""

if [ "$OPENAI_KEY_SET" = false ]; then
    echo -e "${YELLOW}Note: Voice agent is not running. Add your OpenAI API key to agent/.env to enable it.${NC}"
    echo -e ""
fi

read -p "$(echo -e ${YELLOW}Would you like to start the React Native app now? [Y/n]: ${NC})" -n 1 -r START_APP
echo
START_APP=${START_APP:-Y}

if [[ $START_APP =~ ^[Yy]$ ]]; then
    echo -e ""
    echo -e "${BLUE}Choose platform:${NC}"
    echo -e "  ${YELLOW}1)${NC} iOS (Simulator)"
    echo -e "  ${YELLOW}2)${NC} iOS (Physical Device)"
    echo -e "  ${YELLOW}3)${NC} Android"
    echo -e "  ${YELLOW}4)${NC} Skip for now"
    echo -e ""
    read -p "$(echo -e ${YELLOW}Enter choice [1-4]: ${NC})" PLATFORM_CHOICE

    case $PLATFORM_CHOICE in
        1)
            echo -e "${BLUE}Starting iOS Simulator...${NC}"
            npx expo run:ios
            ;;
        2)
            echo -e "${BLUE}Starting on Physical Device...${NC}"
            echo -e "${YELLOW}Make sure your device is connected via USB${NC}"
            npx expo run:ios --device
            ;;
        3)
            echo -e "${BLUE}Starting Android...${NC}"
            npx expo run:android
            ;;
        4|*)
            echo -e "${YELLOW}Skipping app startup${NC}"
            ;;
    esac
fi

echo -e ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}All Services Running! 🎉${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e ""

if [[ ! $START_APP =~ ^[Yy]$ ]] || [[ $PLATFORM_CHOICE == "4" ]]; then
    echo -e "${GREEN}To start the app manually:${NC}"
    echo -e "  ${YELLOW}npx expo run:ios${NC}          # iOS Simulator"
    echo -e "  ${YELLOW}npx expo run:ios --device${NC} # Physical Device"
    echo -e "  ${YELLOW}npx expo run:android${NC}      # Android"
    echo -e ""
fi

if [ "$OPENAI_KEY_SET" = false ]; then
    echo -e "${YELLOW}To enable the voice agent:${NC}"
    echo -e "  ${YELLOW}1. Add your OpenAI API key to agent/.env${NC}"
    echo -e "  ${YELLOW}2. Start the agent:${NC}"
    echo -e "     ${YELLOW}cd agent && source venv/bin/activate && python agent.py start${NC}"
    echo -e ""
fi

echo -e "${GREEN}Useful Commands:${NC}"
echo -e "  • View LiveKit logs: ${YELLOW}docker-compose logs -f livekit-server${NC}"
echo -e "  • View token server logs: ${YELLOW}tail -f token-server.log${NC}"
if [ "$OPENAI_KEY_SET" = true ]; then
    echo -e "  • View agent logs: ${YELLOW}tail -f agent.log${NC}"
fi
echo -e "  • Stop all services: ${YELLOW}./stop.sh${NC}"
echo -e "  • Check service status: ${YELLOW}docker-compose ps${NC}"
echo -e ""
echo -e "${GREEN}Documentation:${NC}"
echo -e "  • Quick Start: ${YELLOW}QUICKSTART.md${NC}"
echo -e "  • Full Setup Guide: ${YELLOW}SETUP.md${NC}"
echo -e "  • Current Status: ${YELLOW}STATUS.md${NC}"
echo -e ""
echo -e "${GREEN}Happy coding! 🚀${NC}\n"

