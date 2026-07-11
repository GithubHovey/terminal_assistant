#!/usr/bin/env python3
"""
esptool wrapper for DeepSpaceAssistant
Calls esptool.main() with command line arguments
"""
import sys
import esptool

if __name__ == '__main__':
    sys.exit(esptool.main())
