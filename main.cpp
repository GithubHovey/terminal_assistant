#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QUrl>
#include <QQuickStyle>
#include <QFontDatabase>
#include "src/backend/logger/Logger.h"
#include "src/backend/radio/RadioConfig.h"
#include "src/backend/character/CharacterManager.h"
#include "src/backend/image/ImageProcessor.h"
#include "src/backend/python/PythonRunner.h"

using namespace Qt::StringLiterals;

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    
    QQuickStyle::setStyle("Basic");
    
    QFontDatabase::addApplicationFont(":/App/src/frontend/fonts/SourceHanSansCN-Medium-2.otf");
    
    QFont font("Source Han Sans CN");
    font.setPixelSize(14);
    app.setFont(font);
    
    QQmlApplicationEngine engine;
    
    RadioConfig radioConfig;
    radioConfig.loadConfig();
    engine.rootContext()->setContextProperty("radioConfig", &radioConfig);
    
    CharacterManager characterManager;
    characterManager.loadConfig();
    engine.rootContext()->setContextProperty("characterManager", &characterManager);
    
    ImageProcessor imageProcessor;
    engine.rootContext()->setContextProperty("imageProcessor", &imageProcessor);
    
    PythonRunner pythonRunner;
    engine.rootContext()->setContextProperty("pythonRunner", &pythonRunner);
    
    engine.rootContext()->setContextProperty("logger", &Logger::instance());
    
    engine.load(QUrl(u"qrc:/App/src/frontend/qml/Main.qml"_s));
    
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }
    
    Logger::instance().logInfo("早上好索拉里斯！");
    
    return app.exec();
}
