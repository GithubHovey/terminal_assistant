#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QUrl>
#include <QQuickStyle>
#include <QFontDatabase>

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
    
    engine.loadFromModule(u"App"_s, u"Main"_s);
    
    return app.exec();
}