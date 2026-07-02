#include "RadioConfig.h"
#include <QFile>
#include <QDir>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QStandardPaths>
#include <QCoreApplication>
#include <QFileInfo>

QVariantMap SongItem::toMap() const
{
    QVariantMap map;
    map["index"] = index;
    map["name"] = name;
    map["filePath"] = filePath;
    map["coverPath"] = coverPath;
    return map;
}

SongItem SongItem::fromMap(const QVariantMap &map)
{
    SongItem item;
    item.index = map.value("index").toInt();
    item.name = map.value("name").toString();
    item.filePath = map.value("filePath").toString();
    item.coverPath = map.value("coverPath").toString();
    return item;
}

RadioConfig::RadioConfig(QObject *parent)
    : QObject(parent)
{
}

RadioConfig::~RadioConfig() = default;

QString RadioConfig::configFilePath() const
{
    QString configDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(configDir);
    return configDir + "/radio_config.json";
}

bool RadioConfig::loadConfig()
{
    QString path = configFilePath();
    QFile file(path);
    if (!file.exists()) {
        return true;
    }

    if (!file.open(QIODevice::ReadOnly)) {
        emit configError("无法打开配置文件: " + path);
        return false;
    }

    QByteArray data = file.readAll();
    file.close();

    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(data, &error);
    if (error.error != QJsonParseError::NoError) {
        emit configError("配置文件解析失败: " + error.errorString());
        return false;
    }

    QJsonObject root = doc.object();
    QJsonArray songsArray = root.value("songs").toArray();

    m_songs.clear();
    for (const QJsonValue &val : songsArray) {
        QJsonObject obj = val.toObject();
        QVariantMap map = obj.toVariantMap();
        m_songs.append(SongItem::fromMap(map));
    }

    reindex();
    emit songListChanged();
    return true;
}

bool RadioConfig::saveConfig()
{
    QString path = configFilePath();
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly)) {
        emit configError("无法写入配置文件: " + path);
        return false;
    }

    QJsonArray songsArray;
    for (const SongItem &song : m_songs) {
        QJsonObject obj;
        obj["index"] = song.index;
        obj["name"] = song.name;
        obj["filePath"] = song.filePath;
        obj["coverPath"] = song.coverPath;
        songsArray.append(obj);
    }

    QJsonObject root;
    root["songs"] = songsArray;

    QJsonDocument doc(root);
    file.write(doc.toJson(QJsonDocument::Indented));
    file.close();
    return true;
}

QVariantList RadioConfig::getSongList() const
{
    QVariantList list;
    for (const SongItem &song : m_songs) {
        list.append(song.toMap());
    }
    return list;
}

int RadioConfig::songCount() const
{
    return m_songs.size();
}

void RadioConfig::addSong(const QString &name, const QString &filePath, const QString &coverPath)
{
    SongItem item;
    item.index = m_songs.size() + 1;
    item.name = name;
    item.filePath = filePath;
    item.coverPath = coverPath;
    m_songs.append(item);
    emit songListChanged();
}

void RadioConfig::removeSong(int index)
{
    if (index < 0 || index >= m_songs.size()) {
        return;
    }
    m_songs.removeAt(index);
    reindex();
    emit songListChanged();
}

void RadioConfig::moveSong(int fromIndex, int toIndex)
{
    if (fromIndex < 0 || fromIndex >= m_songs.size()) {
        return;
    }
    if (toIndex < 0 || toIndex >= m_songs.size()) {
        return;
    }
    if (fromIndex == toIndex) {
        return;
    }

    SongItem item = m_songs.takeAt(fromIndex);
    m_songs.insert(toIndex, item);
    reindex();
    emit songListChanged();
}

void RadioConfig::reindex()
{
    for (int i = 0; i < m_songs.size(); ++i) {
        m_songs[i].index = i + 1;
    }
}

QString RadioConfig::songsDir() const
{
    QString dir = QCoreApplication::applicationDirPath() + "/songs";
    QDir().mkpath(dir);
    return dir;
}

QString RadioConfig::importSong(const QString &srcFilePath)
{
    if (srcFilePath.isEmpty()) {
        return QString();
    }

    QFileInfo fi(srcFilePath);
    if (!fi.exists()) {
        emit configError("源文件不存在: " + srcFilePath);
        return QString();
    }

    QString destDir = songsDir();
    QString baseName = fi.completeBaseName();
    QString suffix = fi.suffix();
    QString fileName = baseName + "." + suffix;
    QString destPath = destDir + "/" + fileName;

    int counter = 1;
    while (QFile::exists(destPath)) {
        fileName = baseName + "_" + QString::number(counter) + "." + suffix;
        destPath = destDir + "/" + fileName;
        ++counter;
    }

    if (!QFile::copy(srcFilePath, destPath)) {
        emit configError("复制文件失败: " + srcFilePath + " -> " + destPath);
        return QString();
    }

    return fileName;
}
