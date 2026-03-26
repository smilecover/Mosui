cmake_minimum_required(VERSION 3.16)

project(Mosuiapp VERSION ${MOSUI_VERSION} LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON) # Use C++17 standard
set(CMAKE_CXX_STANDARD 17)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/../bin/${CMAKE_BUILD_TYPE})

find_package(Qt6 6.5 COMPONENTS Quick REQUIRED )
qt_standard_project_setup(REQUIRES 6.5) # 最低QT版本要求

qt_add_executable(${PROJECT_NAME})

if(QT_KNOWN_POLICY_QTP0004)
    qt_policy(SET QTP0004 NEW)
endif()

qt_add_qml_module(${PROJECT_NAME}
    URI Mosuiapp
    VERSION 1.0
    OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
    QML_FILES
        Main.qml
    SOURCES
        main.cpp
)
qt_add_resources(RES
    src.qrc
)
target_sources(${PROJECT_NAME} PRIVATE ${RES})

# 头文件
target_include_directories(${PROJECT_NAME} PRIVATE
    
)
# 链接库
target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Quick

)

# macOS / iOS Bundle 设置
set_target_properties(${PROJECT_NAME} PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

# ==========================
# 安装规则
# ==========================
include(GNUInstallDirs)
install(TARGETS ${PROJECT_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)


