# esptool Detailed Command Reference

## Table of Contents
- [Complete Command List](#complete-command-list)
- [write-flash Deep Dive](#write-flash-deep-dive)
- [Fast Reflashing](#fast-reflashing)
- [merge-bin Formats](#merge-bin-formats)
- [Python API Reference](#python-api-reference)
- [Troubleshooting](#troubleshooting)
- [ESP-IDF Flash Offsets](#esp-idf-flash-offsets)

## Complete Command List

### Basic Commands
| Command | Serial Required | Description |
|---------|:-:|-------------|
| `write-flash` | Yes | Write binary data to flash |
| `read-flash` | Yes | Read flash contents to file |
| `erase-flash` | Yes | Erase entire flash chip |
| `erase-region` | Yes | Erase a specific flash region |
| `read-mac` | Yes | Read chip MAC address |
| `flash-id` | Yes | Read SPI flash manufacturer/device ID |
| `elf2image` | No | Convert ELF to flashable binary |
| `image-info` | No | Display binary image information |
| `merge-bin` | No | Merge multiple binaries into one |

### Advanced Commands
| Command | Serial Required | Description |
|---------|:-:|-------------|
| `verify-flash` | Yes | Verify flash data against local file |
| `dump-mem` | Yes | Dump memory region to file |
| `load-ram` | Yes | Load binary to RAM and execute |
| `read-mem` | Yes | Read single word (4 bytes) from RAM |
| `write-mem` | Yes | Write single word (4 bytes) to RAM |
| `read-flash-status` | Yes | Read flash chip status register |
| `write-flash-status` | Yes | Write flash chip status register |
| `read-flash-sfdp` | Yes | Read Serial Flash Discoverable Parameters |

## write-flash Deep Dive

### Address and File Pairs

Arguments are pairs of (offset, filename). Offsets can be hex or decimal:

```bash
# Hex offset
esptool write-flash 0x1000 app.bin

# Decimal offset
esptool write-flash 4096 app.bin

# Multiple files
esptool write-flash 0x0 bootloader.bin 0x8000 partitions.bin 0x10000 app.bin
```

### Flash Mode and Size

These options only affect bootable images at bootloader offsets (0x0 for ESP8266, 0x1000 for ESP32):

```bash
esptool write-flash \
  --flash-mode dio \
  --flash-size 4MB \
  --flash-freq 40m \
  0x1000 bootloader.bin 0x10000 app.bin
```

### Compression

Data is compressed by default during transfer. Disable with:
```bash
esptool write-flash -u 0x10000 app.bin
```

### Erase Before Write

```bash
# Erase all flash sectors before writing
esptool write-flash -e 0x10000 app.bin
```

### Sector Alignment

Flash is organized in 4096-byte sectors. When offset or data size is not 4KB-aligned, extra sectors are erased. esptool shows which sectors will be affected.

## Fast Reflashing

Speed up development iteration by only writing changed sectors:

```bash
# Compare new binary with previously flashed binary
esptool write-flash 0x10000 new_app.bin --diff-with old_app.bin

# Multiple files with selective diff
esptool write-flash \
  0x1000 bootloader.bin \
  0x10000 app.bin \
  0x20000 assets.bin \
  --diff-with old_boot.bin skip old_assets.bin

# Skip MD5 verification for unchanged files (fastest)
esptool write-flash 0x10000 new_app.bin \
  --diff-with old_app.bin --trust-flash-content
```

How it works:
1. Compares new binary with old binary sector-by-sector (4KB sectors)
2. Only writes changed sectors
3. Post-flash MD5 verification; auto-reflash whole file if verification fails
4. If no sectors changed, checks if new binary is already in flash

Limitations: Not available with `--erase-all`, `--encrypt`, or Secure Download Mode.

## merge-bin Formats

### RAW (default)
- Gaps padded with 0xFF
- Simple binary concatenation
- Use `--pad-to-size 4MB` to pad to full flash size
- Use `--target-offset 0x1000` to create binary for flashing at offset

### HEX (Intel HEX)
- No padding between sections
- ASCII text format (easier to transfer)
- Per-line checksums
- Automatically split back into sections when used with write-flash or image-info

### UF2 (USB Flashing Format)
- For drag-and-drop flashing via ESP USB Bridge
- Gaps filled with 0x00
- Options: `--chunk-size`, `--md5-disable`

## Python API Reference

### Chip Control

```python
from esptool.cmds import (
    detect_chip,    # Auto-detect and connect to ESP chip
    run_stub,       # Upload stub flasher for faster operations
    reset_chip,     # Reset the chip
    attach_flash,   # Attach flash memory (required for flash ops)
)

# Auto-detect chip
with detect_chip("/dev/ttyACM0", baud=115200) as esp:
    esp = run_stub(esp)
    attach_flash(esp)
    # ... operations ...
    reset_chip(esp, "hard-reset")

# Direct instantiation (when chip is known)
from esptool.targets import ESP32ROM
with ESP32ROM("/dev/ttyACM0") as esp:
    esp.connect()
    # ... operations ...
```

### Flash Operations

```python
from esptool.cmds import write_flash, read_flash, erase_flash, erase_region, verify_flash, flash_id

# Write flash
with open("firmware.bin", "rb") as f:
    write_flash(esp, [(0x10000, f)], flash_mode="dio", flash_size="4MB")

# Read flash
data = read_flash(esp, 0x0, 0x200000)  # Returns bytes
read_flash(esp, 0x0, 0x200000, "output.bin")  # Writes to file

# Erase
erase_flash(esp)
erase_region(esp, 0x20000, 0x4000)

# Verify
with open("firmware.bin", "rb") as f:
    verify_flash(esp, [(0x10000, f)], diff=True)

# Flash ID
flash_id(esp)
```

### Image Manipulation (No Serial Required)

```python
from esptool.cmds import elf2image, merge_bin, image_info

# ELF to binary
bin_data = elf2image("firmware.elf", "esp32")  # Returns bytes
elf2image("firmware.elf", "esp32", "output.bin")  # Writes to file

# Merge binaries
with open("boot.bin", "rb") as bl, open("app.bin", "rb") as app:
    merged = merge_bin([(0x1000, bl), (0x10000, app)], "esp32")
merge_bin([(0x1000, "boot.bin"), (0x10000, "app.bin")], "esp32", "merged.bin")

# Image info
image_info("firmware.bin")
```

### Memory Operations

```python
from esptool.cmds import read_mem, write_mem, dump_mem, load_ram

read_mem(esp, 0x400C0000)
write_mem(esp, 0x400C0000, 0xabad1dea)
dump_mem(esp, 0x40000000, 64*1024, "iram0.bin")
load_ram(esp, "helloworld.bin")
```

### Custom Logger

```python
from esptool.logger import log, TemplateLogger

class MyLogger(TemplateLogger):
    def print(self, message="", *args, **kwargs):
        print(f"[LOG] {message}")
    def note(self, message):
        self.print(f"NOTE: {message}")
    def warning(self, message):
        self.print(f"WARN: {message}")
    def error(self, message):
        self.print(f"ERR: {message}")
    def stage(self, finish=False):
        pass
    def progress_bar(self, cur_iter, total_iters, prefix="", suffix="", bar_length=30):
        pct = 100 * cur_iter / total_iters
        self.print(f"Progress: {pct:.1f}%")
    def set_verbosity(self, verbosity):
        pass

log.set_logger(MyLogger())
```

## Troubleshooting

### Connection fails
- Check serial port: `esptool --port COM3 flash-id`
- Install USB-serial adapter drivers (CP2102, CH340, FTDI)
- Linux: Add user to `dialout` group: `sudo usermod -a -G dialout $USER`
- Try lower baud: `-b 115200`
- Manual bootloader entry: Hold BOOT, press RESET, release BOOT

### Flash write fails
- Check flash size: `esptool flash-id`
- Verify correct offsets for your chip and framework
- Try `--flash-mode dio` if `qio` fails
- Use `--no-stub` for compatibility with some chips

### Boot fails after flashing
- Verify flash mode/size/freq match your hardware
- Check partition table fits within flash size
- Use `--flash-size detect` for auto-detection
- Verify binary is compatible with chip revision

### Permission denied (Linux)
```bash
sudo usermod -a -G dialout $USER
# Then log out and back in, or:
su - $USER
```

## ESP-IDF Flash Offsets

Typical ESP-IDF project flash layout:

| Offset | Content |
|--------|---------|
| 0x0000 | Bootloader (ESP8266) / - (ESP32) |
| 0x1000 | Bootloader (ESP32) |
| 0x8000 | Partition table |
| 0x10000 | Application |

The exact offsets depend on the project configuration. ESP-IDF prints the full flash command after building. Use the `build/flash_args` file or `@flash_args` with esptool.
