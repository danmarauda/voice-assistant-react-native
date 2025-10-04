# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- Interactive React Native app startup in `start.sh` script
  - Prompts user to start the app after services are running
  - Supports iOS Simulator, iOS Physical Device, and Android
  - Option to skip and start manually later

## [1.0.0] - 2025-10-05

### Added
- Complete LiveKit voice assistant infrastructure
- Docker Compose setup for LiveKit server
- Node.js token server for JWT authentication (Express on port 3001)
- Python voice agent using OpenAI GPT-4, Whisper STT, and TTS
- Automated start/stop scripts with health checks
- Network configuration helper for device/simulator switching
- Comprehensive documentation (8 markdown guides)
- Environment variable management
- Proper .gitignore for secrets and logs

### Features
- Voice Activity Detection (Silero VAD)
- OpenAI integration (GPT-4o-mini, Whisper, TTS)
- Proper error handling and logging
- Docker containerization support
- PID tracking and log management
- Health checks for all services

### Documentation
- START_HERE.md: Quick start guide
- GET_STARTED.md: Comprehensive setup instructions
- QUICKSTART.md: 5-minute setup guide
- SETUP.md: Detailed configuration guide
- PROJECT_STRUCTURE.md: Architecture overview
- STATUS.md: Current status and quick reference
- BUILD_FOR_DEVICE.md: Physical device deployment guide
- README_AUTOMATED_SETUP.md: Automation documentation

### Tested
- iOS device build and deployment
- LiveKit server connectivity
- Token generation and authentication
- Voice agent integration
- Metro bundler and React Native app

