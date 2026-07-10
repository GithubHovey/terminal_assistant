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
    map["id"] = id;
    map["title"] = title;
    map["mp3"] = mp3;
    map["cover"] = cover;
    return map;
}

SongItem SongItem::fromMap(const QVariantMap &map)
{
    SongItem item;
    if (map.contains("id")) {
        item.id = map.value("id").toString();
        item.title = map.value("title").toString();
        item.mp3 = map.value("mp3").toString();
        item.cover = map.value("cover").toString();
    } else {
        item.title = map.value("name").toString();
        item.mp3 = map.value("filePath").toString();
        item.cover = map.value("coverPath").toString();
    }
    return item;
}

RadioConfig::RadioConfig(QObject *parent)
    : QObject(parent)
{
}

RadioConfig::~RadioConfig() = default;

QString RadioConfig::configFilePath() const
{
    return musicDir() + "/radio_config.json";
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
    bool needMigration = false;
    for (const QJsonValue &val : songsArray) {
        QJsonObject obj = val.toObject();
        QVariantMap map = obj.toVariantMap();
        if (map.contains("name") && !map.contains("id")) {
            needMigration = true;
        }
        m_songs.append(SongItem::fromMap(map));
    }

    if (needMigration) {
        migrateFromOldFormat();
    }

    emit songListChanged();
    return true;
}

void RadioConfig::migrateFromOldFormat()
{
    QString baseDir = musicDir();

    for (int i = 0; i < m_songs.size(); ++i) {
        QString newId = QString("%1").arg(i + 1, 3, 10, QChar('0'));
        QString oldFilePath = m_songs[i].mp3;
        QString oldFullPath = baseDir + "/" + oldFilePath;
        QString subDir = oldFilePath.left(oldFilePath.indexOf("/"));
        QString oldDir = baseDir + "/" + subDir;
        QString newDir = baseDir + "/" + newId;

        if (QFile::exists(oldFullPath)) {
            if (subDir != newId) {
                QDir(baseDir).rename(subDir, "_migrate_" + subDir);
                QDir(baseDir).rename("_migrate_" + subDir, newId);
            }
            QDir dir(baseDir + "/" + newId);
            for (const QString &f : dir.entryList(QDir::Files)) {
                if (f.endsWith(".mp3", Qt::CaseInsensitive) && f != newId + ".mp3") {
                    QFile::rename(baseDir + "/" + newId + "/" + f, baseDir + "/" + newId + "/" + newId + ".mp3");
                    break;
                }
            }
        }

        m_songs[i].id = newId;
        m_songs[i].mp3 = newId + "/" + newId + ".mp3";
        if (!m_songs[i].cover.isEmpty()) {
            m_songs[i].cover = newId + "/cover.bin";
        }
    }

    saveConfig();
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
        obj["id"] = song.id;
        obj["title"] = song.title;
        obj["mp3"] = song.mp3;
        obj["cover"] = song.cover;
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

void RadioConfig::addSong(const QString &id, const QString &title, const QString &mp3, const QString &cover)
{
    SongItem item;
    item.id = id;
    item.title = title;
    item.mp3 = mp3;
    item.cover = cover;
    m_songs.append(item);
    emit songListChanged();
}

void RadioConfig::removeSong(int index)
{
    if (index < 0 || index >= m_songs.size()) {
        return;
    }

    QString baseDir = musicDir();
    QString removedId = m_songs[index].id;
    QString dirPath = baseDir + "/" + removedId;
    
    QDir dir(dirPath);
    if (dir.exists()) {
        for (const QString &f : dir.entryList(QDir::Files)) {
            QFile::remove(dirPath + "/" + f);
        }
        dir.removeRecursively();
    }

    m_songs.removeAt(index);
    reindex();
    emit songListChanged();
}

void RadioConfig::updateSongCover(int index, const QString &cover)
{
    if (index < 0 || index >= m_songs.size()) {
        return;
    }
    m_songs[index].cover = cover;
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
    QString baseDir = musicDir();
    QList<QString> oldIds;
    for (const SongItem &song : m_songs) {
        oldIds.append(song.id);
    }

    bool needRename = false;
    for (int i = 0; i < m_songs.size(); ++i) {
        QString newId = QString("%1").arg(i + 1, 3, 10, QChar('0'));
        if (oldIds[i] != newId) {
            needRename = true;
            break;
        }
    }

    for (int i = 0; i < m_songs.size(); ++i) {
        QString newId = QString("%1").arg(i + 1, 3, 10, QChar('0'));
        m_songs[i].id = newId;
        m_songs[i].mp3 = newId + "/" + newId + ".mp3";
        if (!m_songs[i].cover.isEmpty()) {
            m_songs[i].cover = newId + "/cover.bin";
        }
    }

    if (!needRename) {
        return;
    }

    for (int i = 0; i < oldIds.size(); ++i) {
        QString oldPath = baseDir + "/" + oldIds[i];
        QString tmpPath = baseDir + "/_tmp_" + oldIds[i];
        if (QDir(oldPath).exists()) {
            QDir().mkpath(tmpPath);
            for (const QString &f : QDir(oldPath).entryList(QDir::Files)) {
                QFile::copy(oldPath + "/" + f, tmpPath + "/" + f);
            }
            QDir(oldPath).removeRecursively();
        }
    }

    for (int i = 0; i < oldIds.size(); ++i) {
        QString newId = QString("%1").arg(i + 1, 3, 10, QChar('0'));
        QString tmpName = "_tmp_" + oldIds[i];
        QString tmpPath = baseDir + "/" + tmpName;
        QString newPath = baseDir + "/" + newId;
        if (QDir(tmpPath).exists()) {
            QDir(newPath).removeRecursively();
            QDir().mkpath(newPath);
            for (const QString &f : QDir(tmpPath).entryList(QDir::Files)) {
                QFile::copy(tmpPath + "/" + f, newPath + "/" + f);
            }
            QDir(tmpPath).removeRecursively();
        }
    }

    for (int i = 0; i < m_songs.size(); ++i) {
        QString newId = m_songs[i].id;
        QDir dir(baseDir + "/" + newId);
        bool foundMp3 = false;
        for (const QString &f : dir.entryList(QDir::Files)) {
            if (f.endsWith(".mp3", Qt::CaseInsensitive) && f != newId + ".mp3") {
                QString oldPath = baseDir + "/" + newId + "/" + f;
                QString newPath = baseDir + "/" + newId + "/" + newId + ".mp3";
                if (!QFile::rename(oldPath, newPath)) {
                    emit configError("重命名文件失败: " + oldPath + " -> " + newPath);
                }
                foundMp3 = true;
                break;
            } else if (f == newId + ".mp3") {
                foundMp3 = true;
                break;
            }
        }
        if (!foundMp3) {
            emit configError("未找到MP3文件: " + baseDir + "/" + newId);
        }
    }
}

QString RadioConfig::musicDir() const
{
    QString dir = QCoreApplication::applicationDirPath() + "/music";
    QDir().mkpath(dir);
    return dir;
}

QString RadioConfig::songDir(const QString &songId) const
{
    if (songId.isEmpty()) {
        return QString();
    }
    return musicDir() + "/" + songId;
}

bool RadioConfig::ensureSongDir(const QString &songId)
{
    if (songId.isEmpty()) {
        return false;
    }
    QString dir = songDir(songId);
    if (!QDir().mkpath(dir)) {
        emit configError("Failed to create song directory: " + dir);
        return false;
    }
    return true;
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

    QString baseDir = musicDir();
    int nextNum = m_songs.size() + 1;
    for (int i = 1; i <= 999; ++i) {
        QString subDir = QString("%1").arg(i, 3, 10, QChar('0'));
        if (!QDir(baseDir).exists(subDir)) {
            nextNum = i;
            break;
        }
    }
    QString id = QString("%1").arg(nextNum, 3, 10, QChar('0'));
    QString destDir = baseDir + "/" + id;
    QDir().mkpath(destDir);

    QString mp3Name = id + ".mp3";
    QString destPath = destDir + "/" + mp3Name;

    m_pendingImportId = id;
    m_pendingImportSrc = srcFilePath;
    m_pendingImportDest = destPath;

    QString ffmpeg = ffmpegPath();
    if (ffmpeg.isEmpty() || !QFileInfo::exists(ffmpeg)) {
        if (!QFile::copy(srcFilePath, destPath)) {
            emit configError("复制文件失败: " + srcFilePath + " -> " + destPath);
            return QString();
        }
        emit importFinished(id, true);
        return id;
    }

    if (m_importProcess) {
        m_importProcess->deleteLater();
        m_importProcess = nullptr;
    }
    m_importProcess = new QProcess(this);
    m_importProcess->setProcessChannelMode(QProcess::SeparateChannels);
    connect(m_importProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, &RadioConfig::onImportProcessFinished);

    QString tmpPath = destDir + "/_tmp.mp3";
    QStringList args;
    args << "-i" << srcFilePath << "-y" << "-ar" << "16000" << "-ac" << "1"
         << "-acodec" << "libmp3lame" << "-b:a" << "48k" << tmpPath;
    m_importProcess->start(ffmpeg, args);

    if (!m_importProcess->waitForStarted(5000)) {
        emit configError("ffmpeg 启动失败: " + m_importProcess->errorString());
        m_importProcess->deleteLater();
        m_importProcess = nullptr;
        if (!QFile::copy(srcFilePath, destPath)) {
            emit configError("复制文件失败: " + srcFilePath + " -> " + destPath);
            return QString();
        }
        emit importFinished(id, true);
        return id;
    }

    emit importStarted();
    return id;
}

QString RadioConfig::importCover(const QString &srcFilePath, const QString &subDir)
{
    if (srcFilePath.isEmpty() || subDir.isEmpty()) {
        return QString();
    }

    QFileInfo fi(srcFilePath);
    if (!fi.exists()) {
        emit configError("封面文件不存在: " + srcFilePath);
        return QString();
    }

    QString destDir = musicDir() + "/" + subDir;
    QDir().mkpath(destDir);

    QString fileName = "cover.bin";
    QString destPath = destDir + "/" + fileName;

    QFile::remove(destPath);
    if (!QFile::copy(srcFilePath, destPath)) {
        emit configError("复制封面失败: " + srcFilePath + " -> " + destPath);
        return QString();
    }

    return subDir + "/" + fileName;
}

int RadioConfig::coverVersion() const
{
    return m_coverVersion;
}

void RadioConfig::incrementCoverVersion()
{
    m_coverVersion++;
    emit coverVersionChanged();
}

QString RadioConfig::ffmpegPath() const
{
    return QCoreApplication::applicationDirPath() + "/python/ffmpeg.exe";
}

void RadioConfig::onImportProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    Q_UNUSED(exitStatus);
    QString id = m_pendingImportId;
    QString destPath = m_pendingImportDest;
    QString destDir = destPath.left(destPath.lastIndexOf("/"));
    QString tmpPath = destDir + "/_tmp.mp3";

    bool success = false;
    if (exitCode == 0 && QFile::exists(tmpPath)) {
        QFile::remove(destPath);
        success = QFile::rename(tmpPath, destPath);
        if (!success) {
            emit configError("转码文件重命名失败: " + tmpPath + " -> " + destPath);
        }
    } else {
        QFile::remove(tmpPath);
        if (exitCode != 0) {
            QString err = m_importProcess ? QString::fromUtf8(m_importProcess->readAllStandardError()).trimmed() : "";
            emit configError("ffmpeg 转码失败 (exit=" + QString::number(exitCode) + "): " + err);
        }
    }

    if (!success) {
        success = QFile::copy(m_pendingImportSrc, destPath);
        if (!success) {
            emit configError("转码失败且复制回退也失败: " + m_pendingImportSrc + " -> " + destPath);
        }
    }

    if (m_importProcess) {
        m_importProcess->deleteLater();
        m_importProcess = nullptr;
    }
    m_pendingImportId.clear();
    m_pendingImportSrc.clear();
    m_pendingImportDest.clear();

    emit importFinished(id, success);
}
