#include "SDCardManager.h"

SDCardManager::SDCardManager(QObject *parent)
    : QObject(parent)
    , m_cardSize(0)
    , m_freeSpace(0)
{
}

SDCardManager::~SDCardManager() = default;

bool SDCardManager::findSDCard()
{
    return false;
}

bool SDCardManager::readSDCard()
{
    return false;
}

qint64 SDCardManager::getCardSize() const
{
    return m_cardSize;
}

qint64 SDCardManager::getFreeSpace() const
{
    return m_freeSpace;
}

bool SDCardManager::isFAT32() const
{
    return false;
}