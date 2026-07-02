# 深空联合助手

## 项目简介

深空联合助手是一个用于配置终端设备SD卡数据的Windows上位机应用程序。用户可以通过图形界面方便地配置终端设备的各种参数，实现个性化的终端配置。

## 技术架构

### 技术栈
- **前端**: Qt QML
- **后端**: C++17
- **构建系统**: CMake 3.16+
- **UI框架**: Qt Quick Controls 2

### 项目结构

```
terminal_assistant/
├── CMakeLists.txt              # CMake构建配置
├── README.md                   # 项目说明文档
├── docs/                       # 文档目录
│   └ary backend-api.md         # 后端API文档（供前端参考）
├── main.cpp                    # 程序入口
│
├── src/
│   ├── backend/                # 后端模块
│   │   ├── sdcard/             # SD卡操作模块
│   │   │   ├── SDCardManager.h
│   │   │   └── SDCardManager.cpp
│   │   ├── basic/              # 基础配置后端
│   │   │   ├── BasicConfig.h
│   │   │   └── BasicConfig.cpp
│   │   ├── agent/              # 智能体配置后端
│   │   │   ├── AgentConfig.h
│   │   │   └── AgentConfig.cpp
│   │   ├── radio/              # 电台配置后端
│   │   │   ├── RadioConfig.h
│   │   │   └── RadioConfig.cpp
│   │   ├── maintenance/        # 维护模块后端
│   │   │   ├── MaintenanceManager.h
│   │   │   └── MaintenanceManager.cpp
│   │   ├── python/             # Python调用接口
│   │   │   ├── PythonRunner.h
│   │   │   └── PythonRunner.cpp
│   │   └── logger/             # 日志管理
│   │       ├── Logger.h
│   │       └── Logger.cpp
│   │
│   └── frontend/               # 前端模块(QML)
│       ├── qml/                # QML文件
│       │   ├── main.qml        # 主窗口
│       │   ├── CustomTabBar.qml
│       │   ├── LogPanel.qml
│       │   ├── ApplyButton.qml
│       │   ├── BasicConfigPage.qml
│       │   ├── AgentConfigPage.qml
│       │   ├── RadioConfigPage.qml
│       │   └── MaintenancePage.qml
│       └── images/             # 图片资源
│
└── tests/                      # 测试目录(待添加)
```

## 功能模块

### 前端界面

#### 主要特性
- 窗口默认分辨率：1080x720
- 窗口自适应缩放
- 白色基调界面设计

#### 页面模块
1. **基础配置** - 设备基础参数配置
2. **智能体配置** - 智能体相关配置
3. **电台配置** - 电台参数配置
4. **维护** - 系统维护功能

#### 底部面板
- 左侧：实时操作日志显示
- 右侧：应用按钮

### 后端功能

#### SDCardManager (SD卡管理)
- `findSDCard()` - 寻找SD卡
- `readSDCard()` - 读取SD卡
- `getCardSize()` - 获取SD卡容量
- `getFreeSpace()` - 获取SD卡剩余空间
- `isFAT32()` - 检查是否为FAT32文件系统

#### BasicConfig (基础配置)
- `loadConfig()` - 加载配置
- `saveConfig()` - 保存配置
- `getConfig()` - 获取配置数据
- `setConfig()` - 设置配置数据

#### AgentConfig (智能体配置)
- 配置加载与保存功能
- 配置数据管理

#### RadioConfig (电台配置)
- 配置加载与保存功能
- 配置数据管理

#### MaintenanceManager (维护管理)
- `diagnose()` - 系统诊断
- `exportLogs()` - 导出日志
- `importLogs()` - 导入日志

#### PythonRunner (Python脚本执行器)
- `runScript()` - 执行Python脚本
- `setPythonPath()` - 设置Python解释器路径
- `getOutput()` - 获取脚本输出

#### Logger (日志管理)
- `log()` - 记录普通日志
- `logInfo()` - 记录信息日志
- `logWarning()` - 记录警告日志
- `logError()` - 记录错误日志
- `getLogHistory()` - 获取历史日志
- `clearLog()` - 清空日志

#### UserSettings (用户设置管理)
- `apiKey()` - 获取/设置API密钥
- `isFirstBoot()` - 初次开机标志
- `roleList()` - 角色信息列表
- `version()` - 版本号
- `loadFromFile()` / `saveToFile()` - 文件读写

#### RoleInfo (角色信息)
- `name()` / `id()` - 名称和编号
- `avatarBinPath()` - 头像文件路径
- `agentId()` - Agent ID
- `voiceCloneId()` - 声音复刻ID
- `voiceCloneMaterialPath()` - 声音素材路径

## 构建说明

### 环境要求
- Qt 6.x
- CMake 3.16+
- C++17编译器
- Windows操作系统

### 构建步骤

```bash
# 创建构建目录
mkdir build
cd build

# 配置CMake
cmake -G "Ninja" ..

# 编译
ninja
```

### 运行

```bash
./DeepSpaceAssistant.exe
```

## 开发状态

### 已完成
- [x] 项目框架搭建
- [x] 前后端基础架构
- [x] 前端界面框架（标签页切换、日志面板）
- [x] 后端类声明（空实现）

### 待完成
- [ ] SD卡读取功能实现
- [ ] 各模块配置界面详细实现
- [ ] 前后端数据交互
- [ ] Python脚本调用功能
- [ ] 日志系统集成
- [ ] 单元测试
- [ ] UserSettings文件读写实现（JSON格式）

## 更新日志

### 2026-07-02
- 初始化项目框架
- 创建基础目录结构
- 实现前端QML界面框架
- 创建后端类声明（空实现）
- 配置CMake构建系统
- 修复QML模块导入问题
- 使用Qt6推荐的loadFromModule加载方式
- 项目编译成功并可正常运行
- 修复ApplyButton.qml cursorShape属性错误
- 更新qt-build skill添加错误捕获测试方法
- 修改默认分辨率为1080x720

## 文档

- [后端API文档](docs/backend-api.md) - 详细的后端接口说明，供前端开发参考

## 许可证

待定

## 联系方式

待定