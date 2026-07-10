---
name: sdcard
description: Use when modifying the SD card / removable drive detection feature. Documents the event-driven hot-plug architecture (WM_DEVICECHANGE), FindVolumeW cold scan, DeviceEventFilter, SDCardManager, and QML integration.
---

# SD Card Detection Skill

This skill documents the SD card / removable drive detection architecture in this project.

## Architecture Overview

The SD card detection uses a **two-layer approach**:

1. **Event-driven hot-plug** (instant, <100ms): `DeviceEventFilter` intercepts `WM_DEVICECHANGE` Windows messages to detect USB/SD card insertions and removals in real-time.
2. **FindVolumeW cold scan** (fast, <100ms): `SDCardManager::scanRemovableDrives()` uses `FindFirstVolumeW` / `FindNextVolumeW` to enumerate only mounted volumes, avoiding the blocking issue with empty card reader slots.

## Key Files

| File | Purpose |
|---|---|
| `src/backend/sdcard/DeviceEventFilter.h/.cpp` | `QAbstractNativeEventFilter` subclass that intercepts `WM_DEVICECHANGE` messages |
| `src/backend/sdcard/SDCardManager.h/.cpp` | Core logic: cold scan, connect/disconnect, connection monitoring |
| `main.cpp` | Wires `DeviceEventFilter` signals to `SDCardManager` slots |
| `src/frontend/qml/Main.qml` | Bottom bar UI: refresh button, drive ComboBox, connect/disconnect |

## How It Works

### Hot-Plug Detection (DeviceEventFilter)

```
Windows OS
  -> WM_DEVICECHANGE message
  -> QGuiApplication native event filter
  -> DeviceEventFilter::nativeEventFilter()
  -> Parse DEV_BROADCAST_VOLUME from lParam
  -> Extract drive letter(s) from dbcv_unitmask bitmask
  -> Emit deviceArrived(letter) or deviceRemoved(letter)
  -> SDCardManager::onDeviceArrived() / onDeviceRemoved()
  -> 500ms debounce timer -> refreshDrives()
```

Key constants (from `<dbt.h>`):
- `DBT_DEVICEARRIVAL` (0x8000): device inserted
- `DBT_DEVICEREMOVECOMPLETE` (0x8004): device removed
- `DBT_DEVTYP_VOLUME` (0x00000002): volume-type device
- `DEV_BROADCAST_VOLUME::dbcv_unitmask`: bitmask where bit 0 = A:, bit 2 = C:, etc.

### Cold Scan (scanRemovableDrives)

```
FindFirstVolumeW() -> volume GUID path (e.g., \\?\Volume{GUID}\)
  -> GetVolumePathNamesForVolumeNameW() -> mount points (e.g., E:\)
  -> Filter: only root drive letters (length == 3, pattern X:\)
  -> GetDriveTypeW() == DRIVE_REMOVABLE
  -> QStorageInfo(mountPoint) -> isValid() && isReady()
  -> Add to result list
FindNextVolumeW() -> repeat
FindVolumeClose()
```

**Why FindFirstVolumeW instead of GetLogicalDrives:**
- `GetLogicalDrives()` returns ALL assigned drive letters, including empty card reader slots
- `QStorageInfo` on an empty slot blocks for 5-10 seconds (OS polls the device)
- `FindFirstVolumeW` only returns volumes with actual mounted filesystems
- Empty card reader slots have no volume, so they're skipped entirely

### Connection Flow

1. User sees drive list in ComboBox (populated by cold scan on startup + hot-plug events)
2. User selects a drive and clicks "Connect"
3. `SDCardManager::connectCard(letter)` validates with `QStorageInfo`
4. Connection monitor timer starts (10s interval, fallback for undetected removals)
5. On device removal event: auto-disconnect if the removed drive was connected

## QML Integration

```qml
// Bottom bar in Main.qml
Button { text: "刷新"; onClicked: sdCardManager.refreshDrives() }
ComboBox { model: sdCardManager.availableDrives; textRole: "display" }
Button { text: sdCardManager.connected ? "断开" : "连接" }
```

Properties exposed to QML:
- `connected` (bool): whether a card is connected
- `driveLetter` (string): connected drive letter (e.g., "E:")
- `cardSize` / `freeSpace` (qint64): in bytes
- `availableDrives` (QVariantList): list of `{letter, label, size, display}`

## main.cpp Wiring

```cpp
SDCardManager sdCardManager;
engine.rootContext()->setContextProperty("sdCardManager", &sdCardManager);

DeviceEventFilter deviceFilter;
app.installNativeEventFilter(&deviceFilter);
QObject::connect(&deviceFilter, &DeviceEventFilter::deviceArrived,
                 &sdCardManager, &SDCardManager::onDeviceArrived);
QObject::connect(&deviceFilter, &DeviceEventFilter::deviceRemoved,
                 &sdCardManager, &SDCardManager::onDeviceRemoved);
```

## Important Notes

- `DeviceEventFilter` inherits from both `QObject` (for signals) and `QAbstractNativeEventFilter` (for native event interception)
- Must include `<dbt.h>` for `DBT_DEVICEARRIVAL`, `DEV_BROADCAST_VOLUME`, etc.
- The 500ms debounce timer coalesces multiple rapid arrival events into a single refresh
- The 10s connection monitor timer is a fallback; primary removal detection is event-driven
- `QGuiApplication::installNativeEventFilter()` must be called before `app.exec()`
- Cold scan runs in the constructor to populate the initial drive list

## Common Pitfalls

1. **Missing `<dbt.h>`**: `DBT_DEVICEARRIVAL` and related constants won't compile
2. **Using `GetLogicalDrives()` for cold scan**: blocks on empty card reader slots (5-10s each)
3. **Not debouncing arrival events**: Windows may send multiple `DBT_DEVICEARRIVAL` for a single insertion
4. **Forgetting `FindVolumeClose()`**: resource leak
5. **`QStorageInfo` on non-ready drives**: blocks the calling thread; only call on volumes confirmed by `FindFirstVolumeW`
