#ifndef MAINTENANCEMANAGER_H
#define MAINTENANCEMANAGER_H

#include <QObject>
#include <QString>

class MaintenanceManager : public QObject
{
    Q_OBJECT

public:
    explicit MaintenanceManager(QObject *parent = nullptr);
    ~MaintenanceManager() override;

    Q_INVOKABLE bool diagnose();
    Q_INVOKABLE bool exportLogs(const QString &logContent, const QString &destination);
    Q_INVOKABLE bool importLogs(const QString &source);

signals:
    void diagnoseComplete(const QString &result);
    void logExported(const QString &path);
    void logImported(const QString &path);
    void error(const QString &errorMessage);

private:
    QString m_lastDiagnoseResult;
};

#endif // MAINTENANCEMANAGER_H