cmake_minimum_required(VERSION 3.16)
project(Mosuiapp VERSION ${MOSUI_VERSION} LANGUAGES CXX)

find_package(Qt6 REQUIRED COMPONENTS Core Qml Quick)
qt_standard_project_setup(REQUIRES 6.5)
set(QT_QML_MODULE_IMPORT_PATH ${LIBRARY_SHARED_OUTPUT_DIRECTORY} CACHE STRING "QML module import path" FORCE)
set(QT_QML_OUTPUT_DIRECTORY ${LIBRARY_SHARED_OUTPUT_DIRECTORY} CACHE PATH "QML module output directory" FORCE)
qt_add_executable(${PROJECT_NAME})

qt_add_qml_module(
    ${PROJECT_NAME}
    URI Mosuiapp
    VERSION ${MOSUI_VERSION}
    QML_FILES Main.qml
    SOURCES main.cpp
)

# 链接库
target_link_libraries(${PROJECT_NAME} PRIVATE
    MosuiBasic
    Qt6::Core
    Qt6::Qml
    Qt6::Quick
)
 
# QML 模块搜索路径
target_compile_definitions(${PROJECT_NAME} PRIVATE
    QML_IMPORT_PATH="${LIBRARY_SHARED_OUTPUT_DIRECTORY}"
)

