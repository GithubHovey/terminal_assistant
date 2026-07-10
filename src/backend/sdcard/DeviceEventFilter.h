#ifndef DEVICEEVENTFILTER_H
#define DEVICEEVENTFILTER_H

#include <QAbstractNativeEventFilter>
#include <QObject>

class DeviceEventFilter : public QObject, public QAbstractNativeEventFilter
{
    Q_OBJECT

public:
    explicit DeviceEventFilter(QObject *parent = nullptr);
    bool nativeEventFilter(const QByteArray &eventType, void *message, qintptr *result) override;

signals:
    void deviceArrived(const QString &driveLetter);
    void deviceRemoved(const QString &driveLetter);
};

#endif // DEVICEEVENTFILTER_H
