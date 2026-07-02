#ifndef SDCARDMANAGER_H
#define SDCARDMANAGER_H

#include <QObject>
#include <QString>

class SDCardManager : public QObject
{
    Q_OBJECT

public:
    explicit SDCardManager(QObject *parent = nullptr);
    ~SDCardManager() override;

    Q_INVOKABLE bool findSDCard();
    Q_INVOKABLE bool readSDCard();
    Q_INVOKABLE qint64 getCardSize() const;
    Q_INVOKABLE qint64 getFreeSpace() const;
    Q_INVOKABLE bool isFAT32() const;

signals:
    void cardFound(const QString &driveLetter);
    void cardReadError(const QString &error);

private:
    QString m_driveLetter;
    qint64 m_cardSize;
    qint64 m_freeSpace;
};

#endif // SDCARDMANAGER_H