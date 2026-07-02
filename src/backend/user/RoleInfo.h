#ifndef ROLEINFO_H
#define ROLEINFO_H

#include <QString>

class RoleInfo
{
public:
    RoleInfo();
    RoleInfo(const QString &name, int id);
    ~RoleInfo();

    QString name() const;
    void setName(const QString &name);

    int id() const;
    void setId(int id);

    bool isUser() const;
    void setIsUser(bool isUser);

    QString avatarBinPath() const;
    void setAvatarBinPath(const QString &path);

    QString agentId() const;
    void setAgentId(const QString &agentId);

    QString voiceCloneId() const;
    void setVoiceCloneId(const QString &voiceCloneId);

    QString voiceCloneMaterialPath() const;
    void setVoiceCloneMaterialPath(const QString &path);

private:
    QString m_name;
    int m_id;
    bool m_isUser;
    QString m_avatarBinPath;
    QString m_agentId;
    QString m_voiceCloneId;
    QString m_voiceCloneMaterialPath;
};

#endif // ROLEINFO_H