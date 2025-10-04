const express = require('express');
const { AccessToken, RoomServiceClient } = require('livekit-server-sdk');
const cors = require('cors');
require('dotenv').config({ path: '../.env' });

const app = express();
const PORT = process.env.TOKEN_SERVER_PORT || 3001;

// Initialize RoomServiceClient for agent dispatch
const livekitHost = process.env.LIVEKIT_URL?.replace('ws://', 'http://').replace('wss://', 'https://');
const roomService = new RoomServiceClient(livekitHost, process.env.LIVEKIT_API_KEY, process.env.LIVEKIT_API_SECRET);

// Enable CORS for all origins (restrict in production)
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Token generation endpoint
app.post('/token', async (req, res) => {
  try {
    const { roomName, participantName } = req.body;
    
    // Validate input
    if (!roomName || !participantName) {
      return res.status(400).json({ 
        error: 'Missing required fields: roomName and participantName' 
      });
    }

    const apiKey = process.env.LIVEKIT_API_KEY;
    const apiSecret = process.env.LIVEKIT_API_SECRET;
    const livekitUrl = process.env.LIVEKIT_URL;

    if (!apiKey || !apiSecret || !livekitUrl) {
      console.error('Missing LiveKit configuration in environment variables');
      return res.status(500).json({ 
        error: 'Server configuration error' 
      });
    }

    // Create access token
    const at = new AccessToken(apiKey, apiSecret, {
      identity: participantName,
      ttl: '24h', // Token valid for 24 hours
    });

    // Grant permissions
    at.addGrant({
      roomJoin: true,
      room: roomName,
      canPublish: true,
      canSubscribe: true,
      canPublishData: true,
    });

    const token = await at.toJwt();

    console.log(`Generated token for ${participantName} in room ${roomName}`);

    // Dispatch an agent to the room
    try {
      await roomService.createRoom({
        name: roomName,
        emptyTimeout: 300, // Room stays alive for 5 minutes after last participant leaves
        maxParticipants: 10,
      });
      console.log(`Room ${roomName} created or already exists`);
    } catch (error) {
      // Room might already exist, which is fine
      console.log(`Room ${roomName} already exists or error creating:`, error.message);
    }

    res.json({
      url: livekitUrl,
      token: token,
      roomName: roomName,
      participantName: participantName,
    });
  } catch (error) {
    console.error('Error generating token:', error);
    res.status(500).json({
      error: 'Failed to generate token',
      message: error.message
    });
  }
});

// Get token with GET request (for simple testing)
app.get('/token', async (req, res) => {
  const roomName = req.query.room || 'default-room';
  const participantName = req.query.participant || `user-${Date.now()}`;
  
  // Reuse the POST logic
  req.body = { roomName, participantName };
  return app._router.handle(req, res);
});

app.listen(PORT, () => {
  console.log(`Token server running on http://localhost:${PORT}`);
  console.log(`LiveKit URL: ${process.env.LIVEKIT_URL}`);
  console.log(`API Key: ${process.env.LIVEKIT_API_KEY}`);
});

