#include "RoleInfo.h"

RoleInfo::RoleInfo()
    : m_id(0)
{
}

RoleInfo::RoleInfo(const QString &name, int id)
    : m_name(name)
    , m_id(id)
{
}

RoleInfo::~RoleInfo() = default;

QString RoleInfo::name() const
{
    return m_name;
}

void RoleInfo::setName(const QString &name)
{
    m_name = name;
}

int RoleInfo::id() const
{
    return m_id;
}

void RoleInfo::setId(int id)
{
    m_id = id;
}

QString RoleInfo::avatarBinPath() const
{
    return m_avatarBinPath;
}

void RoleInfo::setAvatarBinPath(const QString &path)
{
    m_avatarBinPath = path;
}

QString RoleInfo::agentId() const
{
    return m_agentId;
}

void RoleInfo::setAgentId(const QString &agentId)
{
    m_agentId = agentId;
}

QString RoleInfo::voiceCloneId() const
{
    return m_voiceCloneId;
}

void RoleInfo::setVoiceCloneId(const QString &voiceCloneId)
{
    m_voiceCloneId = voiceCloneId;
}

QString RoleInfo::voiceCloneMaterialPath() const
{
    return m_voiceCloneMaterialPath;
}

void RoleInfo::setVoiceCloneMaterialPath(const QString &path)
{
    m_voiceCloneMaterialPath = path;
}