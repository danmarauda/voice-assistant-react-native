import asyncio
import logging
import os
from dotenv import load_dotenv

from livekit.agents import AutoSubscribe, JobContext, WorkerOptions, cli, llm
from livekit.agents.voice import Agent
from livekit.plugins import openai, silero

# Load environment variables
load_dotenv()

logger = logging.getLogger("voice-assistant")
logger.setLevel(logging.INFO)


async def entrypoint(ctx: JobContext):
    """
    Main entry point for the voice assistant agent.
    This function is called when a participant joins a room.
    """
    logger.info(f"Connecting to room: {ctx.room.name}")

    # Connect to the room
    await ctx.connect(auto_subscribe=AutoSubscribe.AUDIO_ONLY)

    # Wait for the first participant to join
    participant = await ctx.wait_for_participant()
    logger.info(f"Starting voice assistant for participant: {participant.identity}")

    # Configure the assistant
    assistant = Agent(
        vad=silero.VAD.load(),  # Voice Activity Detection
        stt=openai.STT(),  # Speech-to-Text
        llm=openai.LLM(model="gpt-4o-mini"),  # Language Model
        tts=openai.TTS(voice="alloy"),  # Text-to-Speech
        chat_ctx=llm.ChatContext().append(
            role="system",
            text=(
                "You are a helpful voice assistant. Your interface with users will be voice. "
                "Keep your responses concise and conversational. "
                "Avoid using special characters or formatting in your responses."
            ),
        ),
    )

    # Start the assistant
    assistant.start(ctx.room, participant)

    # Send an initial greeting
    await assistant.say("Hello! I'm your voice assistant. How can I help you today?", allow_interruptions=True)

    logger.info("Voice assistant started successfully")


async def request_fnc(job_request):
    """
    Accept all job requests.
    This function is called when LiveKit wants to dispatch an agent to a room.
    """
    logger.info(f"Accepting job request for room: {job_request.room.name}")
    await job_request.accept()


if __name__ == "__main__":
    # Run the agent
    # The agent will automatically join any room that is created
    cli.run_app(
        WorkerOptions(
            entrypoint_fnc=entrypoint,
            request_fnc=request_fnc,
        ),
    )

