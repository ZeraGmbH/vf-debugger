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

#include "eventstatisticsystem.h"
#include <QCommandLineParser>

QObject *getStatisticSingletonInstance(QQmlEngine *t_engine, QJSEngine *t_scriptEngine)
{
  Q_UNUSED(t_engine)
  Q_UNUSED(t_scriptEngine)

  return EventStatisticSystem::getStaticInstance();
}

int main(int argc, char *argv[])
{



  QCommandLineParser parser;


  bool loadedOnce=false;


  QString categoryLoggingFormat = "%{if-debug}DD%{endif}%{if-warning}WW%{endif}%{if-critical}EE%{endif}%{if-fatal}FATAL%{endif} %{category} %{message}";

  QStringList loggingFilters = QStringList() << QString("%1.debug=false").arg(VEIN_EVENT().categoryName()) <<
                                                QString("%1.debug=false").arg(VEIN_NET_VERBOSE().categoryName()) <<
                                                QString("%1.debug=false").arg(VEIN_NET_INTRO_VERBOSE().categoryName()) << //< Introspection logging is still enabled
                                                QString("%1.debug=false").arg(VEIN_NET_TCP_VERBOSE().categoryName()) <<
                                                QString("%1.debug=false").arg(VEIN_API_QML_VERBOSE().categoryName());



  QLoggingCategory::setFilterRules(loggingFilters.join("\n"));


  qSetMessagePattern(categoryLoggingFormat);

  QGuiApplication app(argc, argv);
  QQmlApplicationEngine engine;

  const QCommandLineOption veinip("i", "vein ip", "ip");
  parser.addOption(veinip);
  parser.process(app);

  qmlRegisterSingletonType<EventStatisticSystem>("EvStats", 1, 0, "EvStats", getStatisticSingletonInstance);
  QString ip;
  if (parser.isSet(veinip)) {
      ip = parser.value(veinip);
  }else{
      ip="127.0.0.1";
  }



  VeinEvent::EventHandler *evHandler = new VeinEvent::EventHandler(&app);
  VeinNet::NetworkSystem *netSystem = new VeinNet::NetworkSystem(&app);
  VeinNet::TcpSystem *tcpSystem = new VeinNet::TcpSystem(&app);
  VeinApiQml::VeinQml *qmlApi = new VeinApiQml::VeinQml(&app);
  EventStatisticSystem *evStats = new EventStatisticSystem(&app);
  EventStatisticSystem::setStaticInstance(evStats);

  VeinApiQml::VeinQml::setStaticInstance(qmlApi);
  QList<VeinEvent::EventSystem*> subSystems;

  QObject::connect(qmlApi,&VeinApiQml::VeinQml::sigStateChanged, [&](VeinApiQml::VeinQml::ConnectionState t_state){
    if(t_state == VeinApiQml::VeinQml::ConnectionState::VQ_LOADED && loadedOnce == false)
    {
      engine.load(QUrl(QStringLiteral("qrc:/main-debugger.qml")));
      loadedOnce=true;
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
  subSystems.append(evStats);

  evHandler->setSubsystems(subSystems);

  tcpSystem->connectToServer(ip, 12000);

  QObject::connect(tcpSystem, &VeinNet::TcpSystem::sigConnnectionEstablished, [=]() {
    qmlApi->entitySubscribeById(0);
  });

  return app.exec();
}
