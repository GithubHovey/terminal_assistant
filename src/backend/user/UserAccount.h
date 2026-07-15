#ifndef USERACCOUNT_H
#define USERACCOUNT_H

#include <QObject>
#include <QString>

class UserAccount : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString apiKey READ apiKey WRITE setApiKey NOTIFY apiKeyChanged)
    Q_PROPERTY(QString workspaceId READ workspaceId WRITE setWorkspaceId NOTIFY workspaceIdChanged)
    Q_PROPERTY(int motorSpeed READ motorSpeed WRITE setMotorSpeed NOTIFY motorSpeedChanged)
    Q_PROPERTY(int motorTime READ motorTime WRITE setMotorTime NOTIFY motorTimeChanged)
    Q_PROPERTY(int chatBgOpacity READ chatBgOpacity WRITE setChatBgOpacity NOTIFY chatBgOpacityChanged)

public:
    explicit UserAccount(QObject *parent = nullptr);
    ~UserAccount() override;

    QString apiKey() const;
    void setApiKey(const QString &apiKey);

    QString workspaceId() const;
    void setWorkspaceId(const QString &workspaceId);

    int motorSpeed() const;
    void setMotorSpeed(int speed);

    int motorTime() const;
    void setMotorTime(int time);

    int chatBgOpacity() const;
    void setChatBgOpacity(int opacity);

    Q_INVOKABLE bool loadConfig();
    Q_INVOKABLE bool saveConfig();

    void setBasePath(const QString &path);
    QString basePath() const;

signals:
    void apiKeyChanged();
    void workspaceIdChanged();
    void motorSpeedChanged();
    void motorTimeChanged();
    void chatBgOpacityChanged();

private:
    QString m_apiKey;
    QString m_workspaceId;
    int m_motorSpeed = 0;
    int m_motorTime = 0;
    int m_chatBgOpacity = 255;
    QString m_basePath;

    QString configDirPath() const;
    QString configFilePath() const;
};

#endif // USERACCOUNT_H
