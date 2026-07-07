#ifndef USERACCOUNT_H
#define USERACCOUNT_H

#include <QObject>
#include <QString>

class UserAccount : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString apiKey READ apiKey WRITE setApiKey NOTIFY apiKeyChanged)

public:
    explicit UserAccount(QObject *parent = nullptr);
    ~UserAccount() override;

    QString apiKey() const;
    void setApiKey(const QString &apiKey);

    Q_INVOKABLE bool loadConfig();
    Q_INVOKABLE bool saveConfig();

signals:
    void apiKeyChanged();

private:
    QString m_apiKey;

    QString configDirPath() const;
    QString configFilePath() const;
};

#endif // USERACCOUNT_H
