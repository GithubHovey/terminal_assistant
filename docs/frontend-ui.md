# 前端UI文档

本文档描述前端QML界面结构、布局和设计规范。

---

## 技术栈

- **框架**: Qt 6.8.3 Quick / QML
- **样式**: Basic (QQuickStyle::setStyle("Basic"))
- **字体**: Source Han Sans CN（思源黑体）
- **窗口**: 1080x720，自适应缩放

---

## 目录结构

```
src/frontend/qml/
├── Main.qml                          # 主窗口
├── components/
│   ├── CustomTabBar.qml              # 自定义标签栏
│   ├── LogPanel.qml                  # 日志面板
│   └── ApplyButton.qml               # 应用按钮
└── pages/
    ├── BasicConfigPage.qml           # 基础配置页
    ├── AgentConfigPage.qml           # 智能体配置页（容器）
    ├── RadioConfigPage.qml           # 电台配置页
    ├── MaintenancePage.qml           # 维护页
    └── agent/
        ├── AccountPage.qml           # 账号配置
        ├── HotWordsPage.qml          # 热词库
        ├── KnowledgeBasePage.qml     # 知识库
        ├── RolePage.qml              # 角色配置
        └── OtherPage.qml             # 其他设置
```

---

## 主窗口布局 (Main.qml)

```
┌──────────────────────────────────────────────────┐
│  CustomTabBar (高度36px)                          │
│  [基础配置] [智能体配置] [电台配置] [维护]          │
├──────────────────────────────────────────────────┤
│                                                  │
│  StackLayout (填充剩余空间)                       │
│  根据 tabBar.currentIndex 切换页面                │
│                                                  │
├──────────────────────────────────────────────────┤
│  LogPanel            │  ApplyButton (120px)      │
│  (显示最新一条日志)    │  (高度40px)               │
└──────────────────────────────────────────────────┘
```

---

## 智能体配置页 (AgentConfigPage.qml)

左右布局，左侧导航 + 右侧内容区。

```
┌───────────┬──────────────────────────────────────┐
│ 左侧导航   │  StackLayout (右侧内容区)            │
│ (180px)   │                                      │
│           │  currentIndex 与左侧导航同步           │
│ 👤 账号   │                                      │
│ 📝 热词库  │  ┌─────────────────────────────┐     │
│ 📚 知识库  │  │ 对应的子页面                  │     │
│ 🎭 角色   │  │                             │     │
│ ⚙️ 其他   │  │                             │     │
│           │  └─────────────────────────────┘     │
└───────────┴──────────────────────────────────────┘
```

### 子页面索引

| 索引 | 名称 | 文件 |
|------|------|------|
| 0 | 账号 | AccountPage.qml |
| 1 | 热词库 | HotWordsPage.qml |
| 2 | 知识库 | KnowledgeBasePage.qml |
| 3 | 角色 | RolePage.qml |
| 4 | 其他 | OtherPage.qml |

---

## 账号配置页 (AccountPage.qml)

```
┌──────────────────────────────────────────────────┐
│  [头像]  (80x80圆形，点击更换)                     │
│                                                  │
│  账号配置                                         │
│                                                  │
│  服务商: 阿里百炼                                  │
│                                                  │
│  API-KEY: [输入框]                                │
│                                                  │
│  获取API-KEY: [打开阿里百炼控制台]                  │
└──────────────────────────────────────────────────┘
```

### 功能

- **头像**: 80x80圆形，显示首字母"U"，点击弹出更换头像对话框
- **API-KEY**: 输入框，用于配置阿里百炼API密钥
- **获取链接**: 点击打开阿里百炼控制台网页

---

## 角色配置页 (RolePage.qml)

三区域布局：左侧角色列表 + 右侧配置区（左右两列）。

```
┌────────┬──────────────────────┬──────────────────────┐
│ 角色列表 │ 左列 (45%)           │ 右列 (55%)           │
│(120px) │                      │                      │
│        │ [头像] 角色名称       │ ── 参考提示词 ──     │
│ 角色列表 │ 更换头像             │ ┌──────────────────┐ │
│        │                      │ │ [TextArea]       │ │
│ [角色1] │ 英文名(SD卡): [__]   │ │ 灰色背景+边框     │ │
│ [角色2] │                      │ └──────────────────┘ │
│ [角色3] │ ── 声音复刻 ──       │ [复制提示词]         │
│        │ 模型: cosyvoice...   │                      │
│        │ 素材: [__] [选择][复刻]│                      │
│        │ 试听: [__] [合成试听]  │                      │
│        │                      │                      │
│        │ ── 智能体配置 ──      │                      │
│        │ 地址: [__________]    │                      │
│        │ ID:   [__________]    │                      │
│        │ [智能体配置与测试]     │                      │
│        │                      │                      │
│        │ [生成NFC信息]         │                      │
│        │ ┌──────────────────┐ │                      │
│        │ │ NFC结果 (只读)    │ │                      │
│        │ └──────────────────┘ │                      │
│        │ [复制NFC信息]        │                      │
│        │                      │                      │
│ [+添加] │                      │                      │
└────────┴──────────────────────┴──────────────────────┘
```

### 布局说明

- **左侧角色列表** (120px)：显示所有角色，选中高亮
- **右侧配置区**：使用 `Item` + `anchors` 实现 45%/55% 自适应比例分列
- **空状态**：未选中角色时显示 "请先创建一个角色"

### 属性

```qml
property string newRoleName: ""     // 新建角色名称
property int deleteIndex: -1        // 待删除角色索引
property bool nfcGenerated: false   // NFC是否已生成
property string nfcResult: ""       // NFC生成结果文本
```

### 弹窗

| 弹窗 | 说明 |
|------|------|
| addRoleDialog | 添加角色，输入角色名称 |
| deleteConfirmDialog | 确认删除角色 |
| avatarDialog | 更换头像，选择图片文件 |

### 功能模块

1. **角色列表管理**：添加、删除、选中角色
2. **头像配置**：点击头像或按钮更换
3. **基本信息**：角色名称、英文名(SD卡)
4. **声音复刻**：模型选择(cosyvoice-v3.5-plus)、素材文件、试听
5. **智能体配置**：API地址、ID、配置测试
6. **生成NFC**：生成NFC信息文本，支持复制
7. **参考提示词**：编辑提示词，支持复制

---

## 电台配置页 (RadioConfigPage.qml)

歌曲卡片网格布局，支持导入、播放、排序、删除和封面管理。

```
┌──────────────────────────────────────────────────┐
│  ♪ 电台歌曲列表                      共 N 首      │
├──────────────────────────────────────────────────┤
│                                                  │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐│
│  │ [封面]  │ │ [封面]  │ │ [封面]  │ │  ＋     ││
│  │  160x   │ │  160x   │ │  160x   │ │ 添加    ││
│  │ 160     │ │         │ │         │ │ 歌曲    ││
│  │         │ │         │ │         │ │ (MP3)   ││
│  ├─────────┤ ├─────────┤ ├─────────┤ └─────────┘│
│  │001 歌名 │ │002 歌名 │ │003 歌名 │            │
│  │ 未知专辑 │ │ 未知专辑 │ │ 未知专辑 │            │
│  │         │ │         │ │         │            │
│  │    [▶][✕]│ │    [▶][✕]│ │    [▶][✕]│            │
│  │    [↑][↓]│ │    [↑][↓]│ │    [↑][↓]│            │
│  └─────────┘ └─────────┘ └─────────┘            │
│                                                  │
└──────────────────────────────────────────────────┘
```

### 歌曲卡片 (245x260)

| 区域 | 说明 |
|------|------|
| 封面区 (160x160) | 显示封面图片，无封面显示音符图标，点击可更换封面 |
| 编号 | Consolas字体，三位编号（001, 002...），蓝色 |
| 标题 | 歌曲名称，粗体，超长省略 |
| 播放按钮 | 绿色圆形，播放/暂停切换 |
| 删除按钮 | 红色圆形，悬停卡片时显示 |
| 上/下移按钮 | 调整歌曲顺序 |

### 目录结构

歌曲文件存储在 `music/` 目录下，按编号组织：

```
music/
├── radio_config.json      # 歌曲配置
├── 001/
│   ├── 001.mp3           # 音频文件
│   └── cover.bin         # 封面图片（可选）
├── 002/
│   ├── 002.mp3
│   └── cover.bin
└── ...
```

### JSON 配置格式

```json
{
    "songs": [
        {
            "id": "001",
            "title": "歌曲名称",
            "mp3": "001/001.mp3",
            "cover": "001/cover.bin"
        }
    ]
}
```

### 导入流程

1. 点击"添加歌曲"卡片 → 选择 MP3 文件
2. 文件复制为 `music/NNN/NNN.mp3`
3. 弹出封面选择对话框（可跳过）
4. 选择封面 → 复制为 `music/NNN/cover.bin`

### 排序行为

移动歌曲位置时，物理目录和文件会同步重命名：
- 目录重命名采用"先临时名再最终名"策略，避免冲突
- MP3 文件名同步更新为 `NNN.mp3`
- 封面路径同步更新为 `NNN/cover.bin`

### 弹窗

| 弹窗 | 说明 |
|------|------|
| fileDialog | 选择 MP3 文件导入 |
| coverFileDialog | 导入时选择封面（可跳过） |
| deleteConfirmDialog | 确认删除歌曲 |
| coverChangeDialog | 查看/更换已有歌曲封面 |
| coverChangeFileDialog | 选择新封面图片 |

---

## 组件说明

### CustomTabBar.qml

自定义标签栏组件，基于 `TabBar`。

```qml
TabBar {
    property color accentColor: "#1890FF"       // 主题色
    property color textColor: "#333333"          // 默认文字色
    property color selectedTextColor: "#1890FF"  // 选中文字色
}
```

### LogPanel.qml

日志面板组件，基于 `Label`。

```qml
Label {
    // 方法
    function appendLog(message)   // 追加日志
    function clearLog()           // 清空日志
    
    // 属性
    property string fullLog       // 完整日志文本
}
```

- 显示最新一条日志
- 鼠标悬停显示完整日志 Tooltip
- 字体: Consolas, 12px

### ApplyButton.qml

应用按钮组件，基于 `Button`。

- 尺寸: 100x40
- 颜色: #1890FF (hover: #40A9FF, pressed: #096DD9)
- 圆角: 8px

---

## 颜色规范

| 用途 | 颜色 | 说明 |
|------|------|------|
| 主题色 | `#1890FF` | 选中状态、链接、主按钮 |
| 主题色Hover | `#40A9FF` | 按钮悬停 |
| 主题色Pressed | `#096DD9` | 按钮按下 |
| 文字主色 | `#333333` | 正文文字 |
| 文字次色 | `#666666` | 次要文字 |
| 文字辅助 | `#999999` | 提示文字 |
| 背景色 | `#FFFFFF` | 主背景 |
| 次背景色 | `#F5F5F5` | 内容区背景 |
| 边框色 | `#D9D9D9` | 输入框边框 |
| 文本框背景 | `#FAFAFA` | TextArea背景 |
| 成功色 | `#52C41A` | NFC按钮等 |
| 危险色 | `#FF4D4F` | 删除按钮 |
| 悬停浅蓝 | `#E6F7FF` | 列表项悬停 |

---

## 字体规范

| 用途 | 大小 | 样式 |
|------|------|------|
| 标签页标题 | 20px | Bold |
| 页面标题 | 18px | Bold |
| 区块标题 | 16px | Bold |
| 侧栏标题 | 16px | Bold |
| 正文/标签 | 14px | Normal |
| 小按钮 | 12px | Normal |
| 日志 | 12px | Consolas |

---

## 布局实现要点

### 左右比例分列

角色配置页右侧使用 `Item` + `anchors` 实现自适应比例：

```qml
Item {
    anchors.fill: parent
    anchors.margins: 20
    
    ColumnLayout {
        id: leftColumn
        width: parent.width * 0.45 - 15
        height: parent.height
        anchors.left: parent.left
    }
    
    ColumnLayout {
        width: parent.width * 0.55 - 15
        height: parent.height
        anchors.left: leftColumn.right
        anchors.leftMargin: 30
    }
}
```

### TextArea 样式

统一使用 Rectangle 包裹实现边框效果：

```qml
Rectangle {
    color: "#FAFAFA"
    border.color: "#D9D9D9"
    border.width: 1
    radius: 4
    
    TextArea {
        anchors.fill: parent
        anchors.margins: 8
        background: Rectangle { color: "transparent" }
    }
}
```

---

## CMake 注册

QML文件通过 `qt_add_qml_module` 注册，模块URI为 `App`：

```cmake
qt_add_qml_module(DeepSpaceAssistant
    URI App
    VERSION 1.0
    QML_FILES
        src/frontend/qml/Main.qml
        # ... 所有QML文件
)
```

加载方式（main.cpp）：

```cpp
engine.loadFromModule(u"App"_s, u"Main"_s);
```
