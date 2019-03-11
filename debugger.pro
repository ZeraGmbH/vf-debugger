TEMPLATE = app

TARGET = vf-debugger

#dependencies
VEIN_DEP_EVENT = 1
VEIN_DEP_COMP = 1
VEIN_DEP_NET2 = 1
VEIN_DEP_TCP2 = 1
VEIN_DEP_HELPER = 1
VEIN_DEP_QML = 1

exists( ../../vein-framework.pri ) {
  include(../../vein-framework.pri)
}

unix {
    target.path = /usr/bin
}

QT += qml quick

SOURCES += main.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

contains(ANDROID_TARGET_ARCH,armeabi-v7a) {
    ANDROID_EXTRA_LIBS = \
        $$PWD/../../libs-android/libvein-event.so \
        $$PWD/../../libs-android/libvein-component.so \
        /work/downloads/protobuf-2.5.0/build/lib/libprotobuf.so \
        $$PWD/../../libs-android/libxiqnet.so \
        $$PWD/../../libs-android/libvein-framework-protobuf.so \
        $$PWD/../../libs-android/libvein-net.so \
        $$PWD/../../libs-android/libqml-veinentity.so \
        $$PWD/../../libs-android/libvein-hash.so
}

isEmpty(SORT_FILTER_PROXY_PRI) {
  error("Set SORT_FILTER_PROXY_PRI to the .pri file of qml SortFilterProxyModel")
  #clone from: https://github.com/oKcerG/SortFilterProxyModel
  #(example) in QtCreator add qmake argument: SORT_FILTER_PROXY_PRI=<some path ...>/SortFilterProxyModel/SortFilterProxyModel.pri
}
include($$SORT_FILTER_PROXY_PRI)
