#ifndef AGENTCONFIG_H
#define AGENTCONFIG_H

#include <QObject>
#include <QVariantMap>

class AgentConfig : public QObject
{
    Q_OBJECT

public:
    explicit AgentConfig(QObject *parent = nullptr);
    ~AgentConfig() override;

    Q_INVOKABLE bool loadConfig();
    Q_INVOKABLE bool saveConfig();
    Q_INVOKABLE QVariantMap getConfig() const;
    Q_INVOKABLE void setConfig(const QVariantMap &config);

signals:
    void configLoaded();
    void configSaved();
    void configError(const QString &error);

private:
    QVariantMap m_config;
};

#endif // AGENTCONFIG_H