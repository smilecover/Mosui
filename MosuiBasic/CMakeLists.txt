cmake_minimum_required(VERSION 3.16)

project(MosuiBasic VERSION ${MOSUI_VERSION} LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_subdirectory(party3lib/qwindowkit)
 
# 动态库目录
if(NOT DEFINED LIBRARY_SHARED_OUTPUT_DIRECTORY OR NOT EXISTS ${LIBRARY_SHARED_OUTPUT_DIRECTORY})
    set(LIBRARY_SHARED_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/shared CACHE PATH "动态库文件输出目录" FORCE)
    file(MAKE_DIRECTORY ${LIBRARY_SHARED_OUTPUT_DIRECTORY})
endif()

set(QT_QML_OUTPUT_DIRECTORY ${LIBRARY_SHARED_OUTPUT_DIRECTORY})
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

# 动态库
qt_add_library(${PROJECT_NAME} SHARED)

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

qt_add_shaders(${PROJECT_NAME} "shaders"
    PREFIX "/"
    FILES
        shaders/noise.vert
        shaders/noise.frag
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

)

# 将 QWindowKit 动态库复制到 shared/ 目录，确保运行时能找到
if(NOT QWINDOWKIT_BUILD_STATIC)
    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            $<TARGET_FILE:QWKCore>
            ${LIBRARY_SHARED_OUTPUT_DIRECTORY}/
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            $<TARGET_FILE:QWKQuick>
            ${LIBRARY_SHARED_OUTPUT_DIRECTORY}/
        COMMENT "Copying QWindowKit libraries to shared/"
    )
endif()

set_target_properties(${PROJECT_NAME} PROPERTIES
    QT_QML_MODULE_URI MosuiBasic
    VERSION ${MOSUI_VERSION}

    # Linux / macOS 动态库 .so / .dylib
    LIBRARY_OUTPUT_DIRECTORY ${LIBRARY_SHARED_OUTPUT_DIRECTORY}
    LIBRARY_OUTPUT_DIRECTORY_DEBUG ${LIBRARY_SHARED_OUTPUT_DIRECTORY}
    LIBRARY_OUTPUT_DIRECTORY_RELEASE ${LIBRARY_SHARED_OUTPUT_DIRECTORY}

    # Windows 动态库 .dll
    RUNTIME_OUTPUT_DIRECTORY ${LIBRARY_SHARED_OUTPUT_DIRECTORY}
    RUNTIME_OUTPUT_DIRECTORY_DEBUG ${LIBRARY_SHARED_OUTPUT_DIRECTORY}
    RUNTIME_OUTPUT_DIRECTORY_RELEASE ${LIBRARY_SHARED_OUTPUT_DIRECTORY}

    # Windows 导入库 .lib
    ARCHIVE_OUTPUT_DIRECTORY ${LIBRARY_SHARED_OUTPUT_DIRECTORY}
    ARCHIVE_OUTPUT_DIRECTORY_DEBUG ${LIBRARY_SHARED_OUTPUT_DIRECTORY}
    ARCHIVE_OUTPUT_DIRECTORY_RELEASE ${LIBRARY_SHARED_OUTPUT_DIRECTORY}

    # 强制 Qt QML 插件也输出到目标目录
    # QT_QML_MODULE_OUTPUT_DIRECTORY ${LIBRARY_SHARED_OUTPUT_DIRECTORY}
    # QT_QML_MODULE_TARGET_PATH ${LIBRARY_SHARED_OUTPUT_DIRECTORY}
)

# 全局兜底
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${LIBRARY_SHARED_OUTPUT_DIRECTORY})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${LIBRARY_SHARED_OUTPUT_DIRECTORY})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${LIBRARY_SHARED_OUTPUT_DIRECTORY})

target_compile_definitions(${PROJECT_NAME}
    PRIVATE
    $<BUILD_INTERFACE:MOSUIBASIC_LIBRARY>
    $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>
)

# Linux: 设置 RPATH 使动态链接器能找到同目录下的 .so 文件
if(UNIX AND NOT APPLE)
    set_target_properties(${PROJECT_NAME} PROPERTIES
        BUILD_RPATH "${LIBRARY_SHARED_OUTPUT_DIRECTORY}"
        INSTALL_RPATH "$ORIGIN"
    )
endif()

target_include_directories(${PROJECT_NAME} PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/cpp/theme
    ${CMAKE_CURRENT_SOURCE_DIR}/cpp/window
    ${CMAKE_CURRENT_SOURCE_DIR}/cpp/controls
    ${CMAKE_CURRENT_SOURCE_DIR}/cpp/utils
    ${CMAKE_CURRENT_SOURCE_DIR}/cpp/Icon
    ${CMAKE_CURRENT_SOURCE_DIR}/cpp/tools/MosSerialPort
    ${CMAKE_CURRENT_SOURCE_DIR}/cpp/tools/MosCharts
)
