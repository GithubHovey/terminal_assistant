#include "PythonRunner.h"
#include <QProcess>
#include <QFileInfo>
#include <QCoreApplication>
#include <QDir>
#include "src/backend/logger/Logger.h"

PythonRunner::PythonRunner(QObject *parent)
    : QObject(parent)
    , m_workingDir(QCoreApplication::applicationDirPath())
{
}

PythonRunner::~PythonRunner() = default;

QString PythonRunner::scriptExePath(const QString &scriptName) const
{
    if (scriptName.isEmpty()) {
        return QString();
    }
    QString name = scriptName;
    if (!name.endsWith(".exe", Qt::CaseInsensitive)) {
        name += ".exe";
    }
    return QCoreApplication::applicationDirPath() + "/python/" + name;
}

bool PythonRunner::scriptExists(const QString &scriptName) const
{
    QString path = scriptExePath(scriptName);
    return QFileInfo::exists(path);
}

bool PythonRunner::runScript(const QString &scriptName, const QStringList &arguments)
{
    if (m_running) {
        emit scriptError("A script is already running");
        return false;
    }

    QString exePath = scriptExePath(scriptName);
    if (!QFileInfo::exists(exePath)) {
        QString err = "Script not found: " + exePath;
        Logger::instance().logError(err);
        emit scriptError(err);
        return false;
    }

    QProcess process;
    process.setWorkingDirectory(m_workingDir);
    process.setProcessChannelMode(QProcess::SeparateChannels);

    setRunning(true);
    m_lastOutput.clear();
    m_lastError.clear();

    process.start(exePath, arguments);

    if (!process.waitForStarted(5000)) {
        QString err = "Failed to start: " + process.errorString();
        Logger::instance().logError(err);
        m_lastError = err;
        emit scriptError(err);
        setRunning(false);
        return false;
    }

    if (!process.waitForFinished(120000)) {
        QString err = "Script timed out: " + scriptName;
        Logger::instance().logError(err);
        m_lastError = err;
        emit scriptError(err);
        setRunning(false);
        return false;
    }

    m_lastOutput = QString::fromUtf8(process.readAllStandardOutput()).trimmed();
    QString stdError = QString::fromUtf8(process.readAllStandardError()).trimmed();
    int exitCode = process.exitCode();

    if (exitCode != 0) {
        m_lastError = stdError.isEmpty() ? m_lastOutput : stdError;
        Logger::instance().logError("Script error [" + scriptName + "]: " + m_lastError);
        emit scriptError(m_lastError);
    }

    if (!stdError.isEmpty()) {
        Logger::instance().logInfo("Script stderr [" + scriptName + "]: " + stdError);
    }

    if (!m_lastOutput.isEmpty()) {
        Logger::instance().logInfo("Script output [" + scriptName + "]: " + m_lastOutput);
        emit outputReady(m_lastOutput);
    }

    Logger::instance().logInfo("Script finished [" + scriptName + "] exit=" + QString::number(exitCode));
    emit scriptFinished(exitCode);
    setRunning(false);

    return exitCode == 0;
}

QString PythonRunner::getOutput() const
{
    return m_lastOutput;
}

QString PythonRunner::getError() const
{
    return m_lastError;
}

void PythonRunner::setWorkingDirectory(const QString &dir)
{
    m_workingDir = dir;
}

bool PythonRunner::isRunning() const
{
    return m_running;
}

void PythonRunner::setRunning(bool running)
{
    if (m_running == running) {
        return;
    }
    m_running = running;
    emit runningChanged();
}
