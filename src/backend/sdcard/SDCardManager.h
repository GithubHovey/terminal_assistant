#ifndef SDCARDMANAGER_H
#define SDCARDMANAGER_H

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QTimer>
#include <QFutureWatcher>

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
    Q_INVOKABLE void applyResources();

public slots:
    void onDeviceArrived(const QString &driveLetter);
    void onDeviceRemoved(const QString &driveLetter);

signals:
    void connectedChanged();
    void driveListChanged();
    void errorOccurred(const QString &error);
    void applyFinished(bool success, const QString &message);

private slots:
    void checkConnection();

private:
    void startConnectionMonitor();
    void stopConnectionMonitor();
    QVariantList scanRemovableDrives();
    static QString formatSizeStatic(qint64 bytes);
    static bool copyDirectoryRecursive(const QString &srcPath, const QString &dstPath);

    QTimer *m_connTimer;
    QTimer *m_arrivalDebounceTimer;
    QFutureWatcher<bool> *m_applyWatcher;
    bool m_connected;
    QString m_driveLetter;
    qint64 m_cardSize;
    qint64 m_freeSpace;
    QVariantList m_availableDrives;
};

#endif // SDCARDMANAGER_H
