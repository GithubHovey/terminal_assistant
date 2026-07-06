#!/usr/bin/env python3
"""
Terminal image converter wrapper.
Converts PNG images to LVGL .bin format (RGB565A8) for three predefined image types:
  - avatar: 60x60   (role avatar)
  - chatbg: 280x171 (chat background)
  - cover:  160x160 (radio music cover)
"""
import argparse
import sys
import os
import logging

try:
    from PIL import Image
except ImportError:
    raise ImportError("Need Pillow package, do `pip install Pillow`")

from LVGLImage import LVGLImage, ColorFormat, CompressMethod

IMAGE_TYPES = {
    "avatar": (60, 60),
    "chatbg": (280, 171),
    "cover":  (160, 160),
}


def convert(input_path, output_path, image_type):
    if image_type not in IMAGE_TYPES:
        print(f"Error: unknown type '{image_type}'. Use: {', '.join(IMAGE_TYPES.keys())}")
        return False

    target_w, target_h = IMAGE_TYPES[image_type]

    if not os.path.isfile(input_path):
        print(f"Error: input file not found: {input_path}")
        return False

    try:
        img = Image.open(input_path)
        if img.size != (target_w, target_h):
            print(f"Error: image size {img.size[0]}x{img.size[1]} does not match required {target_w}x{target_h} for type '{image_type}'")
            return False
    except Exception as e:
        print(f"Error processing image: {e}")
        return False

    try:
        lvgl_img = LVGLImage().from_png(input_path, cf=ColorFormat.RGB565A8)
        lvgl_img.to_bin(output_path, compress=CompressMethod.NONE)
        print(f"OK: {output_path} ({target_w}x{target_h}, RGB565A8, {os.path.getsize(output_path)} bytes)")
        return True
    except Exception as e:
        print(f"Error converting: {e}")
        return False


def main():
    parser = argparse.ArgumentParser(description="Terminal image converter (PNG -> LVGL BIN)")
    parser.add_argument("--type", required=True, choices=IMAGE_TYPES.keys(),
                        help="Image type: avatar(60x60), chatbg(280x171), cover(160x160)")
    parser.add_argument("--input", required=True, help="Input PNG file path")
    parser.add_argument("--output", required=True, help="Output BIN file path")
    parser.add_argument("-v", "--verbose", action="store_true")

    args = parser.parse_args()

    if args.verbose:
        logging.basicConfig(level=logging.INFO)

    success = convert(args.input, args.output, args.type)
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
