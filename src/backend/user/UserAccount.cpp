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

int UserAccount::motorSpeed() const
{
    return m_motorSpeed;
}

void UserAccount::setMotorSpeed(int speed)
{
    speed = qBound(0, speed, 100);
    if (m_motorSpeed != speed) {
        m_motorSpeed = speed;
        emit motorSpeedChanged();
    }
}

int UserAccount::motorTime() const
{
    return m_motorTime;
}

void UserAccount::setMotorTime(int time)
{
    time = qMax(0, time);
    if (m_motorTime != time) {
        m_motorTime = time;
        emit motorTimeChanged();
    }
}

int UserAccount::chatBgOpacity() const
{
    return m_chatBgOpacity;
}

void UserAccount::setChatBgOpacity(int opacity)
{
    opacity = qBound(0, opacity, 255);
    if (m_chatBgOpacity != opacity) {
        m_chatBgOpacity = opacity;
        emit chatBgOpacityChanged();
    }
}

QString UserAccount::configDirPath() const
{
    if (m_basePath.isEmpty()) {
        return QString();
    }
    return m_basePath;
}

QString UserAccount::configFilePath() const
{
    QString dir = configDirPath();
    if (dir.isEmpty()) {
        return QString();
    }
    return dir + "/config.json";
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
    if (obj.contains("motor_speed")) {
        m_motorSpeed = obj.value("motor_speed").toInt();
    }
    if (obj.contains("motor_time")) {
        m_motorTime = obj.value("motor_time").toInt();
    }
    if (obj.contains("chat_bg_opacity")) {
        m_chatBgOpacity = obj.value("chat_bg_opacity").toInt();
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
    obj["motor_speed"] = m_motorSpeed;
    obj["motor_time"] = m_motorTime;
    obj["chat_bg_opacity"] = m_chatBgOpacity;

    QJsonDocument doc(obj);

    QFile file(configFilePath());
    if (!file.open(QIODevice::WriteOnly)) {
        return false;
    }

    file.write(doc.toJson(QJsonDocument::Indented));
    file.close();
    return true;
}

void UserAccount::setBasePath(const QString &path)
{
    m_basePath = path;
    m_apiKey.clear();
    m_workspaceId.clear();
    m_motorSpeed = 0;
    m_motorTime = 0;
    m_chatBgOpacity = 255;
    if (!path.isEmpty()) {
        loadConfig();
    }
    emit apiKeyChanged();
    emit workspaceIdChanged();
    emit motorSpeedChanged();
    emit motorTimeChanged();
    emit chatBgOpacityChanged();
}

QString UserAccount::basePath() const
{
    return m_basePath;
}
