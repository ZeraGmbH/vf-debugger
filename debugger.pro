TEMPLATE = app

TARGET = vf-debugger

#dependencies
VEIN_DEP_EVENT = 1
VEIN_DEP_COMP = 1
VEIN_DEP_PROTOBUF = 1
VEIN_DEP_NET = 1
VEIN_DEP_TCP = 1
VEIN_DEP_HELPER = 1
VEIN_DEP_QML = 1

exists( ../../project-paths.pri ) {
  include(../../project-paths.pri)
}

QT += qml quick

SOURCES += main.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)
