#ifndef PYTHONRUNNER_H
#define PYTHONRUNNER_H

#include <QObject>
#include <QString>
#include <QStringList>

class PythonRunner : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool running READ isRunning NOTIFY runningChanged)

public:
    explicit PythonRunner(QObject *parent = nullptr);
    ~PythonRunner() override;

    Q_INVOKABLE bool runScript(const QString &scriptName, const QStringList &arguments = QStringList());
    Q_INVOKABLE QString getOutput() const;
    Q_INVOKABLE QString getError() const;
    Q_INVOKABLE QString scriptExePath(const QString &scriptName) const;
    Q_INVOKABLE bool scriptExists(const QString &scriptName) const;
    Q_INVOKABLE void setWorkingDirectory(const QString &dir);

    bool isRunning() const;

signals:
    void scriptFinished(int exitCode);
    void scriptError(const QString &error);
    void outputReady(const QString &output);
    void runningChanged();

private:
    QString m_lastOutput;
    QString m_lastError;
    QString m_workingDir;
    bool m_running = false;

    void setRunning(bool running);
};

#endif // PYTHONRUNNER_H
