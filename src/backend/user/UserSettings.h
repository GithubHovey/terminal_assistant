#ifndef USERSETTINGS_H
#define USERSETTINGS_H

#include <QString>
#include <QList>
#include "RoleInfo.h"

class UserSettings
{
public:
    static UserSettings& instance();
    
    QString apiKey() const;
    void setApiKey(const QString &apiKey);
    
    bool isFirstBoot() const;
    void setFirstBoot(bool firstBoot);
    
    QList<RoleInfo> roleList() const;
    void setRoleList(const QList<RoleInfo> &roleList);
    void addRole(const RoleInfo &role);
    void removeRole(int id);
    RoleInfo getRole(int id) const;
    
    QString version() const;
    
    bool loadFromFile(const QString &filePath);
    bool saveToFile(const QString &filePath);
    
private:
    UserSettings();
    ~UserSettings();
    UserSettings(const UserSettings&) = delete;
    UserSettings& operator=(const UserSettings&) = delete;
    
    QString m_apiKey;
    bool m_isFirstBoot;
    QList<RoleInfo> m_roleList;
    QString m_version;
};

#endif // USERSETTINGS_H