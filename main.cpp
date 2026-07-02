#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QUrl>
#include <QQuickStyle>
#include <QFontDatabase>
#include "src/backend/logger/Logger.h"

using namespace Qt::StringLiterals;

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    
    QQuickStyle::setStyle("Basic");
    
    QFontDatabase::addApplicationFont(":/qt/qml/App/src/frontend/fonts/SourceHanSansCN-Medium-2.otf");
    
    QFont font("Source Han Sans CN");
    font.setPixelSize(14);
    app.setFont(font);
    
    QQmlApplicationEngine engine;
    
    engine.rootContext()->setContextProperty("logger", &Logger::instance());
    
    engine.loadFromModule(u"App"_s, u"Main"_s);
    
    Logger::instance().logInfo("早上好索拉里斯！");
    
    return app.exec();
}