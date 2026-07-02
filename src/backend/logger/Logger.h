#ifndef LOGGER_H
#define LOGGER_H

#include <QObject>
#include <QString>
#include <QStringList>

class Logger : public QObject
{
    Q_OBJECT

public:
    static Logger& instance();
    
    Q_INVOKABLE void log(const QString &message);
    Q_INVOKABLE void logInfo(const QString &message);
    Q_INVOKABLE void logWarning(const QString &message);
    Q_INVOKABLE void logError(const QString &message);
    Q_INVOKABLE QStringList getLogHistory() const;
    Q_INVOKABLE void clearLog();
    
    Q_INVOKABLE QString getLogs() const;

signals:
    void newLogEntry(const QString &entry);

private:
    explicit Logger(QObject *parent = nullptr);
    ~Logger() override;
    Logger(const Logger&) = delete;
    Logger& operator=(const Logger&) = delete;
    
    QStringList m_logHistory;
    QString formatLogEntry(const QString &level, const QString &message);
};

#endif // LOGGER_H