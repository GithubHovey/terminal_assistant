---
name: image-process
description: Use when converting PNG images to LVGL .bin format for the terminal. Supports three image types - role avatar (60x60), chat background (280x171), and radio cover (160x160) - all using RGB565A8 color format. Documents the three-layer architecture (QML preview, C++ processing, Python conversion), ImageProcessor class, and integration with CharacterManager/RadioConfig.
---

# 终端图片处理 Skill

三层协作架构：QML 交互预览 → C++ 图像处理 → Python 格式转换

## 架构总览

```
┌─────────────────────────────────────────────────────────┐
│  第1层：QML（交互预览）                                   │
│  ├─ avatarCropDialog 圆形预览（200x200）                  │
│  ├─ Image + scale/x/y 实现缩放拖拽                        │
│  └─ Slider 控制缩放比例                                   │
└─────────────────────────────────────────────────────────┘
                          ↓ 用户点击"确定"
┌─────────────────────────────────────────────────────────┐
│  第2层：C++ ImageProcessor（图像处理）                     │
│  ├─ cropCircular() 圆形裁剪（头像）                       │
│  ├─ cropRectangular() 矩形裁剪（背景、封面）              │
│  ├─ QImage + QPainter 精确裁剪                            │
│  └─ 保存 <englishname>.png 到角色目录                     │
└─────────────────────────────────────────────────────────┘
                          ↓ 处理完成
┌─────────────────────────────────────────────────────────┐
│  第3层：Python（格式转换）                                 │
│  ├─ pythonRunner.runScript("convert_image", args)        │
│  ├─ 读取刚生成的 PNG                                      │
│  ├─ 调用 LVGLImage 转换为 RGB565A8 格式                  │
│  └─ 保存 <englishname>.bin 到角色目录                     │
└─────────────────────────────────────────────────────────┘
```

## 图片规格速查

| 类型 | 参数值 | 尺寸 | 用途 | 存放路径 |
|------|--------|------|------|----------|
| 角色头像 | `avatar` | 60×60 | 角色列表/详情显示 | `character/<角色名>/<英文名>.bin` |
| 聊天背景 | `chatbg` | 280×171 | 聊天界面背景 | `character/<角色名>/chatbg.png` |
| 电台封面 | `cover` | 160×160 | 音乐列表封面 | `music/<NNN>/cover.bin` |

**注意**：角色头像使用 `<英文名>.png` 和 `<英文名>.bin`，不是固定的 `avatar.bin`。

## 依赖安装

```bash
pip install pypng lz4 Pillow
```

## ImageProcessor C++ 类

### 头文件

```cpp
// src/backend/image/ImageProcessor.h
class ImageProcessor : public QObject
{
    Q_OBJECT
public:
    // 圆形裁剪（用于头像）
    Q_INVOKABLE bool cropCircular(const QString &inputPath,
                                  const QString &outputPath,
                                  int targetSize,
                                  int offsetX, int offsetY,
                                  double scale);
    
    // 矩形裁剪（用于背景、封面）
    Q_INVOKABLE bool cropRectangular(const QString &inputPath,
                                     const QString &outputPath,
                                     int targetWidth, int targetHeight,
                                     int offsetX, int offsetY,
                                     double scale);
};
```

### 使用示例（QML）

```qml
// 角色头像裁剪
var success = imageProcessor.cropCircular(
    sourceImagePath,           // 输入 PNG 路径
    characterManager.roleDir(roleName) + "/" + englishName + ".png",
    60,                        // 目标尺寸
    offsetX, offsetY,          // 偏移量（从 QML 预览获取）
    scaleValue                 // 缩放比例
)
```

## 转换命令

### 使用包装脚本（推荐）

```powershell
# 角色头像
python scripts/convert_image.py --type avatar --input SOLARIS.png --output SOLARIS.bin

# 聊天背景
python scripts/convert_image.py --type chatbg --input chatbg.png --output chatbg.bin

# 电台封面
python scripts/convert_image.py --type cover --input cover.png --output cover.bin
```

### 直接使用 LVGLImage.py

```powershell
python scripts/LVGLImage.py --cf RGB565A8 --ofmt BIN input.png -o output_dir
```

**注意**：输入 PNG 尺寸必须严格匹配目标尺寸，不匹配会报错退出，不会自动缩放。

## 完整工作流（角色头像）

```qml
// avatarCropDialog 确定按钮 onClicked
function processAvatar() {
    var englishName = currentEnglishName()
    var roleName = currentRole.name
    
    // 1. C++ 裁剪生成 PNG
    var pngPath = characterManager.roleDir(roleName) + "/" + englishName + ".png"
    var success = imageProcessor.cropCircular(
        sourceImagePath, pngPath, 60,
        offsetX, offsetY, scaleValue
    )
    
    if (success) {
        // 2. Python 转换为 BIN
        var binPath = characterManager.roleDir(roleName) + "/" + englishName + ".bin"
        var binSuccess = pythonRunner.runScript("convert_image", [
            "--type", "avatar",
            "--input", pngPath,
            "--output", binPath
        ])
        
        if (binSuccess) {
            logger.logInfo("头像处理完成")
            avatarCropDialog.close()
        }
    }
}
```

## RGB565A8 格式说明

- **RGB565**：16bit 颜色（R:5bit, G:6bit, B:5bit），每像素 2 字节
- **A8**：8bit Alpha 通道，每像素 1 字节，附加在 RGB565 数据之后
- **总 bpp**：16（颜色）+ 8（Alpha 分离）
- **BIN 结构**：12 字节 LVGL 9.x 图像头 + RGB565 数据 + A8 Alpha 数据

## CharacterManager 路径方法

```cpp
// 头像 PNG 路径（用于显示）
QString avatarPath(const QString &name) const;
// 返回: character/<角色名>/<英文名>.png

// 头像 BIN 路径（用于终端设备）
QString avatarBinPath(const QString &name) const;
// 返回: character/<角色名>/<英文名>.bin
```

## 关键文件

| 文件 | 作用 |
|------|------|
| `src/backend/image/ImageProcessor.h/.cpp` | C++ 图像裁剪处理类 |
| `src/backend/python/PythonRunner.h/.cpp` | C++ QProcess 调用封装 |
| `src/backend/character/CharacterManager.h/.cpp` | 角色文件目录管理 |
| `src/frontend/qml/pages/agent/RolePage.qml` | avatarCropDialog 交互预览 |
| `scripts/LVGLImage.py` | LVGL 图像转换核心库 |
| `scripts/convert_image.py` | 包装脚本，简化转换流程 |

## 打包为独立 exe

```powershell
pip install pyinstaller
pyinstaller --onefile scripts/convert_image.py --distpath python/ --name convert_image
```

打包后的 `python/convert_image.exe` 随应用分发，用户无需安装 Python。

## 注意事项

- QML 预览区域为 200x200，最终输出为 60x60（按比例缩放）
- C++ 处理保证图像质量和精确裁剪
- Python 负责格式转换，生成终端专用 BIN 格式
- 圆形头像使用 `QPainter::setClipPath()` 实现圆形蒙版
- 输入 PNG 尺寸必须严格匹配目标尺寸（convert_image.py 验证）
- RGB565A8 适合需要半透明的图片（如头像、带渐变背景的封面）
