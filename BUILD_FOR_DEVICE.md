# Building for Physical Device

## Current Configuration

✅ **Your iPhone is connected**: Dan's iPhone (26.0)  
✅ **Mac IP Address**: 192.168.1.30  
✅ **Services Running**:
- LiveKit Server: ws://192.168.1.30:7880
- Token Server: http://192.168.1.30:3001
- Voice Agent: Running

## Quick Build

Run this command to build and install on your iPhone:

```bash
npx expo run:ios --device
```

Expo will automatically detect your connected iPhone and build for it.

## Alternative: Specific Device

If you have multiple devices, specify your iPhone:

```bash
npx expo run:ios --device "Dan's iPhone"
```

## What Happens

1. Expo builds the native iOS app
2. Signs it with your Apple Developer account
3. Installs it on your iPhone
4. Launches the app

## First Time Setup

If this is your first time building for a device, you may need to:

1. **Trust your Mac on iPhone**:
   - When prompted on iPhone, tap "Trust"
   - Enter your iPhone passcode

2. **Trust the Developer**:
   - On iPhone: Settings > General > VPN & Device Management
   - Tap your Apple ID
   - Tap "Trust"

## Network Configuration

The app is configured to connect to:
- **Token Server**: http://192.168.1.30:3001
- **LiveKit Server**: ws://192.168.1.30:7880

Both your Mac and iPhone must be on the same WiFi network.

## Switching Between Device and Simulator

Use the helper script:

```bash
./configure-network.sh
```

Select:
- **Option 1**: Physical Device (uses your Mac's IP)
- **Option 2**: Simulator (uses localhost)

Then restart services:

```bash
./stop.sh
./start.sh
```

## Troubleshooting

### "No devices found"

Make sure:
- iPhone is connected via USB
- iPhone is unlocked
- You've trusted this computer on iPhone

Check connected devices:
```bash
xcrun xctrace list devices
```

### "Code signing error"

You need an Apple Developer account. Expo will guide you through:
1. Open Xcode
2. Go to Preferences > Accounts
3. Add your Apple ID
4. Expo will use it automatically

### "Cannot connect to server"

1. Check both devices are on same WiFi
2. Verify Mac IP hasn't changed:
   ```bash
   ifconfig | grep "inet " | grep -v 127.0.0.1
   ```
3. Update configuration if IP changed:
   ```bash
   ./configure-network.sh
   ```

### "Microphone not working"

1. Check iPhone Settings > Privacy > Microphone
2. Enable microphone for your app
3. Restart the app

## Testing

Once the app launches:

1. Tap "Start Voice Assistant"
2. You should hear: "Hello! I'm your voice assistant. How can I help you today?"
3. Start speaking!

## Logs

View logs in real-time:

```bash
# LiveKit server
docker-compose logs -f livekit-server

# Token server
tail -f token-server.log

# Voice agent
tail -f agent.log
```

## Performance Tips

For better performance on device:

1. **Use WiFi 5GHz** if available (faster than 2.4GHz)
2. **Keep devices close** to WiFi router
3. **Close other apps** on iPhone
4. **Disable Low Power Mode** on iPhone

## Next Steps

After successful build:

1. Test voice interaction
2. Try different commands
3. Customize agent personality in `agent/agent.py`
4. Modify UI in `app/assistant/`

## Production Deployment

For production:

1. Deploy LiveKit server to cloud
2. Use proper SSL/TLS certificates
3. Implement secure token generation
4. Submit app to App Store

See [SETUP.md](SETUP.md) for production deployment guide.

