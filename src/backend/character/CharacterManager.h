#ifndef CHARACTERMANAGER_H
#define CHARACTERMANAGER_H

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QList>
#include "src/backend/user/RoleInfo.h"

class CharacterManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList roleList READ getRoleList NOTIFY roleListChanged)
    Q_PROPERTY(int roleCount READ roleCount NOTIFY roleListChanged)
    Q_PROPERTY(int avatarVersion READ avatarVersion NOTIFY avatarVersionChanged)
    Q_PROPERTY(int chatBgVersion READ chatBgVersion NOTIFY chatBgVersionChanged)

public:
    explicit CharacterManager(QObject *parent = nullptr);
    ~CharacterManager() override;

    bool loadConfig();
    bool saveConfig();

    Q_INVOKABLE QVariantList getRoleList() const;
    Q_INVOKABLE int roleCount() const;
    Q_INVOKABLE void addRole(const QString &name, const QString &englishName);
    Q_INVOKABLE void removeRole(int index);
    Q_INVOKABLE void updateRoleName(int index, const QString &name);
    Q_INVOKABLE void updateRoleAgentId(int index, const QString &agentId);
    Q_INVOKABLE void updateRoleAgentUrl(int index, const QString &agentUrl);
    Q_INVOKABLE void updateRolePrompt(int index, const QString &prompt);
    Q_INVOKABLE void updateRoleVoiceCloneId(int index, const QString &voiceCloneId);

    Q_INVOKABLE QString characterDir() const;
    Q_INVOKABLE QString roleDir(const QString &name) const;
    Q_INVOKABLE QString userDir() const;
    Q_INVOKABLE QString userAvatarPath() const;
    Q_INVOKABLE bool ensureRoleDir(const QString &name);
    Q_INVOKABLE bool ensureUserDir();

    Q_INVOKABLE QString importChatBg(const QString &srcFilePath, const QString &name);
    Q_INVOKABLE bool removeChatBg(const QString &name);
    Q_INVOKABLE QString importVoiceMaterial(const QString &srcFilePath, const QString &name);
    Q_INVOKABLE QString importPreviewAudio(const QString &srcFilePath, const QString &name);

    Q_INVOKABLE QString avatarPath(const QString &name) const;
    Q_INVOKABLE QString avatarBinPath(const QString &name) const;
    Q_INVOKABLE QString chatBgPath(const QString &name) const;
    Q_INVOKABLE QString chatBgBinPath(const QString &name) const;
    Q_INVOKABLE bool chatBgExists(const QString &name) const;
    Q_INVOKABLE QString voiceMaterialPath(const QString &name) const;
    Q_INVOKABLE QString previewAudioPath(const QString &name) const;

    Q_INVOKABLE int avatarVersion() const;
    Q_INVOKABLE void incrementAvatarVersion();
    Q_INVOKABLE int chatBgVersion() const;
    Q_INVOKABLE void incrementChatBgVersion();

    void setBasePath(const QString &path);
    QString basePath() const;

signals:
    void roleListChanged();
    void importError(const QString &error);
    void avatarVersionChanged();
    void chatBgVersionChanged();

private:
    QList<RoleInfo> m_roles;
    int m_avatarVersion = 0;
    int m_chatBgVersion = 0;
    QString m_basePath;
    QString configFilePath() const;
    int nextId() const;
    QString findEnglishNameByName(const QString &name) const;
};

#endif // CHARACTERMANAGER_H
