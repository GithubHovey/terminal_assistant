#include "MaintenanceManager.h"

MaintenanceManager::MaintenanceManager(QObject *parent)
    : QObject(parent)
{
}

MaintenanceManager::~MaintenanceManager() = default;

bool MaintenanceManager::diagnose()
{
    return false;
}

bool MaintenanceManager::exportLogs(const QString &destination)
{
    Q_UNUSED(destination);
    return false;
}

bool MaintenanceManager::importLogs(const QString &source)
{
    Q_UNUSED(source);
    return false;
}