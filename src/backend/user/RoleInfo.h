#ifndef ROLEINFO_H
#define ROLEINFO_H

#include <QString>
#include <QVariantMap>

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

    QString englishName() const;
    void setEnglishName(const QString &englishName);

    QString agentId() const;
    void setAgentId(const QString &agentId);

    QString agentUrl() const;
    void setAgentUrl(const QString &agentUrl);

    QString voiceCloneId() const;
    void setVoiceCloneId(const QString &voiceCloneId);

    QString prompt() const;
    void setPrompt(const QString &prompt);

    QVariantMap toMap() const;
    static RoleInfo fromMap(const QVariantMap &map);

private:
    QString m_name;
    int m_id;
    bool m_isUser;
    QString m_englishName;
    QString m_agentId;
    QString m_agentUrl;
    QString m_voiceCloneId;
    QString m_prompt;
};

#endif // ROLEINFO_H