import { useEffect, useState } from 'react';

// TODO: Add your Sandbox ID here (if using LiveKit Cloud)
const sandboxID = '';
const sandboxTokenEndpoint =
  'https://cloud-api.livekit.io/api/sandbox/connection-details';

// Local token server configuration (for development)
const useLocalTokenServer = true; // Set to false to use sandbox or hardcoded values
// Use your Mac's IP address for physical devices, localhost for simulator
const localTokenServerUrl = 'http://192.168.1.30:3001/token';
const defaultRoomName = 'voice-assistant-room';

// For use without a token server (not recommended)
const hardcodedUrl = '';
const hardcodedToken = '';

/**
 * Retrieves a LiveKit token.
 *
 * Priority order:
 * 1. Local token server (if useLocalTokenServer is true)
 * 2. LiveKit Cloud Sandbox (if sandboxID is provided)
 * 3. Hardcoded values (for testing only)
 */
export function useConnectionDetails(): ConnectionDetails | undefined {
  const [details, setDetails] = useState<ConnectionDetails | undefined>(() => {
    return undefined;
  });

  useEffect(() => {
    fetchToken().then(details => {
      setDetails(details);
    });
  }, []);

  return details;
}

export async function fetchToken() : Promise<ConnectionDetails | undefined> {
    // Option 1: Use local token server
    if (useLocalTokenServer) {
      try {
        const participantName = `user-${Math.random().toString(36).substring(7)}`;
        const response = await fetch(localTokenServerUrl, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            roomName: defaultRoomName,
            participantName: participantName,
          }),
        });

        if (!response.ok) {
          console.error('Failed to fetch token from local server:', response.statusText);
          return undefined;
        }

        const json = await response.json();

        if (json.url && json.token) {
          console.log('Successfully fetched token from local server');
          return {
            url: json.url,
            token: json.token,
          };
        }
      } catch (error) {
        console.error('Error fetching token from local server:', error);
        console.log('Make sure the token server is running: cd token-server && npm start');
        return undefined;
      }
    }

    // Option 2: Use LiveKit Cloud Sandbox
    if (sandboxID) {
      try {
        const response = await fetch(sandboxTokenEndpoint, {
          headers: { 'X-Sandbox-ID': sandboxID },
        });
        const json = await response.json();

        if (json.serverUrl && json.participantToken) {
          return {
            url: json.serverUrl,
            token: json.participantToken,
          };
        }
      } catch (error) {
        console.error('Error fetching token from sandbox:', error);
        return undefined;
      }
    }

    // Option 3: Use hardcoded values (not recommended)
    if (hardcodedUrl && hardcodedToken) {
      return {
        url: hardcodedUrl,
        token: hardcodedToken,
      };
    }

    console.error('No token source configured. Please set up a token server or sandbox ID.');
    return undefined;
}

export type ConnectionDetails = {
  url: string;
  token: string;
};
