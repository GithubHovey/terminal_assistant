#include "DeviceEventFilter.h"
#include <windows.h>
#include <dbt.h>

DeviceEventFilter::DeviceEventFilter(QObject *parent)
    : QObject(parent)
{
}

bool DeviceEventFilter::nativeEventFilter(const QByteArray &eventType, void *message, qintptr *result)
{
    Q_UNUSED(result);

    if (eventType != "windows_generic_MSG")
        return false;

    auto *msg = static_cast<MSG *>(message);
    if (msg->message != WM_DEVICECHANGE)
        return false;

    if (msg->wParam != DBT_DEVICEARRIVAL && msg->wParam != DBT_DEVICEREMOVECOMPLETE)
        return false;

    if (!msg->lParam)
        return false;

    auto *dbHdr = reinterpret_cast<DEV_BROADCAST_HDR *>(msg->lParam);
    if (dbHdr->dbch_devicetype != DBT_DEVTYP_VOLUME)
        return false;

    auto *volume = reinterpret_cast<DEV_BROADCAST_VOLUME *>(dbHdr);
    DWORD unitmask = volume->dbcv_unitmask;

    for (int i = 0; i < 26; i++) {
        if (unitmask & (1 << i)) {
            QString letter = QString(QChar('A' + i)) + ":";
            if (msg->wParam == DBT_DEVICEARRIVAL)
                emit deviceArrived(letter);
            else
                emit deviceRemoved(letter);
        }
    }

    return false;
}
