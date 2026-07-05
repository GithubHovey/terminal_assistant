#include "RoleInfo.h"

RoleInfo::RoleInfo()
    : m_id(1)
    , m_isUser(false)
{
}

RoleInfo::RoleInfo(const QString &name, int id)
    : m_name(name)
    , m_id(id)
    , m_isUser(id == 0)
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
    m_isUser = (id == 0);
}

bool RoleInfo::isUser() const
{
    return m_isUser;
}

void RoleInfo::setIsUser(bool isUser)
{
    m_isUser = isUser;
    if (isUser) {
        m_id = 0;
    }
}

QString RoleInfo::englishName() const
{
    return m_englishName;
}

void RoleInfo::setEnglishName(const QString &englishName)
{
    m_englishName = englishName;
}

QString RoleInfo::agentId() const
{
    return m_agentId;
}

void RoleInfo::setAgentId(const QString &agentId)
{
    m_agentId = agentId;
}

QString RoleInfo::agentUrl() const
{
    return m_agentUrl;
}

void RoleInfo::setAgentUrl(const QString &agentUrl)
{
    m_agentUrl = agentUrl;
}

QString RoleInfo::voiceCloneId() const
{
    return m_voiceCloneId;
}

void RoleInfo::setVoiceCloneId(const QString &voiceCloneId)
{
    m_voiceCloneId = voiceCloneId;
}

QString RoleInfo::prompt() const
{
    return m_prompt;
}

void RoleInfo::setPrompt(const QString &prompt)
{
    m_prompt = prompt;
}

QVariantMap RoleInfo::toMap() const
{
    QVariantMap map;
    map["id"] = m_id;
    map["name"] = m_name;
    map["englishName"] = m_englishName;
    map["agentId"] = m_agentId;
    map["agentUrl"] = m_agentUrl;
    map["voiceCloneId"] = m_voiceCloneId;
    map["prompt"] = m_prompt;
    return map;
}

RoleInfo RoleInfo::fromMap(const QVariantMap &map)
{
    RoleInfo role;
    role.setId(map.value("id").toInt());
    role.setName(map.value("name").toString());
    role.setEnglishName(map.value("englishName").toString());
    role.setAgentId(map.value("agentId").toString());
    role.setAgentUrl(map.value("agentUrl").toString());
    role.setVoiceCloneId(map.value("voiceCloneId").toString());
    role.setPrompt(map.value("prompt").toString());
    return role;
}
