#include "RadioConfig.h"

RadioConfig::RadioConfig(QObject *parent)
    : QObject(parent)
{
}

RadioConfig::~RadioConfig() = default;

bool RadioConfig::loadConfig()
{
    return false;
}

bool RadioConfig::saveConfig()
{
    return false;
}

QVariantMap RadioConfig::getConfig() const
{
    return m_config;
}

void RadioConfig::setConfig(const QVariantMap &config)
{
    m_config = config;
}