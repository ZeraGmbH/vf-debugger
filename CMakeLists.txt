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
find_package(VfCpp REQUIRED)

file(GLOB APP_SOURCES
    ${PROJECT_SOURCE_DIR}/*.cpp
    )

file(GLOB APP_HEADERS
    ${PROJECT_SOURCE_DIR}/*.h
    )

file(GLOB APP_RESOURCES
    ${PROJECT_SOURCE_DIR}/*.qrc
    )

include(${PROJECT_SOURCE_DIR}/3rdparty/include3rdParty.cmake)

set(SOURCES   ${APP_SOURCES} ${3RDPARTY_SOURCES}   )
set(HEADERS   ${APP_HEADERS} ${3RDPARTY_HEADERS}    )
set(RESOURCES ${APP_RESOURCES} ${3RDPARTY_RESOURCES})

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
    Zera::VfHelpers
    Zera::VfComponent
    Zera::VfStorageHash
    Zera::VfNet2
    Zera::VfQml
    VeinMeta::VfCpp
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
