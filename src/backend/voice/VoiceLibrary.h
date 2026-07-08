#ifndef VOICELIBRARY_H
#define VOICELIBRARY_H

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QList>

struct VoiceItem {
    QString voiceId;
    QString name;
    QString characterName;
    QString createdAt;
    
    QVariantMap toMap() const;
    static VoiceItem fromMap(const QVariantMap &map);
};

class VoiceLibrary : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList voiceList READ getVoiceList NOTIFY voiceListChanged)
    Q_PROPERTY(int voiceCount READ voiceCount NOTIFY voiceListChanged)
    Q_PROPERTY(QVariantList cloudVoiceList READ getCloudVoiceList NOTIFY cloudVoiceListChanged)

public:
    explicit VoiceLibrary(QObject *parent = nullptr);
    ~VoiceLibrary() override;

    bool loadConfig();
    bool saveConfig();

    Q_INVOKABLE QVariantList getVoiceList() const;
    Q_INVOKABLE int voiceCount() const;
    Q_INVOKABLE void addVoice(const QString &voiceId, const QString &name, const QString &characterName);
    Q_INVOKABLE void removeVoice(int index);

    Q_INVOKABLE QString voiceLibraryDir() const;
    Q_INVOKABLE QString materialsDir() const;
    Q_INVOKABLE QString optionsFilePath() const;
    Q_INVOKABLE QVariantList getCharacterOptions() const;
    Q_INVOKABLE QString voiceDir(const QString &characterName) const;
    Q_INVOKABLE bool ensureVoiceDir(const QString &characterName);
    Q_INVOKABLE QString importVoiceMaterial(const QString &srcPath, const QString &characterName);
    Q_INVOKABLE QString voiceMaterialPath(const QString &characterName) const;

    Q_INVOKABLE QVariantList getCloudVoiceList() const;
    Q_INVOKABLE void updateCloudVoices(const QString &jsonString);
    Q_INVOKABLE int cloudVoiceCount() const;

signals:
    void voiceListChanged();
    void cloudVoiceListChanged();
    void importError(const QString &error);

private:
    QList<VoiceItem> m_voices;
    QVariantList m_cloudVoices;
    QString configFilePath() const;
    QString cloudConfigFilePath() const;
    bool loadCloudConfig();
    bool saveCloudConfig();
};

#endif // VOICELIBRARY_H
