cmake_minimum_required(VERSION 3.16)
project(Mosuiapp VERSION ${MOSUI_VERSION} LANGUAGES CXX)

find_package(Qt6 REQUIRED COMPONENTS Core Qml Quick)
qt_standard_project_setup(REQUIRES 6.5)
set(QT_QML_MODULE_IMPORT_PATH ${LIBRARY_SHARED_OUTPUT_DIRECTORY} CACHE STRING "QML module import path" FORCE)
set(QT_QML_OUTPUT_DIRECTORY ${LIBRARY_SHARED_OUTPUT_DIRECTORY} CACHE PATH "QML module output directory" FORCE)
qt_add_executable(${PROJECT_NAME})

file(GLOB QML_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "Controls/*.qml" "Controls/*/*.qml" "Tools/*.qml" "Tools/*/*.qml" "Tools/*/*/*.qml")
file(GLOB SRC_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "Tools/*/*/*.cpp" "Tools/*/*/*.h")


# 资源文件（GLOB 自动匹配，无需手动维护文件列表）
set(RES_BASE "${CMAKE_CURRENT_SOURCE_DIR}/resources")

file(GLOB RES_FILES "resources/logo.png")
qt_add_resources(${PROJECT_NAME} "res"
    PREFIX "/"
    BASE "${RES_BASE}"
    FILES ${RES_FILES}
)

file(GLOB RES_FILES "resources/html/*")
qt_add_resources(${PROJECT_NAME} "html"
    PREFIX "/"
    BASE "${RES_BASE}"
    FILES ${RES_FILES}
)

qt_add_qml_module(
    ${PROJECT_NAME}
    URI Mosuiapp
    VERSION ${MOSUI_VERSION}
    QML_FILES
        ${QML_FILES}
        Main.qml
        MenuModel.qml
    SOURCES
        main.cpp
        ${SRC_FILES}
)

target_include_directories(${PROJECT_NAME} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/Tools/TPInv/TPinvbackend
)

qt_add_shaders(${PROJECT_NAME} "shaders"
    PREFIX "/"
    FILES
        shaders/Fractal_Land.vert
        shaders/Fractal_Land.frag
        shaders/Hyperkart.vert
        shaders/Hyperkart.frag
)


# 链接库
target_link_libraries(${PROJECT_NAME} PRIVATE
    MosuiBasic
    Qt6::Core
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::WebView
    Qt6::Graphs
    Qt6::Charts
    $<$<BOOL:${Qt6WebEngineQuick_FOUND}>:Qt6::WebEngineQuick>
    Qt6::Core5Compat
)
 
# QML 模块搜索路径
target_compile_definitions(${PROJECT_NAME} PRIVATE
    QML_IMPORT_PATH="${LIBRARY_SHARED_OUTPUT_DIRECTORY}"
    $<$<BOOL:${Qt6WebEngineQuick_FOUND}>:HAS_QT_WEBENGINE>
)

if(UNIX AND NOT APPLE)
    set_target_properties(${PROJECT_NAME} PROPERTIES
        BUILD_RPATH "${LIBRARY_SHARED_OUTPUT_DIRECTORY}"
        INSTALL_RPATH "$ORIGIN"
    )
endif()

