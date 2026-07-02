#include "UserSettings.h"

UserSettings& UserSettings::instance()
{
    static UserSettings instance;
    return instance;
}

UserSettings::UserSettings()
    : m_isFirstBoot(true)
    , m_version("1.0.0")
{
}

UserSettings::~UserSettings() = default;

QString UserSettings::apiKey() const
{
    return m_apiKey;
}

void UserSettings::setApiKey(const QString &apiKey)
{
    m_apiKey = apiKey;
}

bool UserSettings::isFirstBoot() const
{
    return m_isFirstBoot;
}

void UserSettings::setFirstBoot(bool firstBoot)
{
    m_isFirstBoot = firstBoot;
}

QList<RoleInfo> UserSettings::roleList() const
{
    return m_roleList;
}

void UserSettings::setRoleList(const QList<RoleInfo> &roleList)
{
    m_roleList = roleList;
}

void UserSettings::addRole(const RoleInfo &role)
{
    m_roleList.append(role);
}

void UserSettings::removeRole(int id)
{
    for (int i = 0; i < m_roleList.size(); ++i) {
        if (m_roleList[i].id() == id) {
            m_roleList.removeAt(i);
            break;
        }
    }
}

RoleInfo UserSettings::getRole(int id) const
{
    for (const RoleInfo &role : m_roleList) {
        if (role.id() == id) {
            return role;
        }
    }
    return RoleInfo();
}

QString UserSettings::version() const
{
    return m_version;
}

bool UserSettings::loadFromFile(const QString &filePath)
{
    return false;
}

bool UserSettings::saveToFile(const QString &filePath)
{
    return false;
}