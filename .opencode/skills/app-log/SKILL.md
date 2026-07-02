---
name: app-log
description: Use when adding logging to QML or C++ code in this project. Documents how to use the Logger singleton to display logs in LogPanel, and the architecture connecting them.
---

# App Log Skill

This skill documents the logging system and how to display logs in the LogPanel UI component.

## Architecture

```
Logger (C++ singleton)  -->  main.cpp (QML context property)  -->  Main.qml (Connections)  -->  LogPanel.qml
     logger.logInfo()          setContextProperty("logger")        onNewLogEntry()            appendLog()
     logger.logWarning()       &Logger::instance()                 logPanel.appendLog()       fullLog display
     logger.logError()
```

## QML Usage

In any QML file, use the globally available `logger` object:

```qml
logger.logInfo("普通日志消息")
logger.logWarning("警告消息")
logger.logError("错误消息")
logger.log("等同logInfo")
logger.clearLog()
```

**Do NOT use `console.log()`** for logs that should appear in LogPanel. `console.log()` only outputs to stderr/debug console and is not routed to the UI.

## C++ Usage

```cpp
#include "src/backend/logger/Logger.h"

Logger::instance().logInfo("消息");
Logger::instance().logWarning("警告");
Logger::instance().logError("错误");
```

## Key Files

| File | Role |
|---|---|
| `src/backend/logger/Logger.h` | Logger singleton declaration (Q_INVOKABLE methods, newLogEntry signal) |
| `src/backend/logger/Logger.cpp` | Logger implementation (timestamped entries, signal emission) |
| `src/frontend/qml/components/LogPanel.qml` | Log display component (appendLog, clearLog, tooltip with full history) |
| `src/frontend/qml/Main.qml` | Connections block routing logger signals to logPanel |
| `main.cpp` | Registers Logger as QML context property "logger" |

## Log Format

```
[2025-07-03 05:20:35] [INFO] 应用按钮被点击
[2025-07-03 05:20:35] [WARN] 磁盘空间不足
[2025-07-03 05:20:35] [ERROR] 文件写入失败
```

## LogPanel Behavior

- Displays only the **last log line** (truncated to 100 chars) in the label
- Hovering shows a **tooltip** with the full log history
- `clearLog()` clears both the history and the display

## Adding a New Log Source

When adding logging from a new QML file or C++ class:

1. **QML**: Just call `logger.logInfo("msg")` directly — `logger` is a global context property
2. **C++**: Include Logger.h and call `Logger::instance().logInfo("msg")` — the signal propagates automatically via the existing Connections binding in Main.qml
