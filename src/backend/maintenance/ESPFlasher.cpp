#include "ESPFlasher.h"
#include <QProcess>
#include <QSerialPortInfo>
#include <QCoreApplication>
#include <QFileInfo>
#include <QRegularExpression>
#include "src/backend/logger/Logger.h"

ESPFlasher::ESPFlasher(QObject *parent)
    : QObject(parent)
    , m_serialPort(nullptr)
    , m_process(nullptr)
    , m_running(false)
    , m_monitoring(false)
    , m_progress(0)
    , m_totalFlashSegments(0)
    , m_completedSegments(0)
{
}

ESPFlasher::~ESPFlasher()
{
    disconnectMonitor();
    if (m_process) {
        m_process->kill();
        m_process->waitForFinished(1000);
        delete m_process;
    }
}

bool ESPFlasher::isRunning() const
{
    return m_running;
}

bool ESPFlasher::isMonitoring() const
{
    return m_monitoring;
}

QVariantList ESPFlasher::availablePorts() const
{
    return m_availablePorts;
}

int ESPFlasher::progress() const
{
    return m_progress;
}

QString ESPFlasher::currentOperation() const
{
    return m_currentOperation;
}

void ESPFlasher::scanPorts()
{
    m_availablePorts.clear();
    const auto ports = QSerialPortInfo::availablePorts();
    for (const QSerialPortInfo &info : ports) {
        QVariantMap portInfo;
        portInfo["name"] = info.portName();
        portInfo["description"] = info.description().isEmpty() 
            ? info.portName() 
            : info.description();
        portInfo["manufacturer"] = info.manufacturer();
        portInfo["serialNumber"] = info.serialNumber();
        portInfo["vendorId"] = info.vendorIdentifier();
        portInfo["productId"] = info.productIdentifier();
        m_availablePorts.append(portInfo);
    }
    emit portsChanged();
    Logger::instance().logInfo(QString("Found %1 serial ports").arg(m_availablePorts.size()));
}

bool ESPFlasher::connectMonitor(const QString &portName, int baudRate)
{
    if (m_monitoring) {
        disconnectMonitor();
    }
    
    if (m_running) {
        emit errorOccurred("Cannot start monitoring while flash operation is running");
        return false;
    }

    m_serialPort = new QSerialPort(this);
    m_serialPort->setPortName(portName);
    m_serialPort->setBaudRate(baudRate);
    m_serialPort->setDataBits(QSerialPort::Data8);
    m_serialPort->setParity(QSerialPort::NoParity);
    m_serialPort->setStopBits(QSerialPort::OneStop);
    m_serialPort->setFlowControl(QSerialPort::NoFlowControl);

    if (!m_serialPort->open(QIODevice::ReadOnly)) {
        QString error = m_serialPort->errorString();
        Logger::instance().logError("Failed to open serial port: " + error);
        emit errorOccurred("Failed to open serial port: " + error);
        delete m_serialPort;
        m_serialPort = nullptr;
        return false;
    }

    connect(m_serialPort, &QSerialPort::readyRead, this, &ESPFlasher::onSerialDataReady);
    setMonitoring(true);
    Logger::instance().logInfo(QString("Serial monitor started on %1 @ %2 baud")
        .arg(portName).arg(baudRate));
    emit logOutput(QString("── Serial monitor started on %1 @ %2 baud ──")
        .arg(portName).arg(baudRate));
    return true;
}

void ESPFlasher::disconnectMonitor()
{
    if (m_serialPort) {
        m_serialPort->close();
        delete m_serialPort;
        m_serialPort = nullptr;
        setMonitoring(false);
        Logger::instance().logInfo("Serial monitor stopped");
        emit logOutput("── Serial monitor stopped ──");
    }
}

void ESPFlasher::flashFirmware(const QString &port, const QString &filePath,
                               const QString &offset, const QString &chip,
                               int baud, const QString &flashMode,
                               const QString &flashSize)
{
    if (m_running) {
        emit errorOccurred("A flash operation is already running");
        return;
    }

    if (!QFileInfo::exists(filePath)) {
        emit errorOccurred("Firmware file not found: " + filePath);
        return;
    }

    ensureMonitorDisconnected();

    QStringList args;
    args << "-c" << chip;
    args << "-p" << port;
    args << "-b" << QString::number(baud);
    args << "write-flash";
    args << "--flash-mode" << flashMode;
    args << "--flash-size" << flashSize;
    args << offset << filePath;

    setCurrentOperation("Flashing firmware...");
    setProgress(0, "Starting...");
    startEsptool(args);
}

void ESPFlasher::eraseFlash(const QString &port, const QString &chip, int baud)
{
    if (m_running) {
        emit errorOccurred("A flash operation is already running");
        return;
    }

    ensureMonitorDisconnected();

    QStringList args;
    args << "-c" << chip;
    args << "-p" << port;
    args << "-b" << QString::number(baud);
    args << "erase-flash";

    setCurrentOperation("Erasing flash...");
    setProgress(0, "Starting...");
    startEsptool(args);
}

void ESPFlasher::readChipInfo(const QString &port, const QString &chip, int baud)
{
    if (m_running) {
        emit errorOccurred("A flash operation is already running");
        return;
    }

    ensureMonitorDisconnected();

    QStringList args;
    args << "-c" << chip;
    args << "-p" << port;
    args << "-b" << QString::number(baud);
    args << "flash-id";

    setCurrentOperation("Reading chip info...");
    setProgress(0, "Starting...");
    startEsptool(args);
}

void ESPFlasher::abort()
{
    if (m_process && m_running) {
        m_process->kill();
        Logger::instance().logWarning("Flash operation aborted by user");
        emit logOutput("── Operation aborted ──");
    }
}

void ESPFlasher::onSerialDataReady()
{
    if (!m_serialPort || !m_serialPort->isOpen()) {
        return;
    }

    QByteArray data = m_serialPort->readAll();
    if (!data.isEmpty()) {
        QString text = QString::fromUtf8(data);
        emit serialDataReceived(text);
    }
}

void ESPFlasher::onProcessStdout()
{
    if (!m_process) return;

    QByteArray data = m_process->readAllStandardOutput();
    QString text = QString::fromUtf8(data);
    QStringList lines = text.split('\n', Qt::SkipEmptyParts);

    for (const QString &line : lines) {
        QString trimmed = line.trimmed();
        if (!trimmed.isEmpty()) {
            emit logOutput(trimmed);
            parseEsptoolOutput(trimmed);
        }
    }
}

void ESPFlasher::onProcessStderr()
{
    if (!m_process) return;

    QByteArray data = m_process->readAllStandardError();
    QString text = QString::fromUtf8(data);
    QStringList lines = text.split('\n', Qt::SkipEmptyParts);

    for (const QString &line : lines) {
        QString trimmed = line.trimmed();
        if (!trimmed.isEmpty()) {
            emit logOutput(trimmed);
            parseEsptoolOutput(trimmed);
        }
    }
}

void ESPFlasher::onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    setRunning(false);
    
    if (exitStatus == QProcess::CrashExit) {
        emit operationFinished(false, "Process crashed");
        emit logOutput("── Process crashed ──");
        return;
    }

    if (exitCode == 0) {
        setProgress(100, "Complete");
        emit operationFinished(true, "Operation completed successfully");
        emit logOutput("── Operation completed successfully ──");
        Logger::instance().logInfo("Flash operation completed successfully");
    } else {
        emit operationFinished(false, "Operation failed with exit code " + QString::number(exitCode));
        emit logOutput(QString("── Operation failed (exit code %1) ──").arg(exitCode));
        Logger::instance().logError("Flash operation failed with exit code " + QString::number(exitCode));
    }
}

void ESPFlasher::setRunning(bool running)
{
    if (m_running != running) {
        m_running = running;
        emit runningChanged();
    }
}

void ESPFlasher::setMonitoring(bool monitoring)
{
    if (m_monitoring != monitoring) {
        m_monitoring = monitoring;
        emit monitoringChanged();
    }
}

void ESPFlasher::setProgress(int progress, const QString &message)
{
    m_progress = progress;
    emit progressChanged(progress, message);
}

void ESPFlasher::setCurrentOperation(const QString &operation)
{
    m_currentOperation = operation;
    emit currentOperationChanged();
}

void ESPFlasher::ensureMonitorDisconnected()
{
    if (m_monitoring) {
        disconnectMonitor();
        emit logOutput("── Serial monitor disconnected for flash operation ──");
    }
}

void ESPFlasher::startEsptool(const QStringList &args)
{
    if (m_process) {
        delete m_process;
    }

    m_process = new QProcess(this);
    m_process->setProcessChannelMode(QProcess::SeparateChannels);

    connect(m_process, &QProcess::readyReadStandardOutput, this, &ESPFlasher::onProcessStdout);
    connect(m_process, &QProcess::readyReadStandardError, this, &ESPFlasher::onProcessStderr);
    connect(m_process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, &ESPFlasher::onProcessFinished);

    m_totalFlashSegments = 0;
    m_completedSegments = 0;

    QString program = QCoreApplication::applicationDirPath() + "/python/esptool.exe";
    QStringList fullArgs = args;

    Logger::instance().logInfo("Starting: " + program + " " + fullArgs.join(" "));
    emit logOutput("$ " + program + " " + fullArgs.join(" "));

    m_process->start(program, fullArgs);

    if (!m_process->waitForStarted(5000)) {
        QString error = m_process->errorString();
        Logger::instance().logError("Failed to start esptool: " + error);
        emit errorOccurred("Failed to start esptool: " + error);
        emit logOutput("── Failed to start esptool: " + error + " ──");
        setRunning(false);
        return;
    }

    setRunning(true);
}

void ESPFlasher::parseEsptoolOutput(const QString &line)
{
    // Detect chip info
    if (line.contains("Connected to")) {
        emit chipDetected(line);
    }

    // Count flash segments
    if (line.contains("Flash will be erased from")) {
        m_totalFlashSegments++;
    }

    // Track completed segments
    if (line.contains("Wrote") && line.contains("bytes") && line.contains("at 0x")) {
        m_completedSegments++;
        if (m_totalFlashSegments > 0) {
            int percent = (m_completedSegments * 100) / m_totalFlashSegments;
            setProgress(percent, "Flashing...");
        }
    }

    // Hash verification
    if (line.contains("Hash of data verified")) {
        setProgress(95, "Verifying...");
    }

    // Reset complete
    if (line.contains("Hard resetting")) {
        setProgress(100, "Resetting chip...");
    }

    // Erase progress
    if (line.contains("Erasing flash")) {
        setProgress(50, "Erasing...");
    }

    if (line.contains("Chip erase completed")) {
        setProgress(100, "Erase complete");
    }
}
