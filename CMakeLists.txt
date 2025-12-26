cmake_minimum_required(VERSION 3.1)

project(vf-debugger LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(VfDebugger_VERSION_MAJOR "0")
set(VfDebugger_VERSION_MINOR "0")
set(VfDebugger_VERSION_PATCH "1")
set(PROJECT_VERSION "${VfDebugger_VERSION_MAJOR}.${VfDebugger_VERSION_MINOR}.${VfDebugger_VERSION_PATCH}")

include(FeatureSummary)
include(GNUInstallDirs)

find_package(Qt5 COMPONENTS Quick Core Qml Sql Network CONFIG REQUIRED)
find_package(VeinFramework REQUIRED)
find_package(SortFilterProxyModel REQUIRED)

file(GLOB SOURCES
    ${PROJECT_SOURCE_DIR}/*.cpp
    )

file(GLOB HEADERS
    ${PROJECT_SOURCE_DIR}/*.h
    )

file(GLOB RESOURCES
    ${PROJECT_SOURCE_DIR}/*.qrc
    )

add_executable(VfDebugger 
    ${SOURCES}
    ${HEADERS}
    ${RESOURCES}
    )

target_link_libraries(VfDebugger 
    PRIVATE
    Qt5::Core
    Qt5::Qml
    Qt5::Sql
    Qt5::Network
    Qt5::Quick
    Zera::VfEvent
    Zera::VfComponent
    Zera::VfNet2
    Zera::VfQml
    SortFilterProxyModel::SortFilterProxyModel
    )

target_include_directories(VfDebugger 
    PUBLIC
    $<BUILD_INTERFACE:${MY_LIBRARY_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/VfDebugger>
    ${CMAKE_CURRENT_SOURCE_DIR}
    )

install(TARGETS VfDebugger
    EXPORT VfDebuggerExport
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
