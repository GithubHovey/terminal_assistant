#include "SDCardManager.h"
#include "src/backend/logger/Logger.h"
#include <QStorageInfo>
#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QtConcurrent>
#include <vector>
#include <windows.h>

SDCardManager::SDCardManager(QObject *parent)
    : QObject(parent)
    , m_connTimer(new QTimer(this))
    , m_arrivalDebounceTimer(new QTimer(this))
    , m_applyWatcher(new QFutureWatcher<bool>(this))
    , m_connected(false)
    , m_cardSize(0)
    , m_freeSpace(0)
{
    m_connTimer->setSingleShot(false);
    connect(m_connTimer, &QTimer::timeout, this, &SDCardManager::checkConnection);

    m_arrivalDebounceTimer->setSingleShot(true);
    m_arrivalDebounceTimer->setInterval(500);
    connect(m_arrivalDebounceTimer, &QTimer::timeout, this, &SDCardManager::refreshDrives);

    refreshDrives();
}

SDCardManager::~SDCardManager() = default;

bool SDCardManager::isConnected() const
{
    return m_connected;
}

QString SDCardManager::driveLetter() const
{
    return m_driveLetter;
}

qint64 SDCardManager::cardSize() const
{
    return m_cardSize;
}

qint64 SDCardManager::freeSpace() const
{
    return m_freeSpace;
}

QVariantList SDCardManager::availableDrives() const
{
    return m_availableDrives;
}

void SDCardManager::refreshDrives()
{
    m_availableDrives = scanRemovableDrives();
    emit driveListChanged();
    Logger::instance().logInfo(
        QString("扫描完成，发现 %1 个可移动磁盘").arg(m_availableDrives.size()));
}

void SDCardManager::onDeviceArrived(const QString &driveLetter)
{
    Logger::instance().logInfo(QString("检测到设备插入: %1").arg(driveLetter));
    m_arrivalDebounceTimer->start();
}

void SDCardManager::onDeviceRemoved(const QString &driveLetter)
{
    Logger::instance().logInfo(QString("检测到设备移除: %1").arg(driveLetter));
    if (m_connected && m_driveLetter == driveLetter) {
        Logger::instance().logWarning(QString("SD卡 %1 已移除，自动断开").arg(driveLetter));
        disconnectCard();
    }
    refreshDrives();
}

QVariantList SDCardManager::scanRemovableDrives()
{
    QVariantList result;

    WCHAR volumeName[MAX_PATH];
    HANDLE findHandle = FindFirstVolumeW(volumeName, MAX_PATH);
    if (findHandle == INVALID_HANDLE_VALUE) {
        return result;
    }

    do {
        QString volPath = QString::fromWCharArray(volumeName);

        DWORD pathNamesLen = 0;
        GetVolumePathNamesForVolumeNameW((LPCWSTR)volPath.utf16(), nullptr, 0, &pathNamesLen);
        if (pathNamesLen == 0) {
            continue;
        }

        std::vector<WCHAR> pathNames(pathNamesLen);
        if (!GetVolumePathNamesForVolumeNameW((LPCWSTR)volPath.utf16(),
                                               pathNames.data(), pathNamesLen, &pathNamesLen)) {
            continue;
        }

        for (const WCHAR *p = pathNames.data(); *p; p += wcslen(p) + 1) {
            QString mountPoint = QString::fromWCharArray(p);
            if (mountPoint.length() != 3 || mountPoint[1] != ':' || mountPoint[2] != '\\') {
                continue;
            }

            UINT driveType = GetDriveTypeW((LPCWSTR)mountPoint.utf16());
            if (driveType != DRIVE_REMOVABLE) {
                continue;
            }

            QStorageInfo storage(mountPoint);
            if (!storage.isValid() || !storage.isReady()) {
                continue;
            }

            QString letter = mountPoint.left(2).toUpper();
            qint64 size = storage.bytesTotal();
            QString label = storage.displayName();
            if (label.isEmpty()) {
                label = "Removable";
            }

            QString sizeStr = formatSizeStatic(size);
            QString display = QString("%1 (%2 %3)").arg(letter, label, sizeStr);

            QVariantMap driveMap;
            driveMap["letter"] = letter;
            driveMap["label"] = label;
            driveMap["size"] = size;
            driveMap["display"] = display;
            result.append(driveMap);
        }
    } while (FindNextVolumeW(findHandle, volumeName, MAX_PATH));

    FindVolumeClose(findHandle);
    return result;
}

bool SDCardManager::connectCard(const QString &driveLetter)
{
    if (m_connected) {
        disconnectCard();
    }

    QString rootPath = driveLetter + "/";
    QStorageInfo storage(rootPath);

    if (!storage.isValid()) {
        QString errorMsg = QString("无效的磁盘: %1").arg(driveLetter);
        Logger::instance().logError(errorMsg);
        emit errorOccurred(errorMsg);
        return false;
    }

    if (!storage.isReady()) {
        QString errorMsg = QString("磁盘 %1 未就绪").arg(driveLetter);
        Logger::instance().logError(errorMsg);
        emit errorOccurred(errorMsg);
        return false;
    }

    m_driveLetter = driveLetter;
    m_cardSize = storage.bytesTotal();
    m_freeSpace = storage.bytesFree();

    m_sdSysrootPath = QCoreApplication::applicationDirPath() + "/sd_sysroot";
    QDir sysrootDir(m_sdSysrootPath);
    if (sysrootDir.exists()) {
        sysrootDir.removeRecursively();
    }
    if (!sysrootDir.mkpath(m_sdSysrootPath)) {
        QString errorMsg = QString("无法创建 sd_sysroot 目录: %1").arg(m_sdSysrootPath);
        Logger::instance().logError(errorMsg);
        emit errorOccurred(errorMsg);
        return false;
    }

    Logger::instance().logInfo("正在备份SD卡内容到 sd_sysroot...");
    if (!backupSDCardToLocal()) {
        QString errorMsg = "备份SD卡内容失败，拒绝连接";
        Logger::instance().logError(errorMsg);
        emit errorOccurred(errorMsg);
        m_driveLetter.clear();
        m_cardSize = 0;
        m_freeSpace = 0;
        m_sdSysrootPath.clear();
        return false;
    }
    Logger::instance().logInfo("SD卡内容已备份到 sd_sysroot");

    m_connected = true;

    startConnectionMonitor();

    QString sizeStr = formatSize(m_cardSize);
    QString freeStr = formatSize(m_freeSpace);
    QString infoMsg = QString("已连接SD卡 %1: %2 (可用 %3)").arg(driveLetter, sizeStr, freeStr);
    Logger::instance().logInfo(infoMsg);

    emit connectedChanged();
    return true;
}

void SDCardManager::disconnectCard()
{
    if (!m_connected) {
        return;
    }

    stopConnectionMonitor();

    QString infoMsg = QString("已断开SD卡 %1").arg(m_driveLetter);
    Logger::instance().logInfo(infoMsg);

    m_connected = false;
    m_driveLetter.clear();
    m_sdSysrootPath.clear();
    m_cardSize = 0;
    m_freeSpace = 0;

    emit connectedChanged();
}

QString SDCardManager::formatSize(qint64 bytes) const
{
    return formatSizeStatic(bytes);
}

QString SDCardManager::formatSizeStatic(qint64 bytes)
{
    if (bytes <= 0) {
        return "0 B";
    }

    const qint64 KB = 1024;
    const qint64 MB = KB * 1024;
    const qint64 GB = MB * 1024;

    if (bytes >= GB) {
        return QString("%1 GB").arg(static_cast<double>(bytes) / GB, 0, 'f', 1);
    } else if (bytes >= MB) {
        return QString("%1 MB").arg(static_cast<double>(bytes) / MB, 0, 'f', 1);
    } else if (bytes >= KB) {
        return QString("%1 KB").arg(static_cast<double>(bytes) / KB, 0, 'f', 1);
    } else {
        return QString("%1 B").arg(bytes);
    }
}

void SDCardManager::checkConnection()
{
    if (!m_connected || m_driveLetter.isEmpty()) {
        return;
    }

    QStorageInfo storage(m_driveLetter + "/");
    if (!storage.isValid() || !storage.isReady()) {
        QString infoMsg = QString("SD卡 %1 已移除，自动断开").arg(m_driveLetter);
        Logger::instance().logWarning(infoMsg);
        disconnectCard();
    }
}

void SDCardManager::startConnectionMonitor()
{
    m_connTimer->start(10000);
}

void SDCardManager::stopConnectionMonitor()
{
    m_connTimer->stop();
}

void SDCardManager::applyResources()
{
    if (!m_connected) {
        emit applyFinished(false, "SD卡未连接");
        return;
    }

    QString appDir = QCoreApplication::applicationDirPath();
    QString sdRoot = m_driveLetter + "/";
    QString musicSrc = appDir + "/music";
    QString musicDst = m_sdSysrootPath + "/music";
    QString charSrc = appDir + "/character";
    QString charDst = m_sdSysrootPath + "/character";
    QString bootlogoSrc = appDir + "/bootlogo";
    QString bootlogoDst = m_sdSysrootPath + "/bootlogo";
    QString configSrc = appDir + "/config.json";
    QString configDst = m_sdSysrootPath + "/config.json";

    if (!QDir(musicSrc).exists()) {
        emit applyFinished(false, "music目录不存在");
        return;
    }
    if (!QDir(charSrc).exists()) {
        emit applyFinished(false, "character目录不存在");
        return;
    }
    QDir().mkpath(bootlogoSrc);

    Logger::instance().logInfo("开始复制资源到 sd_sysroot 并同步到SD卡...");

    QString sdSysrootPath = m_sdSysrootPath;
    QFuture<bool> future = QtConcurrent::run([musicSrc, musicDst, charSrc, charDst, bootlogoSrc, bootlogoDst, configSrc, configDst, sdRoot, sdSysrootPath]() -> bool {
        QDir musicDstDir(musicDst);
        if (musicDstDir.exists()) {
            musicDstDir.removeRecursively();
        }
        QDir charDstDir(charDst);
        if (charDstDir.exists()) {
            charDstDir.removeRecursively();
        }
        QDir bootlogoDstDir(bootlogoDst);
        if (bootlogoDstDir.exists()) {
            bootlogoDstDir.removeRecursively();
        }

        if (!copyDirectoryRecursive(musicSrc, musicDst)) {
            return false;
        }
        if (!copyDirectoryRecursive(charSrc, charDst)) {
            return false;
        }
        if (!copyDirectoryRecursive(bootlogoSrc, bootlogoDst)) {
            return false;
        }

        QFile::remove(configDst);
        if (!QFile::copy(configSrc, configDst)) {
            return false;
        }

        QDir sdRootDir(sdRoot);
        if (sdRootDir.exists()) {
            sdRootDir.removeRecursively();
        }
        if (!copyDirectoryRecursive(sdSysrootPath, sdRoot)) {
            return false;
        }
        return true;
    });

    m_applyWatcher->setFuture(future);

    connect(m_applyWatcher, &QFutureWatcher<bool>::finished, this, [this]() {
        bool success = m_applyWatcher->result();
        if (success) {
            Logger::instance().logInfo("资源已成功同步到SD卡");
            emit applyFinished(true, "资源已成功同步到SD卡");
        } else {
            Logger::instance().logError("同步资源到SD卡失败");
            emit applyFinished(false, "同步资源到SD卡失败");
        }
    });
}

bool SDCardManager::copyDirectoryRecursive(const QString &srcPath, const QString &dstPath)
{
    QDir srcDir(srcPath);
    if (!srcDir.exists()) {
        return false;
    }

    QDir dstDir;
    if (!dstDir.mkpath(dstPath)) {
        return false;
    }

    const QFileInfoList entries = srcDir.entryInfoList(QDir::NoDotAndDotDot | QDir::Files | QDir::Dirs);
    for (const QFileInfo &info : entries) {
        if (info.isDir()) {
            if (!copyDirectoryRecursive(info.absoluteFilePath(), dstPath + "/" + info.fileName())) {
                return false;
            }
        } else {
            QString dstFile = dstPath + "/" + info.fileName();
            QFile::remove(dstFile);
            if (!QFile::copy(info.absoluteFilePath(), dstFile)) {
                return false;
            }
        }
    }
    return true;
}

bool SDCardManager::backupSDCardToLocal()
{
    QString sdRoot = m_driveLetter + "/";
    QDir sdDir(sdRoot);

    const QFileInfoList entries = sdDir.entryInfoList(QDir::NoDotAndDotDot | QDir::Files | QDir::Dirs | QDir::Hidden | QDir::System);
    for (const QFileInfo &info : entries) {
        QString dstPath = m_sdSysrootPath + "/" + info.fileName();
        if (info.isDir()) {
            if (!copyDirectoryRecursive(info.absoluteFilePath(), dstPath)) {
                return false;
            }
        } else {
            QFile::remove(dstPath);
            if (!QFile::copy(info.absoluteFilePath(), dstPath)) {
                return false;
            }
        }
    }
    return true;
}
