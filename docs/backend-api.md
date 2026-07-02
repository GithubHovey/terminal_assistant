# 后端API文档

本文档描述后端类的接口，供前端调用参考。

---

## UserSettings 用户设置类

单例模式，存储和管理所有用户设置信息。

### 获取实例

```cpp
UserSettings& settings = UserSettings::instance();
```

### 属性接口

#### API密钥

```cpp
// 获取API密钥
QString apiKey() const;

// 设置API密钥
void setApiKey(const QString &apiKey);
```

**示例：**
```cpp
UserSettings::instance().setApiKey("your-api-key");
QString key = UserSettings::instance().apiKey();
```

---

#### 初次开机标志

```cpp
// 是否初次开机
bool isFirstBoot() const;

// 设置初次开机标志
void setFirstBoot(bool firstBoot);
```

**示例：**
```cpp
if (UserSettings::instance().isFirstBoot()) {
    // 显示欢迎引导页面
    UserSettings::instance().setFirstBoot(false);
}
```

---

#### 角色列表

```cpp
// 获取所有角色
QList<RoleInfo> roleList() const;

// 设置角色列表
void setRoleList(const QList<RoleInfo> &roleList);

// 添加角色
void addRole(const RoleInfo &role);

// 移除角色（按ID）
void removeRole(int id);

// 获取单个角色（按ID）
RoleInfo getRole(int id) const;
```

**示例：**
```cpp
// 添加新角色
RoleInfo role("助手A", 1);
role.setAgentId("agent-001");
UserSettings::instance().addRole(role);

// 获取所有角色
QList<RoleInfo> roles = UserSettings::instance().roleList();

// 移除角色
UserSettings::instance().removeRole(1);
```

---

#### 版本号

```cpp
// 获取当前版本号
QString version() const;
```

**示例：**
```cpp
QString ver = UserSettings::instance().version(); // "1.0.0"
```

---

#### 文件读写

```cpp
// 从文件加载设置
bool loadFromFile(const QString &filePath);

// 保存设置到文件
bool saveToFile(const QString &filePath);
```

**示例：**
```cpp
// 从SD卡加载
UserSettings::instance().loadFromFile("D:/config/user_settings.json");

// 保存到SD卡
UserSettings::instance().saveToFile("D:/config/user_settings.json");
```

---

## RoleInfo 角色信息类

存储单个角色的详细信息。

### 构造函数

```cpp
// 默认构造
RoleInfo();

// 带名称和ID构造
RoleInfo(const QString &name, int id);
```

---

### 属性接口

#### 名称

```cpp
QString name() const;
void setName(const QString &name);
```

---

#### 编号

```cpp
int id() const;
void setId(int id);
```

---

#### 头像文件路径

```cpp
QString avatarBinPath() const;
void setAvatarBinPath(const QString &path);
```

**示例：**
```cpp
RoleInfo role;
role.setAvatarBinPath("D:/avatars/avatar_001.bin");
```

---

#### Agent ID

```cpp
QString agentId() const;
void setAgentId(const QString &agentId);
```

---

#### 声音复刻ID

```cpp
QString voiceCloneId() const;
void setVoiceCloneId(const QString &voiceCloneId);
```

---

#### 声音复刻素材路径

```cpp
QString voiceCloneMaterialPath() const;
void setVoiceCloneMaterialPath(const QString &path);
```

**示例：**
```cpp
RoleInfo role;
role.setVoiceCloneId("voice-001");
role.setVoiceCloneMaterialPath("D:/voice/material_001.wav");
```

---

## 使用流程示例

### 1. 初始化设置

```cpp
// 应用启动时
UserSettings& settings = UserSettings::instance();

// 尝试从SD卡加载配置
if (!settings.loadFromFile(sdCardPath + "/config/settings.json")) {
    // 加载失败，使用默认配置
    settings.setFirstBoot(true);
}
```

### 2. 添加新角色

```cpp
RoleInfo newRole;
newRole.setName("智能助手");
newRole.setId(1001);
newRole.setAgentId("agent-1001");
newRole.setVoiceCloneId("voice-1001");
newRole.setAvatarBinPath(sdCardPath + "/avatars/1001.bin");
newRole.setVoiceCloneMaterialPath(sdCardPath + "/voice/1001.wav");

UserSettings::instance().addRole(newRole);
UserSettings::instance().saveToFile(sdCardPath + "/config/settings.json");
```

### 3. 获取并显示角色列表

```cpp
QList<RoleInfo> roles = UserSettings::instance().roleList();
for (const RoleInfo &role : roles) {
    qDebug() << "角色:" << role.name() << "ID:" << role.id();
}
```

---

## 注意事项

1. **单例模式**：UserSettings全局唯一，通过`instance()`获取
2. **文件格式**：loadFromFile/saveToFile目前返回false（待实现），后续将支持JSON格式
3. **线程安全**：当前版本非线程安全，请在主线程调用
4. **内存管理**：RoleInfo为值类型，可自由复制