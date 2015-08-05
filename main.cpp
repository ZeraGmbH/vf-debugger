#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QTimer>

#include <ve_eventhandler.h>
#include <vn_networksystem.h>
#include <vn_tcpsystem.h>
#include <veinqml.h>
#include <veinqmlwrapper.h>

#include <QDataStream>
#include <QList>
#include <QMetaType>

int main(int argc, char *argv[])
{
  qRegisterMetaTypeStreamOperators<QList<double> >("QList<double>");
  qRegisterMetaTypeStreamOperators<QList<int> >("QList<int>");
  qRegisterMetaTypeStreamOperators<QList<QString> >("QList<QString>");

  QString categoryLoggingFormat = "%{if-debug}DD%{endif}%{if-warning}WW%{endif}%{if-critical}EE%{endif}%{if-fatal}FATAL%{endif} %{category} %{message}";

  qSetMessagePattern(categoryLoggingFormat);

  QGuiApplication app(argc, argv);

  QQmlApplicationEngine engine;


  //register QML type
  VeinApiQml::QmlWrapper::registerTypes();

  VeinEvent::EventHandler* evHandler =new VeinEvent::EventHandler(&app);
  VeinNet::NetworkSystem *netSystem = new VeinNet::NetworkSystem(&app);
  VeinNet::TcpSystem *tcpSystem = new VeinNet::TcpSystem(&app);
  VeinApiQml::VeinQml *qmlApi = new VeinApiQml::VeinQml(&app);

  VeinApiQml::VeinQml::setStaticInstance(qmlApi);
  QList<VeinEvent::EventSystem*> subSystems;

  QObject::connect(qmlApi,&VeinApiQml::VeinQml::sigStateChanged, [&](VeinApiQml::VeinQml::ConnectionState t_state){
    if(t_state == VeinApiQml::VeinQml::ConnectionState::VQ_LOADED)
    {
      engine.load(QUrl(QStringLiteral("qrc:/main-debugger.qml")));
    }
    else if(t_state == VeinApiQml::VeinQml::ConnectionState::VQ_ERROR)
    {
      engine.quit();
    }
  });

  netSystem->setOperationMode(VeinNet::NetworkSystem::VNOM_PASS_THROUGH);


  subSystems.append(netSystem);
  subSystems.append(tcpSystem);
  subSystems.append(qmlApi);

  evHandler->setSubsystems(subSystems);

  tcpSystem->connectToServer("127.0.0.1", 8008);

  QTimer *timer = new QTimer(&app);
  timer->setSingleShot(true);

  QObject::connect(timer, &QTimer::timeout, [=]() {
    qmlApi->setRequiredIds(QList<int>()<<0);

    timer->deleteLater();
  });

  timer->start(0);
  return app.exec();
}
