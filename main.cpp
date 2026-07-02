#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QUrl>

using namespace Qt::StringLiterals;

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    
    QQmlApplicationEngine engine;
    
    engine.loadFromModule(u"App"_s, u"Main"_s);
    
    return app.exec();
}