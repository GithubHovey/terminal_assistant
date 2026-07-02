#include "BasicConfig.h"

BasicConfig::BasicConfig(QObject *parent)
    : QObject(parent)
{
}

BasicConfig::~BasicConfig() = default;

bool BasicConfig::loadConfig()
{
    return false;
}

bool BasicConfig::saveConfig()
{
    return false;
}

QVariantMap BasicConfig::getConfig() const
{
    return m_config;
}

void BasicConfig::setConfig(const QVariantMap &config)
{
    m_config = config;
}