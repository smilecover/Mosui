cmake_minimum_required(VERSION 3.16)

project(MosuiBasic VERSION ${MOSUI_VERSION} LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_subdirectory(party3lib/qwindowkit)

# ====== 静态库 / 动态库选择 ======
option(MOSUIBASIC_BUILD_STATIC "Build MosuiBasic as a static library (default: shared)" OFF)

# 根据构建类型选择输出目录
if(MOSUIBASIC_BUILD_STATIC)
    if(NOT DEFINED LIBRARY_STATIC_OUTPUT_DIRECTORY OR NOT EXISTS ${LIBRARY_STATIC_OUTPUT_DIRECTORY})
        set(LIBRARY_STATIC_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/static CACHE PATH "静态库文件输出目录" FORCE)
        file(MAKE_DIRECTORY ${LIBRARY_STATIC_OUTPUT_DIRECTORY})
    endif()
    set(MOSUIBASIC_OUTPUT_DIR ${LIBRARY_STATIC_OUTPUT_DIRECTORY})
else()
    if(NOT DEFINED LIBRARY_SHARED_OUTPUT_DIRECTORY OR NOT EXISTS ${LIBRARY_SHARED_OUTPUT_DIRECTORY})
        set(LIBRARY_SHARED_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/shared CACHE PATH "动态库文件输出目录" FORCE)
        file(MAKE_DIRECTORY ${LIBRARY_SHARED_OUTPUT_DIRECTORY})
    endif()
    set(MOSUIBASIC_OUTPUT_DIR ${LIBRARY_SHARED_OUTPUT_DIRECTORY})
endif()

set(QT_QML_OUTPUT_DIRECTORY ${MOSUIBASIC_OUTPUT_DIR})
if(NOT EXISTS ${QT_QML_OUTPUT_DIRECTORY}/MosuiBasic)
    file(MAKE_DIRECTORY ${QT_QML_OUTPUT_DIRECTORY}/MosuiBasic)
endif()

file(GLOB QML_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "qml/*.qml")
file(GLOB CPP_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
    "cpp/*.cpp" "cpp/*.h"
    "cpp/theme/*.cpp" "cpp/theme/*.h"
    "cpp/window/*.cpp" "cpp/window/*.h"
    "cpp/controls/*.cpp" "cpp/controls/*.h"
    "cpp/utils/*.cpp" "cpp/utils/*.h"
    "cpp/Icon/*.cpp" "cpp/Icon/*.h"
    "cpp/tools/*/*.cpp" "cpp/tools/*/*.h"
)

# 库类型（静态/动态）
if(MOSUIBASIC_BUILD_STATIC)
    qt_add_library(${PROJECT_NAME} STATIC)
else()
    qt_add_library(${PROJECT_NAME} SHARED)
endif()

# 资源文件（GLOB 自动匹配，无需手动维护文件列表）
set(RES_BASE "${CMAKE_CURRENT_SOURCE_DIR}/resources")

file(GLOB RES_FILES "resources/theme/*.json")
qt_add_resources(${PROJECT_NAME} "theme"
    PREFIX "/theme"
    BASE "${RES_BASE}"
    FILES ${RES_FILES}
)

file(GLOB RES_FILES "resources/font/*")
qt_add_resources(${PROJECT_NAME} "font"
    PREFIX "/font"
    BASE "${RES_BASE}"
    FILES ${RES_FILES}
)

file(GLOB RES_FILES "resources/image/*")
qt_add_resources(${PROJECT_NAME} "image"
    PREFIX "/image"
    BASE "${RES_BASE}"
    FILES ${RES_FILES}
)

qt_add_shaders(${PROJECT_NAME} "mosuibasic_shaders"
    PREFIX "/"
    FILES
        shaders/noise.vert
        shaders/noise.frag
        shaders/mosliquidglass.vert
        shaders/mosliquidglass.frag
        shaders/mosrate.frag
)

qt_add_qml_module(
    ${PROJECT_NAME}
    URI MosuiBasic
    VERSION ${MOSUI_VERSION}
    QML_FILES ${QML_FILES}
    SOURCES
        ${CPP_FILES}
)
set_target_properties(${PROJECT_NAME} PROPERTIES
    QMLDIR_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/qmldir"
)

# 收集 Qt 自动生成的资源目标（OBJECT 库），后面 install(EXPORT) 需要
set(_mosui_resource_targets "")
set(_res_idx 1)
while(TARGET ${PROJECT_NAME}_resources_${_res_idx})
    list(APPEND _mosui_resource_targets ${PROJECT_NAME}_resources_${_res_idx})
    math(EXPR _res_idx "${_res_idx} + 1")
endwhile()
message(STATUS "MosuiBasic resource targets: ${_mosui_resource_targets}")

target_link_libraries(${PROJECT_NAME} PUBLIC
    QWKCore
    QWKQuick

    Qt6::Core
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickPrivate
    Qt6::QuickTemplates2
    Qt6::QuickTemplates2Private
    Qt6::WebView
    Qt6::SerialPort
    Qt6::Mqtt
)

# 将 QWindowKit 动态库复制到输出目录，确保运行时能找到（仅动态库需要）
if(NOT MOSUIBASIC_BUILD_STATIC AND NOT QWINDOWKIT_BUILD_STATIC)
    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            $<TARGET_FILE:QWKCore>
            ${MOSUIBASIC_OUTPUT_DIR}/
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            $<TARGET_FILE:QWKQuick>
            ${MOSUIBASIC_OUTPUT_DIR}/
        COMMENT "Copying QWindowKit libraries to output/"
    )
endif()

set_target_properties(${PROJECT_NAME} PROPERTIES
    QT_QML_MODULE_URI MosuiBasic
    VERSION ${MOSUI_VERSION}

    # 根据构建类型输出到 shared/ 或 static/ 目录
    LIBRARY_OUTPUT_DIRECTORY ${MOSUIBASIC_OUTPUT_DIR}
    RUNTIME_OUTPUT_DIRECTORY ${MOSUIBASIC_OUTPUT_DIR}
    ARCHIVE_OUTPUT_DIRECTORY ${MOSUIBASIC_OUTPUT_DIR}
)

# 子目标（QWindowKit 等）默认输出目录
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${MOSUIBASIC_OUTPUT_DIR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${MOSUIBASIC_OUTPUT_DIR})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${MOSUIBASIC_OUTPUT_DIR})

target_compile_definitions(${PROJECT_NAME}
    PRIVATE
        $<$<NOT:$<BOOL:${MOSUIBASIC_BUILD_STATIC}>>:$<BUILD_INTERFACE:MOSUIBASIC_LIBRARY>>
        $<$<BOOL:${MOSUIBASIC_BUILD_STATIC}>:MOSUIBASIC_STATIC_LIBRARY>
        $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>
    PUBLIC
        $<$<BOOL:${MOSUIBASIC_BUILD_STATIC}>:MOSUIBASIC_STATIC_LIBRARY>
)

# Linux: 设置 RPATH 使动态链接器能找到同目录下的 .so 文件（仅动态库需要）
if(UNIX AND NOT APPLE AND NOT MOSUIBASIC_BUILD_STATIC)
    set_target_properties(${PROJECT_NAME} PROPERTIES
        BUILD_RPATH "${MOSUIBASIC_OUTPUT_DIR}"
        INSTALL_RPATH "$ORIGIN"
    )
endif()

target_include_directories(${PROJECT_NAME} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/cpp>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/cpp/theme>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/cpp/window>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/cpp/controls>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/cpp/utils>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/cpp/Icon>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/cpp/tools/MosSerialPort>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/cpp/tools/MosMqtt>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/cpp/tools/MosCharts>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/MosuiBasic>
)

# ====== Install 规则 ======
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

# --- 1. 库文件（MosuiBasic + QWindowKit） ---
install(TARGETS ${PROJECT_NAME} QWKCore QWKQuick
    EXPORT MosuiBasicTargets
    LIBRARY  DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE  DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME  DESTINATION ${CMAKE_INSTALL_BINDIR}
)
# Qt 资源目标（OBJECT 库）必须加入 EXPORT 以避免 "not in any export set" 错误
# OBJECT 库无需指定 DESTINATION（无实际文件输出）
if(_mosui_resource_targets)
    install(TARGETS ${_mosui_resource_targets}
        EXPORT MosuiBasicTargets
    )
endif()

# --- 2. MosuiBasic 公共头文件 ---
install(DIRECTORY cpp/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/MosuiBasic
    FILES_MATCHING PATTERN "*.h"
)

# --- 3. QWindowKit 头文件（MosuiBasic 的 PUBLIC 依赖需要） ---
install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/party3lib/qwindowkit/include/QWKCore/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/QWindowKit/QWKCore
    FILES_MATCHING PATTERN "*.h"
)
install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/party3lib/qwindowkit/include/QWKQuick/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/QWindowKit/QWKQuick
    FILES_MATCHING PATTERN "*.h"
)

# --- 4. QML 模块 ---
# 源 QML 文件
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/qml/
    DESTINATION ${CMAKE_INSTALL_DATADIR}/MosuiBasic/qml/MosuiBasic
    FILES_MATCHING PATTERN "*.qml"
)
# 生成的 qmldir（构建后才存在）
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/qmldir
    DESTINATION ${CMAKE_INSTALL_DATADIR}/MosuiBasic/qml/MosuiBasic
    OPTIONAL
)
# 生成的 qmltypes
install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/.qt/qmltypes/
    DESTINATION ${CMAKE_INSTALL_DATADIR}/MosuiBasic/qml/MosuiBasic
    FILES_MATCHING PATTERN "MosuiBasic.qmltypes"
)

# --- 5. CMake 导出目标 ---
install(EXPORT MosuiBasicTargets
    FILE MosuiBasicTargets.cmake
    NAMESPACE MosuiBasic::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/MosuiBasic
)

# --- 6. 版本文件 ---
write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/MosuiBasicConfigVersion.cmake
    VERSION ${MOSUI_VERSION}
    COMPATIBILITY SameMajorVersion
)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/MosuiBasicConfigVersion.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/MosuiBasic
)

# --- 7. 包配置文件（从模板生成） ---
configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/MosuiBasicConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/MosuiBasicConfig.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/MosuiBasic
)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/MosuiBasicConfig.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/MosuiBasic
)

# 打印安装路径（方便用户确认）
message(STATUS "MosuiBasic install prefix: ${CMAKE_INSTALL_PREFIX}")
message(STATUS "  Library  → ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}")
message(STATUS "  Headers  → ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR}")
message(STATUS "  QML      → ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATADIR}/MosuiBasic/qml/MosuiBasic")
message(STATUS "  CMake    → ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/cmake/MosuiBasic")

# ====== 修正 .qmlls.ini ======
# buildDir 故意指向 static/（非 CMake 目录），让 qmlls CMake 模式静默失败
# 实际通过 VSCode customArgs 的 -b 参数提供真正的构建目录
# 这样避免了 ninja 文件锁导致 qmlls 初始化崩溃
cmake_language(DEFER CALL file WRITE
    "${CMAKE_CURRENT_SOURCE_DIR}/.qmlls.ini"
    "[General]\nbuildDir=\"${CMAKE_SOURCE_DIR}/static\"\nno-cmake-calls=false\ndocDir=D:/Qt/Docs/Qt-6.8.3\nimportPaths=\"D:/Qt/6.8.3/msvc2022_64/qml;${CMAKE_SOURCE_DIR}/static\"\n"
)
