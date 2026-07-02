#include "AgentConfig.h"

AgentConfig::AgentConfig(QObject *parent)
    : QObject(parent)
{
}

AgentConfig::~AgentConfig() = default;

bool AgentConfig::loadConfig()
{
    return false;
}

bool AgentConfig::saveConfig()
{
    return false;
}

QVariantMap AgentConfig::getConfig() const
{
    return m_config;
}

void AgentConfig::setConfig(const QVariantMap &config)
{
    m_config = config;
}