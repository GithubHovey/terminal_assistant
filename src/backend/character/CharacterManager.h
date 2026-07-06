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

public:
    explicit CharacterManager(QObject *parent = nullptr);
    ~CharacterManager() override;

    bool loadConfig();
    bool saveConfig();

    Q_INVOKABLE QVariantList getRoleList() const;
    Q_INVOKABLE int roleCount() const;
    Q_INVOKABLE void addRole(const QString &name);
    Q_INVOKABLE void removeRole(int index);
    Q_INVOKABLE void updateRoleName(int index, const QString &name);
    Q_INVOKABLE void updateRoleEnglishName(int index, const QString &englishName);
    Q_INVOKABLE void updateRoleAgentId(int index, const QString &agentId);
    Q_INVOKABLE void updateRoleAgentUrl(int index, const QString &agentUrl);
    Q_INVOKABLE void updateRolePrompt(int index, const QString &prompt);

    Q_INVOKABLE QString characterDir() const;
    Q_INVOKABLE QString roleDir(const QString &name) const;
    Q_INVOKABLE bool ensureRoleDir(const QString &name);

    Q_INVOKABLE QString importChatBg(const QString &srcFilePath, const QString &name);
    Q_INVOKABLE bool removeChatBg(const QString &name);
    Q_INVOKABLE QString importVoiceMaterial(const QString &srcFilePath, const QString &name);
    Q_INVOKABLE QString importPreviewAudio(const QString &srcFilePath, const QString &name);

    Q_INVOKABLE QString avatarPath(const QString &name) const;
    Q_INVOKABLE QString avatarBinPath(const QString &name) const;
    Q_INVOKABLE QString chatBgPath(const QString &name) const;
    Q_INVOKABLE QString voiceMaterialPath(const QString &name) const;
    Q_INVOKABLE QString previewAudioPath(const QString &name) const;

    Q_INVOKABLE int avatarVersion() const;
    Q_INVOKABLE void incrementAvatarVersion();

signals:
    void roleListChanged();
    void importError(const QString &error);
    void avatarVersionChanged();

private:
    QList<RoleInfo> m_roles;
    int m_avatarVersion = 0;
    QString configFilePath() const;
    int nextId() const;
    QString findEnglishNameByName(const QString &name) const;
};

#endif // CHARACTERMANAGER_H
