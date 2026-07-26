#ifndef BASICCONFIG_H
#define BASICCONFIG_H

#include <QObject>
#include <QVariantMap>

class BasicConfig : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString bootlogoPath READ bootlogoPath NOTIFY bootlogoPathChanged)

public:
    explicit BasicConfig(QObject *parent = nullptr);
    ~BasicConfig() override;

    Q_INVOKABLE bool loadConfig();
    Q_INVOKABLE bool saveConfig();
    Q_INVOKABLE QVariantMap getConfig() const;
    Q_INVOKABLE void setConfig(const QVariantMap &config);
    Q_INVOKABLE bool replaceBootlogo(const QString &srcPath, double offsetX, double offsetY, double scale, bool speedUp);

    QString bootlogoPath() const;
    void setBasePath(const QString &path);
    QString basePath() const;

signals:
    void configLoaded();
    void configSaved();
    void configError(const QString &error);
    void bootlogoPathChanged();

private:
    QVariantMap m_config;
    QString m_basePath;
};

#endif // BASICCONFIG_H