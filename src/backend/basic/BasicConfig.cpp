#include "BasicConfig.h"
#include "src/backend/logger/Logger.h"
#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QProcess>

BasicConfig::BasicConfig(QObject *parent)
    : QObject(parent)
{
}

BasicConfig::~BasicConfig() = default;

bool BasicConfig::loadConfig()
{
    return false;
}

bool BasicConfig::saveConfig()
{
    return false;
}

QVariantMap BasicConfig::getConfig() const
{
    return m_config;
}

void BasicConfig::setConfig(const QVariantMap &config)
{
    m_config = config;
}

QString BasicConfig::bootlogoPath() const
{
    return QCoreApplication::applicationDirPath() + "/bootlogo/bootlogo.gif";
}

bool BasicConfig::replaceBootlogo(const QString &srcPath, double offsetX, double offsetY, double scale, bool speedUp)
{
    if (srcPath.isEmpty()) {
        Logger::instance().logError("源文件路径为空");
        return false;
    }

    if (!QFile::exists(srcPath)) {
        Logger::instance().logError("源文件不存在: " + srcPath);
        return false;
    }

    QString appDir = QCoreApplication::applicationDirPath();
    QString bootlogoDir = appDir + "/bootlogo";
    QString outputPath = bootlogoDir + "/bootlogo.gif";
    QString ffmpegPath = appDir + "/python/ffmpeg.exe";

    QDir dir;
    if (!dir.exists(bootlogoDir)) {
        if (!dir.mkpath(bootlogoDir)) {
            Logger::instance().logError("无法创建 bootlogo 目录");
            return false;
        }
    }

    if (!QFile::exists(ffmpegPath)) {
        Logger::instance().logError("ffmpeg 不存在: " + ffmpegPath);
        return false;
    }

    QString scaleFilter = QString("scale=iw*%1:ih*%1").arg(scale);
    QString cropFilter = QString("crop=320:240:(iw-320)/2-(%1):(ih-240)/2-(%2)").arg(offsetX).arg(offsetY);

    QString vf;
    if (speedUp) {
        vf = QString("%1,%2,setpts=PTS/2").arg(scaleFilter, cropFilter);
    } else {
        vf = QString("%1,%2").arg(scaleFilter, cropFilter);
    }

    QProcess process;
    process.setWorkingDirectory(appDir);
    process.setProcessChannelMode(QProcess::SeparateChannels);

    QStringList args;
    args << "-i" << srcPath
         << "-vf" << vf
         << "-y" << outputPath;

    Logger::instance().logInfo("正在处理 GIF: " + srcPath + " (缩放:" + QString::number(scale) + "x, 偏移:" + QString::number(offsetX) + "," + QString::number(offsetY) + ")");

    process.start(ffmpegPath, args);

    if (!process.waitForStarted(5000)) {
        Logger::instance().logError("无法启动 ffmpeg: " + process.errorString());
        return false;
    }

    if (!process.waitForFinished(120000)) {
        Logger::instance().logError("GIF 处理超时");
        return false;
    }

    if (process.exitCode() != 0) {
        QString error = QString::fromUtf8(process.readAllStandardError()).trimmed();
        Logger::instance().logError("GIF 处理失败: " + error);
        return false;
    }

    Logger::instance().logInfo("bootlogo.gif 已更新");
    emit bootlogoPathChanged();
    return true;
}