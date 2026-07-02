---
name: qt-build
description: Use when building and running Qt CMake projects in this workspace. Handles compilation with ninja and execution with proper Qt environment setup.
---

# Qt Build and Run Skill

This skill provides instructions for compiling and running Qt projects in this workspace.

## Project Information

- Qt Version: 6.8.3
- Compiler: MinGW 64-bit
- Build System: CMake + Ninja
- Target: terminal_assistant

## Build Directory

```
build/Desktop_Qt_6_8_3_MinGW_64_bit-Debug/
```

## Compilation

Run ninja in the build directory:

```powershell
# 清理旧日志
Remove-Item -LiteralPath "build\qt_error.log" -Force -ErrorAction SilentlyContinue

# 编译
& "A:/app/QT/Tools/Ninja/ninja.exe"
```

Working directory: `build/Desktop_Qt_6_8_3_MinGW_64_bit-Debug`

## Running the Application

Set PATH to include Qt and MinGW binaries, then run the executable:

```powershell
$env:PATH = "A:/app/QT/6.8.3/mingw_64/bin;A:/app/QT/Tools/mingw1310_64/bin;" + $env:PATH
& "build/Desktop_Qt_6_8_3_MinGW_64_bit-Debug/DeepSpaceAssistant.exe"
```

**注意：GUI程序不会自动退出，直接运行会卡住。请使用后台启动方式：**

## Testing with Error Capture

由于Qt Creator能实时显示错误，推荐优先使用Qt Creator调试。但如果需要命令行测试，使用以下方法：

```powershell
# 后台启动，捕获错误日志到build目录
$env:PATH = "A:/app/QT/6.8.3/mingw_64/bin;A:/app/QT/Tools/mingw1310_64/bin;" + $env:PATH
Start-Process -FilePath "build\Desktop_Qt_6_8_3_MinGW_64_bit-Debug\DeepSpaceAssistant.exe" -RedirectStandardError "build\qt_error.log"

# 等待至少5秒让QML错误完全输出（重要！）
Start-Sleep -Seconds 5

# 检查进程是否运行（有进程=启动成功）
Get-Process -Name "DeepSpaceAssistant" -ErrorAction SilentlyContinue

# 读取错误日志
Get-Content "build\qt_error.log"
```

**关键点：**
- 必须等待至少5秒再读取日志，QML错误需要时间才能写入
- 只看到"QML debugging is enabled"不代表成功，要检查是否有其他错误
- 常见QML错误：类型不可用、属性不存在、组件加载失败

## Tool Paths

- Ninja: `A:/app/QT/Tools/Ninja/ninja.exe`
- Qt Binaries: `A:/app/QT/6.8.3/mingw_64/bin`
- MinGW: `A:/app/QT/Tools/mingw1310_64/bin`

## Notes

- The project uses QML (Qt Quick) with `qt_add_qml_module`
- Debug build is configured by default
- WIN32_EXECUTABLE is enabled for Windows
- QML文件名必须大写开头（如Main.qml）才能被`loadFromModule`识别
- 关闭运行中的程序：`Get-Process -Name "DeepSpaceAssistant" | Stop-Process -Force`