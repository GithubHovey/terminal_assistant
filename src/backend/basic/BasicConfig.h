#ifndef BASICCONFIG_H
#define BASICCONFIG_H

#include <QObject>
#include <QVariantMap>

class BasicConfig : public QObject
{
    Q_OBJECT

public:
    explicit BasicConfig(QObject *parent = nullptr);
    ~BasicConfig() override;

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

#endif // BASICCONFIG_H