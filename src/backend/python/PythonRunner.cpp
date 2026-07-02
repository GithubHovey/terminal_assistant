#include "PythonRunner.h"

PythonRunner::PythonRunner(QObject *parent)
    : QObject(parent)
    , m_pythonPath("python")
{
}

PythonRunner::~PythonRunner() = default;

bool PythonRunner::runScript(const QString &scriptPath, const QStringList &arguments)
{
    Q_UNUSED(scriptPath);
    Q_UNUSED(arguments);
    return false;
}

void PythonRunner::setPythonPath(const QString &pythonPath)
{
    m_pythonPath = pythonPath;
}

QString PythonRunner::getOutput() const
{
    return m_lastOutput;
}