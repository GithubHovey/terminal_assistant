#include "UserAccount.h"
#include <QFile>
#include <QDir>
#include <QJsonDocument>
#include <QJsonObject>
#include <QCoreApplication>

UserAccount::UserAccount(QObject *parent)
    : QObject(parent)
{
}

UserAccount::~UserAccount() = default;

QString UserAccount::apiKey() const
{
    return m_apiKey;
}

void UserAccount::setApiKey(const QString &apiKey)
{
    if (m_apiKey != apiKey) {
        m_apiKey = apiKey;
        emit apiKeyChanged();
    }
}

QString UserAccount::workspaceId() const
{
    return m_workspaceId;
}

void UserAccount::setWorkspaceId(const QString &workspaceId)
{
    if (m_workspaceId != workspaceId) {
        m_workspaceId = workspaceId;
        emit workspaceIdChanged();
    }
}

QString UserAccount::configDirPath() const
{
    return QCoreApplication::applicationDirPath();
}

QString UserAccount::configFilePath() const
{
    return configDirPath() + "/config.json";
}

bool UserAccount::loadConfig()
{
    QString path = configFilePath();
    QFile file(path);
    if (!file.exists()) {
        return true;
    }

    if (!file.open(QIODevice::ReadOnly)) {
        return false;
    }

    QByteArray data = file.readAll();
    file.close();

    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(data, &error);
    if (error.error != QJsonParseError::NoError) {
        return false;
    }

    QJsonObject obj = doc.object();
    if (obj.contains("apikey")) {
        m_apiKey = obj.value("apikey").toString();
    }
    if (obj.contains("workspace_id")) {
        m_workspaceId = obj.value("workspace_id").toString();
    }

    return true;
}

bool UserAccount::saveConfig()
{
    QDir dir(configDirPath());
    if (!dir.exists()) {
        if (!dir.mkpath(".")) {
            return false;
        }
    }

    QJsonObject obj;
    obj["apikey"] = m_apiKey;
    obj["workspace_id"] = m_workspaceId;

    QJsonDocument doc(obj);

    QFile file(configFilePath());
    if (!file.open(QIODevice::WriteOnly)) {
        return false;
    }

    file.write(doc.toJson(QJsonDocument::Indented));
    file.close();
    return true;
}
