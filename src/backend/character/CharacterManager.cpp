#include "CharacterManager.h"
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QCoreApplication>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include "src/backend/logger/Logger.h"

CharacterManager::CharacterManager(QObject *parent)
    : QObject(parent)
{
}

CharacterManager::~CharacterManager() = default;

QString CharacterManager::characterDir() const
{
    QString dir = QCoreApplication::applicationDirPath() + "/character";
    QDir().mkpath(dir);
    return dir;
}

QString CharacterManager::configFilePath() const
{
    return characterDir() + "/character_config.json";
}

QString CharacterManager::roleDir(const QString &name) const
{
    if (name.isEmpty()) {
        return QString();
    }
    return characterDir() + "/" + name;
}

bool CharacterManager::ensureRoleDir(const QString &name)
{
    if (name.isEmpty()) {
        return false;
    }
    QString dir = roleDir(name);
    if (!QDir().mkpath(dir)) {
        Logger::instance().logError("Failed to create character directory: " + dir);
        return false;
    }
    return true;
}

int CharacterManager::nextId() const
{
    int maxId = 0;
    for (const RoleInfo &role : m_roles) {
        if (role.id() > maxId) {
            maxId = role.id();
        }
    }
    return maxId + 1;
}

bool CharacterManager::loadConfig()
{
    QString path = configFilePath();
    QFile file(path);
    if (!file.exists()) {
        return true;
    }

    if (!file.open(QIODevice::ReadOnly)) {
        Logger::instance().logError("Failed to open character config: " + path);
        return false;
    }

    QByteArray data = file.readAll();
    file.close();

    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(data, &error);
    if (error.error != QJsonParseError::NoError) {
        Logger::instance().logError("Character config parse error: " + error.errorString());
        return false;
    }

    QJsonObject root = doc.object();
    QJsonArray rolesArray = root.value("roles").toArray();

    m_roles.clear();
    for (const QJsonValue &val : rolesArray) {
        QJsonObject obj = val.toObject();
        QVariantMap map = obj.toVariantMap();
        m_roles.append(RoleInfo::fromMap(map));
    }

    Logger::instance().logInfo("Loaded " + QString::number(m_roles.size()) + " roles from config");
    emit roleListChanged();
    return true;
}

bool CharacterManager::saveConfig()
{
    QString path = configFilePath();
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly)) {
        Logger::instance().logError("Failed to write character config: " + path);
        return false;
    }

    QJsonArray rolesArray;
    for (const RoleInfo &role : m_roles) {
        rolesArray.append(QJsonObject::fromVariantMap(role.toMap()));
    }

    QJsonObject root;
    root["roles"] = rolesArray;

    QJsonDocument doc(root);
    file.write(doc.toJson(QJsonDocument::Indented));
    file.close();
    return true;
}

QVariantList CharacterManager::getRoleList() const
{
    QVariantList list;
    for (const RoleInfo &role : m_roles) {
        list.append(role.toMap());
    }
    return list;
}

int CharacterManager::roleCount() const
{
    return m_roles.size();
}

void CharacterManager::addRole(const QString &name)
{
    if (name.trimmed().isEmpty()) {
        return;
    }

    RoleInfo role(name.trimmed(), nextId());
    m_roles.append(role);
    ensureRoleDir(name.trimmed());
    saveConfig();
    emit roleListChanged();
    Logger::instance().logInfo("Added role: " + name);
}

void CharacterManager::removeRole(int index)
{
    if (index < 0 || index >= m_roles.size()) {
        return;
    }

    RoleInfo role = m_roles.at(index);
    QString name = role.name();

    if (!name.isEmpty()) {
        QString dir = roleDir(name);
        QDir d(dir);
        if (d.exists()) {
            d.removeRecursively();
            Logger::instance().logInfo("Removed character directory: " + dir);
        }
    }

    m_roles.removeAt(index);
    saveConfig();
    emit roleListChanged();
    Logger::instance().logInfo("Removed role: " + role.name());
}

void CharacterManager::updateRoleName(int index, const QString &name)
{
    if (index < 0 || index >= m_roles.size()) {
        return;
    }
    m_roles[index].setName(name);
    saveConfig();
}

void CharacterManager::updateRoleEnglishName(int index, const QString &englishName)
{
    if (index < 0 || index >= m_roles.size()) {
        return;
    }
    
    QString oldEnglishName = m_roles[index].englishName();
    QString newEnglishName = englishName.toUpper();
    
    // 限制英文名最大长度为8个字符
    if (newEnglishName.length() > 8) {
        newEnglishName = newEnglishName.left(8);
    }
    
    // 如果英文名没有变化，直接返回
    if (oldEnglishName == newEnglishName) {
        return;
    }
    
    // 如果旧英文名不为空，重命名相关文件
    if (!oldEnglishName.isEmpty()) {
        QString dir = roleDir(m_roles[index].name());
        QDir dirObj(dir);
        
        if (dirObj.exists()) {
            // 重命名 PNG 文件
            QString oldPngPath = dir + "/" + oldEnglishName + ".png";
            QString newPngPath = dir + "/" + newEnglishName + ".png";
            if (QFile::exists(oldPngPath)) {
                if (QFile::exists(newPngPath)) {
                    QFile::remove(newPngPath);
                }
                if (QFile::rename(oldPngPath, newPngPath)) {
                    Logger::instance().logInfo("重命名头像: " + oldPngPath + " -> " + newPngPath);
                } else {
                    Logger::instance().logError("重命名头像失败: " + oldPngPath);
                }
            }
            
            // 重命名 BIN 文件
            QString oldBinPath = dir + "/" + oldEnglishName + ".bin";
            QString newBinPath = dir + "/" + newEnglishName + ".bin";
            if (QFile::exists(oldBinPath)) {
                if (QFile::exists(newBinPath)) {
                    QFile::remove(newBinPath);
                }
                if (QFile::rename(oldBinPath, newBinPath)) {
                    Logger::instance().logInfo("重命名BIN: " + oldBinPath + " -> " + newBinPath);
                } else {
                    Logger::instance().logError("重命名BIN失败: " + oldBinPath);
                }
            }
        }
    }
    
    m_roles[index].setEnglishName(newEnglishName);
    ensureRoleDir(m_roles[index].name());
    saveConfig();
}

void CharacterManager::updateRoleAgentId(int index, const QString &agentId)
{
    if (index < 0 || index >= m_roles.size()) {
        return;
    }
    m_roles[index].setAgentId(agentId);
    saveConfig();
}

void CharacterManager::updateRoleAgentUrl(int index, const QString &agentUrl)
{
    if (index < 0 || index >= m_roles.size()) {
        return;
    }
    m_roles[index].setAgentUrl(agentUrl);
    saveConfig();
}

void CharacterManager::updateRolePrompt(int index, const QString &prompt)
{
    if (index < 0 || index >= m_roles.size()) {
        return;
    }
    m_roles[index].setPrompt(prompt);
    saveConfig();
}

QString CharacterManager::importChatBg(const QString &srcFilePath, const QString &name)
{
    if (srcFilePath.isEmpty() || name.isEmpty()) {
        return QString();
    }

    QFileInfo fi(srcFilePath);
    if (!fi.exists()) {
        emit importError("Source file does not exist: " + srcFilePath);
        return QString();
    }

    if (!ensureRoleDir(name)) {
        return QString();
    }

    QString dest = roleDir(name) + "/background.png";
    if (QFile::exists(dest)) {
        QFile::remove(dest);
    }

    if (!QFile::copy(srcFilePath, dest)) {
        emit importError("Failed to copy chat background: " + srcFilePath);
        return QString();
    }

    Logger::instance().logInfo("Imported chat background for " + name + ": " + dest);
    return dest;
}

bool CharacterManager::removeChatBg(const QString &name)
{
    if (name.isEmpty()) {
        return false;
    }

    bool success = true;
    
    // Remove PNG file
    QString pngPath = chatBgPath(name);
    if (QFile::exists(pngPath)) {
        if (!QFile::remove(pngPath)) {
            emit importError("Failed to remove chat background PNG: " + pngPath);
            success = false;
        } else {
            Logger::instance().logInfo("Removed chat background PNG for " + name);
        }
    }
    
    // Remove BIN file
    QString binPath = chatBgBinPath(name);
    if (QFile::exists(binPath)) {
        if (!QFile::remove(binPath)) {
            emit importError("Failed to remove chat background BIN: " + binPath);
            success = false;
        } else {
            Logger::instance().logInfo("Removed chat background BIN for " + name);
        }
    }
    
    if (success) {
        incrementChatBgVersion();
    }
    
    return success;
}

QString CharacterManager::importVoiceMaterial(const QString &srcFilePath, const QString &name)
{
    if (srcFilePath.isEmpty() || name.isEmpty()) {
        return QString();
    }

    QFileInfo fi(srcFilePath);
    if (!fi.exists()) {
        emit importError("Source file does not exist: " + srcFilePath);
        return QString();
    }

    if (!ensureRoleDir(name)) {
        return QString();
    }

    QString ext = fi.suffix().toLower();
    QString dest = roleDir(name) + "/voice_clone." + ext;
    if (QFile::exists(dest)) {
        QFile::remove(dest);
    }

    if (!QFile::copy(srcFilePath, dest)) {
        emit importError("Failed to copy voice material: " + srcFilePath);
        return QString();
    }

    Logger::instance().logInfo("Imported voice material for " + name + ": " + dest);
    return dest;
}

QString CharacterManager::importPreviewAudio(const QString &srcFilePath, const QString &name)
{
    if (srcFilePath.isEmpty() || name.isEmpty()) {
        return QString();
    }

    QFileInfo fi(srcFilePath);
    if (!fi.exists()) {
        emit importError("Source file does not exist: " + srcFilePath);
        return QString();
    }

    if (!ensureRoleDir(name)) {
        return QString();
    }

    QString dest = roleDir(name) + "/preview.wav";
    if (QFile::exists(dest)) {
        QFile::remove(dest);
    }

    if (!QFile::copy(srcFilePath, dest)) {
        emit importError("Failed to copy preview audio: " + srcFilePath);
        return QString();
    }

    Logger::instance().logInfo("Imported preview audio for " + name + ": " + dest);
    return dest;
}

QString CharacterManager::avatarPath(const QString &name) const
{
    if (name.isEmpty()) {
        return QString();
    }
    QString englishName = findEnglishNameByName(name);
    if (englishName.isEmpty()) {
        return QString();
    }
    QString path = roleDir(name) + "/" + englishName + ".png";
    return QFile::exists(path) ? path : QString();
}

QString CharacterManager::avatarBinPath(const QString &name) const
{
    if (name.isEmpty()) {
        return QString();
    }
    QString englishName = findEnglishNameByName(name);
    if (englishName.isEmpty()) {
        return QString();
    }
    QString path = roleDir(name) + "/" + englishName + ".bin";
    return QFile::exists(path) ? path : QString();
}

QString CharacterManager::chatBgPath(const QString &name) const
{
    if (name.isEmpty()) {
        return QString();
    }
    QString path = roleDir(name) + "/background.png";
    return QFile::exists(path) ? path : QString();
}

QString CharacterManager::chatBgBinPath(const QString &name) const
{
    if (name.isEmpty()) {
        return QString();
    }
    QString path = roleDir(name) + "/background.bin";
    return QFile::exists(path) ? path : QString();
}

bool CharacterManager::chatBgExists(const QString &name) const
{
    if (name.isEmpty()) {
        return false;
    }
    QString path = roleDir(name) + "/background.png";
    return QFile::exists(path);
}

QString CharacterManager::voiceMaterialPath(const QString &name) const
{
    if (name.isEmpty()) {
        return QString();
    }
    QString path = roleDir(name) + "/voice_clone.wav";
    return QFile::exists(path) ? path : QString();
}

QString CharacterManager::previewAudioPath(const QString &name) const
{
    if (name.isEmpty()) {
        return QString();
    }
    QString path = roleDir(name) + "/preview.wav";
    return QFile::exists(path) ? path : QString();
}

QString CharacterManager::findEnglishNameByName(const QString &name) const
{
    for (const RoleInfo &role : m_roles) {
        if (role.name() == name) {
            return role.englishName();
        }
    }
    return QString();
}

int CharacterManager::avatarVersion() const
{
    return m_avatarVersion;
}

void CharacterManager::incrementAvatarVersion()
{
    m_avatarVersion++;
    emit avatarVersionChanged();
}

int CharacterManager::chatBgVersion() const
{
    return m_chatBgVersion;
}

void CharacterManager::incrementChatBgVersion()
{
    m_chatBgVersion++;
    emit chatBgVersionChanged();
}
