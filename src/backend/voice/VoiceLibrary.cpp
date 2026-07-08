#include "VoiceLibrary.h"
#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QCoreApplication>
#include <QDateTime>
#include <QUrl>
#include "src/backend/logger/Logger.h"

QVariantMap VoiceItem::toMap() const
{
    QVariantMap map;
    map["voiceId"] = voiceId;
    map["name"] = name;
    map["characterName"] = characterName;
    map["createdAt"] = createdAt;
    return map;
}

VoiceItem VoiceItem::fromMap(const QVariantMap &map)
{
    VoiceItem item;
    item.voiceId = map.value("voiceId").toString();
    item.name = map.value("name").toString();
    item.characterName = map.value("characterName").toString();
    item.createdAt = map.value("createdAt").toString();
    return item;
}

VoiceLibrary::VoiceLibrary(QObject *parent)
    : QObject(parent)
{
    loadCloudConfig();
}

VoiceLibrary::~VoiceLibrary() = default;

QString VoiceLibrary::voiceLibraryDir() const
{
    QString dir = QCoreApplication::applicationDirPath() + "/voice_clone";
    QDir().mkpath(dir);
    return dir;
}

QString VoiceLibrary::materialsDir() const
{
    QString dir = QCoreApplication::applicationDirPath() + "/materials";
    QDir().mkpath(dir);
    return dir;
}

QString VoiceLibrary::optionsFilePath() const
{
    return materialsDir() + "/option.json";
}

QString VoiceLibrary::configFilePath() const
{
    return voiceLibraryDir() + "/voice_library.json";
}

bool VoiceLibrary::loadConfig()
{
    QString path = configFilePath();
    QFile file(path);
    if (!file.exists()) {
        return true;
    }

    if (!file.open(QIODevice::ReadOnly)) {
        Logger::instance().logError("Failed to open voice library config: " + path);
        return false;
    }

    QByteArray data = file.readAll();
    file.close();

    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(data, &error);
    if (error.error != QJsonParseError::NoError) {
        Logger::instance().logError("Voice library config parse error: " + error.errorString());
        return false;
    }

    QJsonObject root = doc.object();
    QJsonArray voicesArray = root.value("voices").toArray();

    m_voices.clear();
    for (const QJsonValue &val : voicesArray) {
        QJsonObject obj = val.toObject();
        QVariantMap map = obj.toVariantMap();
        m_voices.append(VoiceItem::fromMap(map));
    }

    Logger::instance().logInfo("Loaded " + QString::number(m_voices.size()) + " voices from library");
    emit voiceListChanged();
    return true;
}

bool VoiceLibrary::saveConfig()
{
    QString path = configFilePath();
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly)) {
        Logger::instance().logError("Failed to write voice library config: " + path);
        return false;
    }

    QJsonArray voicesArray;
    for (const VoiceItem &voice : m_voices) {
        voicesArray.append(QJsonObject::fromVariantMap(voice.toMap()));
    }

    QJsonObject root;
    root["voices"] = voicesArray;

    QJsonDocument doc(root);
    file.write(doc.toJson(QJsonDocument::Indented));
    file.close();
    return true;
}

QVariantList VoiceLibrary::getVoiceList() const
{
    QVariantList list;
    for (const VoiceItem &voice : m_voices) {
        list.append(voice.toMap());
    }
    return list;
}

int VoiceLibrary::voiceCount() const
{
    return m_voices.size();
}

void VoiceLibrary::addVoice(const QString &voiceId, const QString &name, const QString &characterName)
{
    if (voiceId.isEmpty()) {
        return;
    }

    VoiceItem item;
    item.voiceId = voiceId;
    item.name = name;
    item.characterName = characterName;
    item.createdAt = QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm:ss");

    m_voices.append(item);
    saveConfig();
    Logger::instance().logInfo("Added voice: " + name + " (" + voiceId + ")");
    emit voiceListChanged();
}

void VoiceLibrary::removeVoice(int index)
{
    if (index < 0 || index >= m_voices.size()) {
        return;
    }

    QString voiceId = m_voices[index].voiceId;
    
    QString dir = voiceDir(voiceId);
    if (QDir(dir).exists()) {
        QDir(dir).removeRecursively();
    }

    m_voices.removeAt(index);
    saveConfig();
    Logger::instance().logInfo("Removed voice: " + voiceId);
    emit voiceListChanged();
}

QString VoiceLibrary::voiceDir(const QString &characterName) const
{
    if (characterName.isEmpty()) {
        return QString();
    }
    return voiceLibraryDir() + "/" + characterName;
}

bool VoiceLibrary::ensureVoiceDir(const QString &characterName)
{
    if (characterName.isEmpty()) {
        return false;
    }
    QString dir = voiceDir(characterName);
    if (!QDir().mkpath(dir)) {
        Logger::instance().logError("Failed to create voice directory: " + dir);
        return false;
    }
    return true;
}

QString VoiceLibrary::importVoiceMaterial(const QString &srcPath, const QString &characterName)
{
    if (srcPath.isEmpty() || characterName.isEmpty()) {
        return QString();
    }

    QString localPath = srcPath;
    if (localPath.startsWith("file:///")) {
        localPath = QUrl(localPath).toLocalFile();
    }

    QFileInfo fi(localPath);
    if (!fi.exists()) {
        emit importError("Source file does not exist: " + localPath);
        return QString();
    }

    if (!ensureVoiceDir(characterName)) {
        return QString();
    }

    QString ext = fi.suffix().toLower();
    QString dest = voiceDir(characterName) + "/voice_demo." + ext;
    if (QFile::exists(dest)) {
        QFile::remove(dest);
    }

    if (!QFile::copy(localPath, dest)) {
        emit importError("Failed to copy voice material: " + localPath);
        return QString();
    }

    Logger::instance().logInfo("Imported voice material for " + characterName + ": " + dest);
    return dest;
}

QString VoiceLibrary::voiceMaterialPath(const QString &characterName) const
{
    if (characterName.isEmpty()) {
        return QString();
    }
    QString dir = voiceDir(characterName);
    QStringList exts = {"wav", "mp3", "flac"};
    for (const QString &ext : exts) {
        QString path = dir + "/voice_demo." + ext;
        if (QFile::exists(path)) {
            return path;
        }
    }
    return QString();
}

QVariantList VoiceLibrary::getCharacterOptions() const
{
    QVariantList list;
    QString path = optionsFilePath();
    QFile file(path);
    
    if (!file.exists()) {
        Logger::instance().logWarning("Options file not found: " + path);
        return list;
    }

    if (!file.open(QIODevice::ReadOnly)) {
        Logger::instance().logError("Failed to open options file: " + path);
        return list;
    }

    QByteArray data = file.readAll();
    file.close();

    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(data, &error);
    if (error.error != QJsonParseError::NoError) {
        Logger::instance().logError("Options file parse error: " + error.errorString());
        return list;
    }

    QJsonObject root = doc.object();
    QJsonArray charactersArray = root.value("characters").toArray();

    for (const QJsonValue &val : charactersArray) {
        QJsonObject obj = val.toObject();
        QVariantMap map;
        map["englishName"] = obj.value("englishName").toString();
        map["chineseName"] = obj.value("chineseName").toString();
        list.append(map);
    }

    return list;
}

QString VoiceLibrary::cloudConfigFilePath() const
{
    return voiceLibraryDir() + "/cloud_voices.json";
}

bool VoiceLibrary::loadCloudConfig()
{
    QString path = cloudConfigFilePath();
    QFile file(path);
    if (!file.exists()) {
        return true;
    }

    if (!file.open(QIODevice::ReadOnly)) {
        Logger::instance().logError("Failed to open cloud voices config: " + path);
        return false;
    }

    QByteArray data = file.readAll();
    file.close();

    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(data, &error);
    if (error.error != QJsonParseError::NoError) {
        Logger::instance().logError("Cloud voices config parse error: " + error.errorString());
        return false;
    }

    QJsonArray arr = doc.array();
    m_cloudVoices.clear();
    for (const QJsonValue &val : arr) {
        m_cloudVoices.append(val.toObject().toVariantMap());
    }

    Logger::instance().logInfo("Loaded " + QString::number(m_cloudVoices.size()) + " cloud voices");
    emit cloudVoiceListChanged();
    return true;
}

bool VoiceLibrary::saveCloudConfig()
{
    QString path = cloudConfigFilePath();
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly)) {
        Logger::instance().logError("Failed to write cloud voices config: " + path);
        return false;
    }

    QJsonArray arr;
    for (const QVariant &v : m_cloudVoices) {
        arr.append(QJsonObject::fromVariantMap(v.toMap()));
    }

    QJsonDocument doc(arr);
    file.write(doc.toJson(QJsonDocument::Indented));
    file.close();
    return true;
}

QVariantList VoiceLibrary::getCloudVoiceList() const
{
    return m_cloudVoices;
}

void VoiceLibrary::updateCloudVoices(const QString &jsonString)
{
    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(jsonString.toUtf8(), &error);
    if (error.error != QJsonParseError::NoError) {
        Logger::instance().logError("Cloud voices JSON parse error: " + error.errorString());
        return;
    }

    QJsonArray arr = doc.array();
    m_cloudVoices.clear();
    for (const QJsonValue &val : arr) {
        m_cloudVoices.append(val.toObject().toVariantMap());
    }

    saveCloudConfig();
    Logger::instance().logInfo("Updated " + QString::number(m_cloudVoices.size()) + " cloud voices");
    emit cloudVoiceListChanged();
}

int VoiceLibrary::cloudVoiceCount() const
{
    return m_cloudVoices.size();
}
