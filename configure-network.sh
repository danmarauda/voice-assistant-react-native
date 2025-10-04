#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Network Configuration Helper${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Get current IP
CURRENT_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | head -1 | awk '{print $2}')

echo -e "${GREEN}Current Mac IP Address: ${YELLOW}$CURRENT_IP${NC}\n"

echo -e "Select configuration:"
echo -e "  ${YELLOW}1${NC} - Physical Device (use IP: $CURRENT_IP)"
echo -e "  ${YELLOW}2${NC} - Simulator (use localhost)"
echo -e ""
read -p "Enter choice (1 or 2): " choice

case $choice in
    1)
        echo -e "\n${YELLOW}Configuring for physical device...${NC}\n"
        
        # Update .env
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i "" "s|LIVEKIT_URL=ws://.*:7880|LIVEKIT_URL=ws://$CURRENT_IP:7880|g" .env
        else
            sed -i "s|LIVEKIT_URL=ws://.*:7880|LIVEKIT_URL=ws://$CURRENT_IP:7880|g" .env
        fi
        
        # Update hooks/useConnectionDetails.ts
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i "" "s|const localTokenServerUrl = 'http://.*:3001/token';|const localTokenServerUrl = 'http://$CURRENT_IP:3001/token';|g" hooks/useConnectionDetails.ts
        else
            sed -i "s|const localTokenServerUrl = 'http://.*:3001/token';|const localTokenServerUrl = 'http://$CURRENT_IP:3001/token';|g" hooks/useConnectionDetails.ts
        fi
        
        echo -e "${GREEN}✓ Configured for physical device${NC}"
        echo -e "${GREEN}  LiveKit URL: ${YELLOW}ws://$CURRENT_IP:7880${NC}"
        echo -e "${GREEN}  Token Server: ${YELLOW}http://$CURRENT_IP:3001${NC}\n"
        ;;
    2)
        echo -e "\n${YELLOW}Configuring for simulator...${NC}\n"
        
        # Update .env
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i "" "s|LIVEKIT_URL=ws://.*:7880|LIVEKIT_URL=ws://localhost:7880|g" .env
        else
            sed -i "s|LIVEKIT_URL=ws://.*:7880|LIVEKIT_URL=ws://localhost:7880|g" .env
        fi
        
        # Update hooks/useConnectionDetails.ts
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i "" "s|const localTokenServerUrl = 'http://.*:3001/token';|const localTokenServerUrl = 'http://localhost:3001/token';|g" hooks/useConnectionDetails.ts
        else
            sed -i "s|const localTokenServerUrl = 'http://.*:3001/token';|const localTokenServerUrl = 'http://localhost:3001/token';|g" hooks/useConnectionDetails.ts
        fi
        
        echo -e "${GREEN}✓ Configured for simulator${NC}"
        echo -e "${GREEN}  LiveKit URL: ${YELLOW}ws://localhost:7880${NC}"
        echo -e "${GREEN}  Token Server: ${YELLOW}http://localhost:3001${NC}\n"
        ;;
    *)
        echo -e "\n${YELLOW}Invalid choice. No changes made.${NC}\n"
        exit 1
        ;;
esac

echo -e "${YELLOW}Restart services for changes to take effect:${NC}"
echo -e "  ${YELLOW}./stop.sh${NC}"
echo -e "  ${YELLOW}./start.sh${NC}\n"

