#ifndef RADIOCONFIG_H
#define RADIOCONFIG_H

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QString>
#include <QProcess>

struct SongItem {
    QString id;
    QString title;
    QString mp3;
    QString cover;

    QVariantMap toMap() const;
    static SongItem fromMap(const QVariantMap &map);
};

class RadioConfig : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList songList READ getSongList NOTIFY songListChanged)
    Q_PROPERTY(int songCount READ songCount NOTIFY songListChanged)
    Q_PROPERTY(int coverVersion READ coverVersion NOTIFY coverVersionChanged)

public:
    explicit RadioConfig(QObject *parent = nullptr);
    ~RadioConfig() override;

    Q_INVOKABLE bool loadConfig();
    Q_INVOKABLE bool saveConfig();
    Q_INVOKABLE QVariantList getSongList() const;
    Q_INVOKABLE int songCount() const;

    Q_INVOKABLE void addSong(const QString &id, const QString &title, const QString &mp3, const QString &cover);
    Q_INVOKABLE void removeSong(int index);
    Q_INVOKABLE void moveSong(int fromIndex, int toIndex);
    Q_INVOKABLE void updateSongCover(int index, const QString &cover);
    Q_INVOKABLE void reindex();
    Q_INVOKABLE QString musicDir() const;
    Q_INVOKABLE QString songDir(const QString &songId) const;
    Q_INVOKABLE bool ensureSongDir(const QString &songId);
    Q_INVOKABLE QString importSong(const QString &srcFilePath);
    Q_INVOKABLE QString importCover(const QString &srcFilePath, const QString &subDir);
    Q_INVOKABLE int coverVersion() const;
    Q_INVOKABLE void incrementCoverVersion();
    Q_INVOKABLE void setBasePath(const QString &path);
    Q_INVOKABLE QString basePath() const;

signals:
    void songListChanged();
    void configError(const QString &error);
    void coverVersionChanged();
    void importStarted();
    void importFinished(const QString &id, bool success);

private:
    QList<SongItem> m_songs;
    int m_coverVersion = 0;
    QString m_basePath;
    QString configFilePath() const;
    void migrateFromOldFormat();
    QString ffmpegPath() const;
    void onImportProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);
    QProcess *m_importProcess = nullptr;
    QString m_pendingImportId;
    QString m_pendingImportSrc;
    QString m_pendingImportDest;
};

#endif // RADIOCONFIG_H
