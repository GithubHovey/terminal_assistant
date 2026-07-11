---
name: esptool
description: Use when flashing ESP chips, reading/writing flash, erasing firmware, converting ELF to binary, merging binaries, or any ESP32/ESP8266/ESP32-S/C series serial programming task. Also use when the user mentions esptool, write-flash, read-flash, erase-flash, elf2image, merge-bin, flash-id, or needs to interact with Espressif SoCs via serial/UART. Trigger this skill whenever firmware flashing, chip detection, flash memory operations, or bootloader interactions with any ESP chip are involved.
---

# esptool

esptool is the official Espressif command-line tool for serial communication with ESP8266, ESP32, ESP32-S2, ESP32-S3, ESP32-C3, ESP32-C6, ESP32-H2 and other Espressif SoCs. It handles firmware flashing, flash read/write/erase, chip detection, binary image conversion, and more.

## Installation

```bash
pip install esptool
```

Requires Python 3.10+. Can also run as `python -m esptool`.

## Command Structure

```
esptool [global options] <command> [command options]
```

Global options (chip, port, baud) come BEFORE the command. Command-specific options come AFTER.

## Basic Global Options

| Option | Short | Description | Default |
|--------|-------|-------------|---------|
| `--chip CHIP` | `-c` | Target chip (esp32, esp32s2, esp32s3, esp32c3, etc.) | Auto-detect |
| `--port PORT` | `-p` | Serial port (COM1 on Windows, /dev/ttyUSB0 on Linux) | Auto-detect |
| `--baud BAUD` | `-b` | Baud rate | 115200 |

Environment variables: `ESPTOOL_CHIP`, `ESPTOOL_PORT`, `ESPTOOL_BAUD`

## Core Commands

### write-flash - Flash firmware to chip

The most common command. Writes binary files to flash at specified offsets.

```bash
# Single file
esptool --chip esp32 --port COM3 write-flash 0x1000 app.bin

# Multiple files (typical ESP-IDF project)
esptool --chip esp32 -p COM3 -b 460800 write-flash \
  --flash-mode dio --flash-size 4MB \
  0x1000 bootloader.bin \
  0x8000 partition-table.bin \
  0x10000 app.bin

# Skip unchanged content (faster re-flashing)
esptool write-flash 0x10000 app.bin --skip-flashed

# Fast differential reflash (only changed sectors)
esptool write-flash 0x10000 new_app.bin --diff-with old_app.bin

# Erase all before writing
esptool write-flash -e 0x0 image.bin
```

Key options:
- `--flash-mode {keep,qio,qout,dio,dout}` - SPI flash mode
- `--flash-size {keep,detect,1MB,2MB,4MB,8MB,16MB}` - Flash size
- `--flash-freq {keep,40m,26m,20m,80m}` - Flash frequency
- `-e / --erase-all` - Erase entire flash before writing
- `--skip-flashed` / `-s` - Skip if MD5 matches
- `--diff-with OLD_FILE` - Fast differential flashing
- `--trust-flash-content` - Skip MD5 verification for unchanged files
- `-u / --no-compress` - Disable compression

### read-flash - Read flash contents

```bash
# Read 2MB from offset 0
esptool -p COM3 -b 460800 read-flash 0 0x200000 flash_contents.bin

# Auto-detect flash size
esptool -p COM3 read-flash 0 ALL flash_contents.bin
```

### erase-flash / erase-region - Erase flash

```bash
# Erase entire flash
esptool erase-flash

# Erase a region (address + size, must be 4KB aligned)
esptool erase-region 0x20000 16k
```

### flash-id - Read flash chip info

```bash
esptool flash-id
# Output: Manufacturer, Device ID, Detected flash size
```

### read-mac - Read chip MAC address

```bash
esptool read-mac
```

### elf2image - Convert ELF to flashable binary (no serial needed)

```bash
esptool --chip esp32 elf2image my_app.elf
# Output: my_app.bin
```

Options: `--flash-freq`, `--flash-mode`, `--flash-size`, `--use-segments`

### image-info - Inspect binary image

```bash
esptool image-info my_app.bin
```

### merge-bin - Merge multiple binaries

```bash
esptool --chip esp32 merge-bin -o merged.bin \
  --flash-mode dio --flash-size 4MB \
  0x1000 bootloader.bin \
  0x8000 partition-table.bin \
  0x10000 app.bin

# Output as Intel HEX (no padding between sections)
esptool --chip esp32 merge-bin --format hex -o merged.hex ...

# Output as UF2 (for USB drag-and-drop flashing)
esptool --chip esp32 merge-bin --format uf2 -o merged.uf2 ...
```

Use `@flash_args` file to read arguments from a file (ESP-IDF generates this in build/).

## Advanced Global Options

| Option | Description |
|--------|-------------|
| `--before {default-reset,no-reset,no-reset-no-sync}` | Reset behavior before operation |
| `--after {hard-reset,no-reset,no-reset-stub}` | Reset behavior after operation |
| `--no-stub` | Skip stub loader (uses ROM bootloader only, fewer features) |
| `--spi-connection {SPI,HSPI,CLK,Q,D,HD,CS}` | Override SPI flash pins (ESP32 only) |
| `--port-filter vid=0x303A` | Filter serial ports by VID/PID/name/serial |
| `--verbose` / `-v` | Verbose output |
| `--silent` / `-s` | Errors only |

## Advanced Commands

| Command | Description |
|---------|-------------|
| `verify-flash --diff ADDR FILE` | Verify flash matches local file (byte-by-byte with --diff) |
| `dump-mem ADDR SIZE FILE` | Dump memory region to file |
| `load-ram FILE` | Load binary to RAM and execute |
| `read-mem ADDR` | Read 4 bytes from RAM address |
| `write-mem ADDR VALUE` | Write 4 bytes to RAM address |
| `read-flash-status --bytes N` | Read flash chip status register |
| `write-flash-status --bytes N VALUE` | Write flash chip status register |
| `read-flash-sfdp ADDR BYTES` | Read Serial Flash Discoverable Parameters |

## Typical ESP-IDF Flash Workflow

```bash
# 1. Build project (from ESP-IDF project directory)
idf.py build

# 2. Flash using the generated command or manually:
python -m esptool --chip esp32 -b 460800 \
  --before default-reset --after hard-reset \
  write-flash --flash-mode dio --flash-size 4MB --flash-freq 40m \
  0x1000 build/bootloader/bootloader.bin \
  0x8000 build/partition_table/partition-table.bin \
  0x10000 build/my_app.bin

# Or use the @flash_args shortcut from build directory:
cd build
python -m esptool --chip esp32 -b 460800 write-flash "@flash_args"
```

## Flash Modes Reference

- **qio** (Quad I/O) - Fastest, uses 4 data pins. Most ESP32 modules.
- **qout** (Quad Output) - Uses 4 pins for output only.
- **dio** (Dual I/O) - Uses 2 data pins. Compatible with more boards.
- **dout** (Dual Output) - Uses 2 pins for output only. Most compatible.

Flash frequency: 40m is standard, 80m for performance (if hardware supports it).

## Serial Connection

ESP chip UART wiring (3.3V only!):
- ESP TX -> Adapter RX
- ESP RX -> Adapter TX
- ESP GND -> Adapter GND

Settings: 115200 baud, 8N1, no flow control.

## Entering Bootloader

Most dev boards (NodeMCU, WeMOS, ESP32-WROVER-KIT) auto-reset into bootloader. For manual entry:
1. Hold BOOT button (GPIO0 low)
2. Press and release RESET (EN) button
3. Release BOOT button

## Configuration File

Create `esptool.cfg` in the working directory or `~/.config/esptool/`:

```ini
[esptool]
timeout = 3
chip_erase_timeout = 120
connect_attempts = 7
reset_delay = 0.05
custom_reset_sequence = D0|R1|W0.1|D1|R0|W0.05|D0
```

## Python API

esptool can be used as a Python module:

```python
from esptool.cmds import detect_chip, attach_flash, run_stub, write_flash, reset_chip

with detect_chip("/dev/ttyACM0") as esp:
    esp = run_stub(esp)
    attach_flash(esp)
    with open("firmware.bin", "rb") as f:
        write_flash(esp, [(0x10000, f)])
    reset_chip(esp, "hard-reset")
```

Or pass CLI arguments directly:

```python
import esptool
esptool.main(['--chip', 'esp32', 'write-flash', '0x1000', 'app.bin'])
```

For detailed command reference, see `references/commands.md`.
