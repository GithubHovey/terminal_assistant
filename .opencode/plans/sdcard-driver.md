# SD卡驱动实现计划

## 概述
实现SD卡检测、连接/断开功能，并在底部栏添加SD卡控制面板。

## 修改文件清单

| 文件 | 操作 |
|---|---|
| `src/backend/sdcard/SDCardManager.h` | 重写 |
| `src/backend/sdcard/SDCardManager.cpp` | 重写 |
| `main.cpp` | 添加注册 |
| `src/frontend/qml/Main.qml` | 修改底部栏 |

---

## 1. SDCardManager.h（重写）

```cpp
#ifndef SDCARDMANAGER_H
#define SDCARDMANAGER_H

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QTimer>

class SDCardManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool connected READ isConnected NOTIFY connectedChanged)
    Q_PROPERTY(QString driveLetter READ driveLetter NOTIFY connectedChanged)
    Q_PROPERTY(qint64 cardSize READ cardSize NOTIFY connectedChanged)
    Q_PROPERTY(qint64 freeSpace READ freeSpace NOTIFY connectedChanged)
    Q_PROPERTY(QVariantList availableDrives READ availableDrives NOTIFY driveListChanged)

public:
    explicit SDCardManager(QObject *parent = nullptr);
    ~SDCardManager() override;

    bool isConnected() const;
    QString driveLetter() const;
    qint64 cardSize() const;
    qint64 freeSpace() const;
    QVariantList availableDrives() const;

    Q_INVOKABLE void refreshDrives();
    Q_INVOKABLE bool connectCard(const QString &driveLetter);
    Q_INVOKABLE void disconnectCard();
    Q_INVOKABLE QString formatSize(qint64 bytes) const;

signals:
    void connectedChanged();
    void driveListChanged();
    void errorOccurred(const QString &error);

private slots:
    void pollDrives();

private:
    void scanRemovableDrives();

    QTimer *m_pollTimer;
    bool m_connected;
    QString m_driveLetter;
    qint64 m_cardSize;
    qint64 m_freeSpace;
    QVariantList m_availableDrives;
    QStringList m_lastDriveLetters;
};

#endif // SDCARDMANAGER_H
```

## 2. SDCardManager.cpp（重写）

核心逻辑：
- **构造函数**：初始化 QTimer（2秒间隔），连接 `timeout -> pollDrives()`，启动定时器，首次调用 `scanRemovableDrives()`
- **scanRemovableDrives()**：用 `QStorageInfo::mountedVolumes()` 遍历，筛选 `isRemovable()` 且非空的卷，生成 `m_availableDrives` 列表（每项含 `letter`, `label`, `size`），与 `m_lastDriveLetters` 比较，有变化时 emit `driveListChanged()`
- **connectCard(driveLetter)**：
  - 如果已连接，先断开
  - 用 `QStorageInfo(QFileInfo(driveLetter + "/"))` 获取卷信息
  - 验证 `isRemovable()` 和 `isValid()`
  - 获取 `bytesTotal()` 和 `bytesFree()`
  - 设置 `m_connected = true`，emit `connectedChanged()`
  - 用 Logger 记录连接信息
- **disconnectCard()**：清除状态，emit `connectedChanged()`
- **pollDrives()**：调用 `scanRemovableDrives()`，如果已连接的盘符不再存在于可移动磁盘列表中，自动断开
- **formatSize()**：将 bytes 转为 "xx GB" / "xx MB" 格式

需要 `#include <QStorageInfo>` 和 `#include "src/backend/logger/Logger.h"`

## 3. main.cpp（修改）

在 `VoiceLibrary` 注册之后、`logger` 注册之前添加：

```cpp
#include "src/backend/sdcard/SDCardManager.h"
...
SDCardManager sdCardManager;
engine.rootContext()->setContextProperty("sdCardManager", &sdCardManager);
```

## 4. Main.qml 底部栏（修改）

将底部栏的 RowLayout 从：
```
[LogPanel (fillWidth)]  [ApplyButton (120px)]
```

改为：
```
[SD卡控制组件 (~380px)]  [LogPanel (fillWidth)]  [ApplyButton (120px)]
```

SD卡控制组件内容：
```qml
RowLayout {
    Layout.preferredWidth: 380
    Layout.fillHeight: true
    spacing: 8

    // SD卡选择下拉框
    ComboBox {
        id: sdCardCombo
        Layout.preferredWidth: 140
        Layout.fillHeight: true
        enabled: !sdCardManager.connected
        model: sdCardManager.availableDrives
        textRole: "display"
        
        delegate: ItemDelegate {
            width: sdCardCombo.width
            contentItem: Text {
                text: modelData
                font.pixelSize: 13
                color: "#333333"
                verticalAlignment: Text.AlignVCenter
            }
            highlighted: sdCardCombo.highlightedIndex === index
        }
    }

    // 连接状态
    RowLayout {
        spacing: 4
        Rectangle {
            width: 8; height: 8; radius: 4
            color: sdCardManager.connected ? "#52C41A" : "#D9D9D9"
        }
        Text {
            text: sdCardManager.connected
                  ? sdCardManager.formatSize(sdCardManager.freeSpace) + "/" + sdCardManager.formatSize(sdCardManager.cardSize)
                  : "未连接"
            font.pixelSize: 12
            color: "#666666"
        }
    }

    // 连接/断开按钮
    Button {
        Layout.preferredWidth: 64
        Layout.fillHeight: true
        text: sdCardManager.connected ? "断开" : "连接"
        enabled: sdCardManager.connected || sdCardCombo.currentIndex >= 0
        
        background: Rectangle {
            color: sdCardManager.connected
                   ? (parent.pressed ? "#FF4D4F" : (parent.hovered ? "#FF7875" : "#FF4D4F"))
                   : (parent.pressed ? "#096DD9" : (parent.hovered ? "#40A9FF" : "#1890FF"))
            radius: 4
        }
        contentItem: Text {
            text: parent.text
            font.pixelSize: 13
            font.bold: true
            color: "#FFFFFF"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        
        onClicked: {
            if (sdCardManager.connected) {
                sdCardManager.disconnectCard()
            } else {
                var drive = sdCardManager.availableDrives[sdCardCombo.currentIndex]
                // drive 格式: "E:\ (SD 32GB)"，需要提取盘符
                var letter = drive.substring(0, 2)
                sdCardManager.connectCard(letter)
            }
        }
    }
}
```

底部栏高度从 40px 调整为 44px。

---

## 验证步骤

1. `cmake --build build` 编译通过
2. 运行程序，底部栏显示SD卡控制组件
3. 插入SD卡 -> 下拉框自动出现盘符
4. 点击"连接" -> 状态变为绿色，显示容量
5. 点击"断开" -> 状态恢复灰色
6. 拔出SD卡 -> 如果已连接则自动断开
