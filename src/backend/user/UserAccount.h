#ifndef USERACCOUNT_H
#define USERACCOUNT_H

#include <QObject>
#include <QString>

class UserAccount : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString apiKey READ apiKey WRITE setApiKey NOTIFY apiKeyChanged)
    Q_PROPERTY(QString workspaceId READ workspaceId WRITE setWorkspaceId NOTIFY workspaceIdChanged)

public:
    explicit UserAccount(QObject *parent = nullptr);
    ~UserAccount() override;

    QString apiKey() const;
    void setApiKey(const QString &apiKey);

    QString workspaceId() const;
    void setWorkspaceId(const QString &workspaceId);

    Q_INVOKABLE bool loadConfig();
    Q_INVOKABLE bool saveConfig();

signals:
    void apiKeyChanged();
    void workspaceIdChanged();

private:
    QString m_apiKey;
    QString m_workspaceId;

    QString configDirPath() const;
    QString configFilePath() const;
};

#endif // USERACCOUNT_H
