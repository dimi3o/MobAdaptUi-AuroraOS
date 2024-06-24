#include <auroraapp.h>
#include <QtQuick>
#include <QtQml>
#include "stringobject.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> application(Aurora::Application::application(argc, argv));
    application->setOrganizationName(QStringLiteral("ru.bmstu"));
    application->setApplicationName(QStringLiteral("MobAdaptUi"));

    //----second way CPPtoQML
    qmlRegisterType<StringObject>("StringObject", 1, 0, "StringObject");

    QScopedPointer<QQuickView> view(Aurora::Application::createView());
    view->setSource(Aurora::Application::pathTo(QStringLiteral("qml/MobAdaptUi.qml")));

    //----first way CPPtoQML
//    auto stringObject = new StringObject(application.data());
//    view->rootContext()->setContextProperty("stringObject", stringObject);

    view->show();

    return application->exec();
}
