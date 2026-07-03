#ifndef RADIOCONFIG_H
#define RADIOCONFIG_H

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QString>

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
    Q_INVOKABLE QString importSong(const QString &srcFilePath);
    Q_INVOKABLE QString importCover(const QString &srcFilePath, const QString &subDir);

signals:
    void songListChanged();
    void configError(const QString &error);

private:
    QList<SongItem> m_songs;
    QString configFilePath() const;
    void migrateFromOldFormat();
};

#endif // RADIOCONFIG_H
