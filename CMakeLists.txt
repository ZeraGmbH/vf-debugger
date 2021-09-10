cmake_minimum_required(VERSION 3.1)

#set project name and language
project(vf-debugger LANGUAGES CXX)

#Automoc and RCC ON. Needed in QT projects
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
#C++ 11 Flag
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

#Set project Version
set(VfDebugger_VERSION_MAJOR "0")
set(VfDebugger_VERSION_MINOR "0")
set(VfDebugger_VERSION_PATCH "1")

set(PROJECT_VERSION "${VfDebugger_VERSION_MAJOR}.${VfDebugger_VERSION_MINOR}.${VfDebugger_VERSION_PATCH}")

#Adding cmake functions like feature_summary()
include(FeatureSummary)
include(GNUInstallDirs)

#Find dependecies
find_package(Qt5 COMPONENTS Quick Core Qml Sql Network CONFIG REQUIRED)
find_package(VfEvent REQUIRED)
find_package(VfHelpers REQUIRED)
find_package(VfComponent REQUIRED)
find_package(VfStorageHash REQUIRED)
find_package(VfQml REQUIRED)
find_package(VfNet2 REQUIRED)
#find_package(VfLogger REQUIRED)
find_package(VfCpp REQUIRED)


#sum up project Files 
file(GLOB APP_SOURCES
    ${PROJECT_SOURCE_DIR}/*.cpp
    )

file(GLOB APP_HEADERS
    ${PROJECT_SOURCE_DIR}/*.h
    )

file(GLOB APP_RESOURCES
    ${PROJECT_SOURCE_DIR}/*.qrc
    )

##include 3RDPARTY sources in seperate file
include(${PROJECT_SOURCE_DIR}/3rdparty/include3rdParty.cmake)

##Sum up all properties
set(SOURCES   ${APP_SOURCES} ${3RDPARTY_SOURCES}   )
set(HEADERS   ${APP_HEADERS} ${3RDPARTY_HEADERS}    )
set(RESOURCES ${APP_RESOURCES} ${3RDPARTY_RESOURCES})

#create executable
add_executable(VfDebugger 
    ${SOURCES}
    ${HEADERS}
    ${RESOURCES}
    )

#link dependencies
target_link_libraries(VfDebugger 
    PRIVATE
    Qt5::Core
    Qt5::Qml
    Qt5::Sql
    Qt5::Network
    Qt5::Quick
    VeinMeta::VfEvent
    VeinMeta::VfHelpers
    VeinMeta::VfComponent
    VeinMeta::VfStorageHash
    VeinMeta::VfQml
    VeinMeta::VfNet2
    VeinMeta::VfCpp
    )	





# announce headers - target perspective
target_include_directories(VfDebugger 
    PUBLIC
    $<BUILD_INTERFACE:${MY_LIBRARY_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/VfDebugger>
    PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    )



#install VfDebugger to bin 
install(TARGETS VfDebugger
    EXPORT VfDebuggerExport
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )

# spawn out some info on configuration
feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)






