#!/usr/bin/env python3
import argparse
import json
import os
import sys


def load_api_key():
    config_path = os.path.join(os.getcwd(), "config.json")
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

    return api_key


def cmd_clone(args):
    if not os.path.isfile(args.wav):
        print(f"Error: wav file not found: {args.wav}", file=sys.stderr)
        sys.exit(1)

    api_key = load_api_key()

    try:
        import dashscope
        from dashscope import Files
        from dashscope.audio.tts_v2 import VoiceEnrollmentService

        dashscope.api_key = api_key

        # Step 1: Upload local file to DashScope
        print("Uploading audio file to DashScope...", file=sys.stderr)
        upload_response = Files.upload(file_path=args.wav, purpose='assistants')
        
        if upload_response.status_code != 200:
            print(f"Error: upload failed with status {upload_response.status_code}", file=sys.stderr)
            if upload_response.message:
                print(f"Error message: {upload_response.message}", file=sys.stderr)
            sys.exit(1)
        
        # Extract file_id from response
        uploaded_files = upload_response.output.get('uploaded_files', [])
        if not uploaded_files:
            print("Error: no files were uploaded", file=sys.stderr)
            sys.exit(1)
        
        file_id = uploaded_files[0].get('file_id')
        if not file_id:
            print("Error: file_id not found in upload response", file=sys.stderr)
            sys.exit(1)
        
        print(f"File uploaded successfully, file_id: {file_id}", file=sys.stderr)
        
        # Step 2: Get file URL
        print("Getting file URL...", file=sys.stderr)
        get_response = Files.get(file_id)
        
        if get_response.status_code != 200:
            print(f"Error: get file info failed with status {get_response.status_code}", file=sys.stderr)
            if get_response.message:
                print(f"Error message: {get_response.message}", file=sys.stderr)
            sys.exit(1)
        
        file_url = get_response.output.get('url')
        if not file_url:
            print("Error: url not found in file info response", file=sys.stderr)
            sys.exit(1)
        
        print(f"File URL obtained: {file_url[:80]}...", file=sys.stderr)
        
        # Step 3: Create voice using the URL
        print("Creating voice...", file=sys.stderr)
        service = VoiceEnrollmentService()
        voice_id = service.create_voice(
            target_model="cosyvoice-v3.5-plus",
            prefix=args.name,
            url=file_url,
        )

        print(voice_id)
    except Exception as e:
        print(f"Error: voice cloning failed: {e}", file=sys.stderr)
        sys.exit(1)


def cmd_list(args):
    api_key = load_api_key()

    try:
        import dashscope
        from dashscope.audio.tts_v2 import VoiceEnrollmentService

        dashscope.api_key = api_key

        service = VoiceEnrollmentService()
        prefix = args.prefix if args.prefix else None
        voices = service.list_voices(prefix=prefix, page_index=0, page_size=100)

        voice_list = []
        if voices and hasattr(voices, 'voices'):
            voice_list = voices.voices
        elif isinstance(voices, list):
            voice_list = voices

        result = []
        for v in voice_list:
            if isinstance(v, dict):
                item = {
                    "voice_id": v.get("voice_id", ""),
                    "target_model": v.get("target_model", ""),
                    "gmt_create": v.get("gmt_create", ""),
                    "status": v.get("status", ""),
                }
            else:
                item = {
                    "voice_id": getattr(v, 'voice_id', str(v)),
                    "target_model": getattr(v, 'target_model', ''),
                    "gmt_create": getattr(v, 'gmt_create', ''),
                    "status": getattr(v, 'status', ''),
                }
            result.append(item)

        print(json.dumps(result, ensure_ascii=False))
    except Exception as e:
        print(f"Error: list voices failed: {e}", file=sys.stderr)
        sys.exit(1)


def cmd_delete(args):
    if not args.voice_id:
        print("Error: voice_id is empty", file=sys.stderr)
        sys.exit(1)

    api_key = load_api_key()

    try:
        import dashscope
        from dashscope.audio.tts_v2 import VoiceEnrollmentService

        dashscope.api_key = api_key

        service = VoiceEnrollmentService()
        service.delete_voice(voice_id=args.voice_id)

        print(args.voice_id)
    except Exception as e:
        print(f"Error: delete voice failed: {e}", file=sys.stderr)
        sys.exit(1)


def cmd_synthesize(args):
    if not args.text:
        print("Error: text is empty", file=sys.stderr)
        sys.exit(1)

    api_key = load_api_key()

    try:
        import dashscope
        from dashscope.audio.tts_v2 import SpeechSynthesizer

        dashscope.api_key = api_key

        synthesizer = SpeechSynthesizer(model="cosyvoice-v3.5-plus", voice=args.voice)
        audio = synthesizer.call(args.text)

        if audio is None:
            print("Error: speech synthesis returned None", file=sys.stderr)
            sys.exit(1)

        with open(args.output, "wb") as f:
            f.write(audio)

        print(args.output)
    except Exception as e:
        print(f"Error: speech synthesis failed: {e}", file=sys.stderr)
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(description="Voice tools via DashScope CosyVoice")
    subparsers = parser.add_subparsers(dest="command", required=True)

    clone_parser = subparsers.add_parser("clone", help="Voice cloning")
    clone_parser.add_argument("--wav", required=True, help="Path to voice material WAV file")
    clone_parser.add_argument("--name", required=True, help="Character English name (used as prefix)")

    list_parser = subparsers.add_parser("list", help="List cloned voices")
    list_parser.add_argument("--prefix", default=None, help="Filter by prefix, or omit to query all")

    delete_parser = subparsers.add_parser("delete", help="Delete a cloned voice")
    delete_parser.add_argument("--voice-id", required=True, help="Voice ID to delete")

    synthesize_parser = subparsers.add_parser("synthesize", help="Speech synthesis")
    synthesize_parser.add_argument("--voice", required=True, help="Voice ID from cloning")
    synthesize_parser.add_argument("--text", required=True, help="Text to synthesize")
    synthesize_parser.add_argument("--output", required=True, help="Output audio file path")

    args = parser.parse_args()

    if args.command == "clone":
        cmd_clone(args)
    elif args.command == "list":
        cmd_list(args)
    elif args.command == "delete":
        cmd_delete(args)
    elif args.command == "synthesize":
        cmd_synthesize(args)


if __name__ == "__main__":
    main()
