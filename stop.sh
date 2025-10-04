#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Stopping LiveKit Voice Assistant${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Stop voice agent
if [ -f agent.pid ]; then
    AGENT_PID=$(cat agent.pid)
    if kill -0 $AGENT_PID 2>/dev/null; then
        echo -e "${YELLOW}Stopping voice agent (PID: $AGENT_PID)...${NC}"
        kill $AGENT_PID
        # Wait a bit for graceful shutdown
        sleep 2
        # Force kill if still running
        if kill -0 $AGENT_PID 2>/dev/null; then
            kill -9 $AGENT_PID 2>/dev/null
        fi
        rm agent.pid
        echo -e "${GREEN}✓ Voice agent stopped${NC}"
    else
        echo -e "${YELLOW}Voice agent is not running${NC}"
        rm agent.pid
    fi
else
    echo -e "${YELLOW}No voice agent PID file found${NC}"
fi

# Stop token server
if [ -f token-server.pid ]; then
    TOKEN_SERVER_PID=$(cat token-server.pid)
    if kill -0 $TOKEN_SERVER_PID 2>/dev/null; then
        echo -e "${YELLOW}Stopping token server (PID: $TOKEN_SERVER_PID)...${NC}"
        kill $TOKEN_SERVER_PID
        # Wait a bit for graceful shutdown
        sleep 2
        # Force kill if still running
        if kill -0 $TOKEN_SERVER_PID 2>/dev/null; then
            kill -9 $TOKEN_SERVER_PID 2>/dev/null
        fi
        rm token-server.pid
        echo -e "${GREEN}✓ Token server stopped${NC}"
    else
        echo -e "${YELLOW}Token server is not running${NC}"
        rm token-server.pid
    fi
else
    echo -e "${YELLOW}No token server PID file found${NC}"
fi

# Stop LiveKit server
echo -e "${YELLOW}Stopping LiveKit server...${NC}"
docker-compose down

echo -e "${GREEN}✓ LiveKit server stopped${NC}\n"

# Clean up log files
if [ -f token-server.log ]; then
    rm token-server.log
    echo -e "${GREEN}✓ Cleaned up token server logs${NC}"
fi

if [ -f agent.log ]; then
    rm agent.log
    echo -e "${GREEN}✓ Cleaned up agent logs${NC}"
fi

echo -e ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}All services stopped successfully! ✓${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${YELLOW}To start services again, run:${NC}"
echo -e "  ${YELLOW}./start.sh${NC}\n"

