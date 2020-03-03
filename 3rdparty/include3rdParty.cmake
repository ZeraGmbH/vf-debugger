
# This file needs to be included from CMakeLists.txt in debugger
# It has no stand alone functions 

##3dPaerty includes
include_directories(${PROJECT_SOURCE_DIR}/3rdparty/SortFilterProxyModel)

##SortFilterProxyModel

file(GLOB SORTF_HEADERS
    ${PROJECT_SOURCE_DIR}/3rdparty/SortFilterProxyModel/*.h    	
    )

file(GLOB SORTF_SOURCES
    ${PROJECT_SOURCE_DIR}/3rdparty/SortFilterProxyModel/*.cpp
    )

file(GLOB SORTF_RESOURCES
    ${PROJECT_SOURCE_DIR}/3rdparty/SortFilterProxyModel/*.qrc
    )

# sum up 3rdParty sources
set(3RDPARTY_SOURCES   ${QNANO_SOURCES} ${JSONSET_SOURCES} ${SORTF_SOURCES})
set(3RDPARTY_HEADERS   ${QNANO_HEADERS} ${JSONSET_HEADERS} ${SORTF_HEADERS})
set(3RDPARTY_RESOURCES ${QNANO_RESOURCES} ${JSONSET_RESOURCES} ${SORTF_RESOURCES})


