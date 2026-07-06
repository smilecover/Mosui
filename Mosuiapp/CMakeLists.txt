cmake_minimum_required(VERSION 3.16)
project(Mosuiapp VERSION ${MOSUI_VERSION} LANGUAGES CXX)

find_package(Qt6 REQUIRED COMPONENTS Core Qml Quick)
qt_standard_project_setup(REQUIRES 6.5)
if(MOSUIBASIC_BUILD_STATIC)
    set(QT_QML_MODULE_IMPORT_PATH ${LIBRARY_STATIC_OUTPUT_DIRECTORY} CACHE STRING "QML module import path" FORCE)
    set(QT_QML_OUTPUT_DIRECTORY ${LIBRARY_STATIC_OUTPUT_DIRECTORY} CACHE PATH "QML module output directory" FORCE)
else()
    set(QT_QML_MODULE_IMPORT_PATH ${LIBRARY_SHARED_OUTPUT_DIRECTORY} CACHE STRING "QML module import path" FORCE)
    set(QT_QML_OUTPUT_DIRECTORY ${LIBRARY_SHARED_OUTPUT_DIRECTORY} CACHE PATH "QML module output directory" FORCE)
endif()
qt_add_executable(${PROJECT_NAME})

file(GLOB QML_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "Controls/*.qml" "Controls/*/*.qml" "Tools/*.qml" "Tools/*/*.qml" "Tools/*/*/*.qml" "Tools/*/*/*/*.qml")
file(GLOB SRC_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "Tools/*/*/*.cpp" "Tools/*/*/*.h" "src/*.cpp" "src/*.h")


# 资源文件（GLOB 自动匹配，无需手动维护文件列表）
set(RES_BASE "${CMAKE_CURRENT_SOURCE_DIR}/resources")

file(GLOB RES_FILES "resources/*.png")
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
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/Tools/TPInv/TPinvbackend
    ${CMAKE_CURRENT_SOURCE_DIR}/Tools/PLC_APP/PLCbackend
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
# 静态链接 MosuiBasic 时必须使用 whole-archive，
# 否则链接器会丢弃静态库中的资源初始化对象文件（shader 资源、QML 缓存等）
set(MOSUIAPP_QT_LIBS
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
if(MOSUIBASIC_BUILD_STATIC)
    target_link_libraries(${PROJECT_NAME} PRIVATE
        $<LINK_LIBRARY:WHOLE_ARCHIVE,MosuiBasic>
        ${MOSUIAPP_QT_LIBS}
    )
else()
    target_link_libraries(${PROJECT_NAME} PRIVATE
        MosuiBasic
        ${MOSUIAPP_QT_LIBS}
    )
endif()
 
# QML 模块搜索路径
target_compile_definitions(${PROJECT_NAME} PRIVATE
    QML_IMPORT_PATH="${EXE_OUTPUT_DIR}"
    $<$<BOOL:${Qt6WebEngineQuick_FOUND}>:HAS_QT_WEBENGINE>
)

if(UNIX AND NOT APPLE)
    set_target_properties(${PROJECT_NAME} PROPERTIES
        BUILD_RPATH "${LIBRARY_SHARED_OUTPUT_DIRECTORY};${LIBRARY_SHARED_OUTPUT_DIRECTORY}/bin"
        INSTALL_RPATH "$ORIGIN/.."
    )
endif()

# ====== 修正 .qmlls.ini ======
# 从 Qt6_DIR 推导 Qt 安装根目录（避免硬编码路径）
get_filename_component(QT6_PREFIX "${Qt6_DIR}/../../.." ABSOLUTE)
cmake_language(DEFER CALL file WRITE
    "${CMAKE_CURRENT_SOURCE_DIR}/.qmlls.ini"
    "[General]\nbuildDir=\"${CMAKE_SOURCE_DIR}/static\"\nno-cmake-calls=false\ndocDir=${QT6_PREFIX}/Docs/Qt-${Qt6_VERSION}\nimportPaths=\"${QT6_PREFIX}/qml;${CMAKE_SOURCE_DIR}/static\"\n"
)

