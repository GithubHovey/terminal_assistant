#ifndef PYTHONRUNNER_H
#define PYTHONRUNNER_H

#include <QObject>
#include <QString>
#include <QStringList>

class PythonRunner : public QObject
{
    Q_OBJECT

public:
    explicit PythonRunner(QObject *parent = nullptr);
    ~PythonRunner() override;

    Q_INVOKABLE bool runScript(const QString &scriptPath, const QStringList &arguments);
    Q_INVOKABLE void setPythonPath(const QString &pythonPath);
    Q_INVOKABLE QString getOutput() const;

signals:
    void scriptFinished(int exitCode);
    void scriptError(const QString &error);
    void outputReady(const QString &output);

private:
    QString m_pythonPath;
    QString m_lastOutput;
};

#endif // PYTHONRUNNER_H