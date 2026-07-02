cmake_minimum_required(VERSION 3.16)

project(DeepSpaceAssistant VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2)

set(BACKEND_SOURCES
    src/backend/sdcard/SDCardManager.cpp
    src/backend/basic/BasicConfig.cpp
    src/backend/agent/AgentConfig.cpp
    src/backend/radio/RadioConfig.cpp
    src/backend/maintenance/MaintenanceManager.cpp
    src/backend/python/PythonRunner.cpp
    src/backend/logger/Logger.cpp
    src/backend/user/RoleInfo.cpp
    src/backend/user/UserSettings.cpp
)

set(BACKEND_HEADERS
    src/backend/sdcard/SDCardManager.h
    src/backend/basic/BasicConfig.h
    src/backend/agent/AgentConfig.h
    src/backend/radio/RadioConfig.h
    src/backend/maintenance/MaintenanceManager.h
    src/backend/python/PythonRunner.h
    src/backend/logger/Logger.h
    src/backend/user/RoleInfo.h
    src/backend/user/UserSettings.h
)

qt_add_executable(DeepSpaceAssistant
    main.cpp
    ${BACKEND_SOURCES}
    ${BACKEND_HEADERS}
)

qt_add_qml_module(DeepSpaceAssistant
    URI App
    VERSION 1.0
    QML_FILES
        src/frontend/qml/Main.qml
        src/frontend/qml/CustomTabBar.qml
        src/frontend/qml/LogPanel.qml
        src/frontend/qml/ApplyButton.qml
        src/frontend/qml/BasicConfigPage.qml
        src/frontend/qml/AgentConfigPage.qml
        src/frontend/qml/RadioConfigPage.qml
        src/frontend/qml/MaintenancePage.qml
    RESOURCES
        src/frontend/fonts/SourceHanSansCN-Medium-2.otf
)

target_link_libraries(DeepSpaceAssistant PRIVATE
    Qt6::Quick
    Qt6::QuickControls2
)

set_target_properties(DeepSpaceAssistant PROPERTIES
    WIN32_EXECUTABLE TRUE
)