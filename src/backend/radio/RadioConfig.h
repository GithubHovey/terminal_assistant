#ifndef RADIOCONFIG_H
#define RADIOCONFIG_H

#include <QObject>
#include <QVariantMap>

class RadioConfig : public QObject
{
    Q_OBJECT

public:
    explicit RadioConfig(QObject *parent = nullptr);
    ~RadioConfig() override;

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

#endif // RADIOCONFIG_H