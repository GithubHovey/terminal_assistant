#include "Logger.h"
#include <QDateTime>

Logger& Logger::instance()
{
    static Logger instance;
    return instance;
}

Logger::Logger(QObject *parent)
    : QObject(parent)
{
}

Logger::~Logger() = default;

QString Logger::formatLogEntry(const QString &level, const QString &message)
{
    QString timestamp = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss");
    return QString("[%1] [%2] %3").arg(timestamp, level, message);
}

void Logger::log(const QString &message)
{
    logInfo(message);
}

void Logger::logInfo(const QString &message)
{
    QString entry = formatLogEntry("INFO", message);
    m_logHistory.append(entry);
    emit newLogEntry(entry);
}

void Logger::logWarning(const QString &message)
{
    QString entry = formatLogEntry("WARN", message);
    m_logHistory.append(entry);
    emit newLogEntry(entry);
}

void Logger::logError(const QString &message)
{
    QString entry = formatLogEntry("ERROR", message);
    m_logHistory.append(entry);
    emit newLogEntry(entry);
}

QStringList Logger::getLogHistory() const
{
    return m_logHistory;
}

void Logger::clearLog()
{
    m_logHistory.clear();
}

QString Logger::getLogs() const
{
    return m_logHistory.join("\n");
}