#!/usr/bin/env python3
import argparse
import json
import os
import sys


def main():
    parser = argparse.ArgumentParser(description="Voice cloning via DashScope CosyVoice")
    parser.add_argument("--wav", required=True, help="Path to voice material WAV file")
    parser.add_argument("--name", required=True, help="Character English name (used as prefix)")
    args = parser.parse_args()

    if not os.path.isfile(args.wav):
        print(f"Error: wav file not found: {args.wav}", file=sys.stderr)
        sys.exit(1)

    config_path = os.path.join(os.getcwd(), "sd_sysroot", "config.json")
    if not os.path.isfile(config_path):
        print(f"Error: config.json not found: {config_path}", file=sys.stderr)
        sys.exit(1)

    try:
        with open(config_path, "r", encoding="utf-8") as f:
            config = json.load(f)
    except Exception as e:
        print(f"Error reading config.json: {e}", file=sys.stderr)
        sys.exit(1)

    api_key = config.get("apikey", "")
    if not api_key:
        print("Error: apikey is empty or missing in config.json", file=sys.stderr)
        sys.exit(1)

    try:
        import dashscope
        from dashscope.audio.tts_v2 import VoiceEnrollmentService

        dashscope.api_key = api_key

        service = VoiceEnrollmentService()
        voice_id = service.create_voice(
            target_model="cosyvoice-v3.5-plus",
            prefix=args.name,
            url=args.wav,
        )

        print(voice_id)
    except Exception as e:
        print(f"Error: voice cloning failed: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
