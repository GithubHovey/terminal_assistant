#ifndef ESPFLASHER_H
#define ESPFLASHER_H

#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariantList>
#include <QProcess>
#include <QSerialPort>

class ESPFlasher : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool running READ isRunning NOTIFY runningChanged)
    Q_PROPERTY(bool monitoring READ isMonitoring NOTIFY monitoringChanged)
    Q_PROPERTY(QVariantList availablePorts READ availablePorts NOTIFY portsChanged)
    Q_PROPERTY(int progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(QString currentOperation READ currentOperation NOTIFY currentOperationChanged)

public:
    explicit ESPFlasher(QObject *parent = nullptr);
    ~ESPFlasher() override;

    bool isRunning() const;
    bool isMonitoring() const;
    QVariantList availablePorts() const;
    int progress() const;
    QString currentOperation() const;

    Q_INVOKABLE void scanPorts();
    Q_INVOKABLE bool connectMonitor(const QString &portName, int baudRate);
    Q_INVOKABLE void disconnectMonitor();
    Q_INVOKABLE void flashFirmware(const QString &port, const QString &filePath,
                                   const QString &offset, const QString &chip,
                                   int baud, const QString &flashMode,
                                   const QString &flashSize);
    Q_INVOKABLE void eraseFlash(const QString &port, const QString &chip, int baud);
    Q_INVOKABLE void readChipInfo(const QString &port, const QString &chip, int baud);
    Q_INVOKABLE void abort();

signals:
    void runningChanged();
    void monitoringChanged();
    void portsChanged();
    void progressChanged(int percent, const QString &message);
    void currentOperationChanged();
    void serialDataReceived(const QString &data);
    void monitorConnected(bool connected);
    void logOutput(const QString &line);
    void operationFinished(bool success, const QString &message);
    void errorOccurred(const QString &error);
    void chipDetected(const QString &chipInfo);

private slots:
    void onSerialDataReady();
    void onProcessStdout();
    void onProcessStderr();
    void onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);

private:
    void setRunning(bool running);
    void setMonitoring(bool monitoring);
    void setProgress(int progress, const QString &message);
    void setCurrentOperation(const QString &operation);
    void ensureMonitorDisconnected();
    void startEsptool(const QStringList &args);
    void parseEsptoolOutput(const QString &line);

    QSerialPort *m_serialPort;
    QProcess *m_process;
    QVariantList m_availablePorts;
    bool m_running;
    bool m_monitoring;
    int m_progress;
    QString m_currentOperation;
    int m_totalFlashSegments;
    int m_completedSegments;
};

#endif // ESPFLASHER_H
