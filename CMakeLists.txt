cmake_minimum_required(VERSION 3.16)

project(DeepSpaceAssistant VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2 Multimedia Concurrent)

set(BACKEND_SOURCES
    src/backend/sdcard/SDCardManager.cpp
    src/backend/sdcard/DeviceEventFilter.cpp
    src/backend/basic/BasicConfig.cpp
    src/backend/agent/AgentConfig.cpp
    src/backend/radio/RadioConfig.cpp
    src/backend/character/CharacterManager.cpp
    src/backend/image/ImageProcessor.cpp
    src/backend/maintenance/MaintenanceManager.cpp
    src/backend/python/PythonRunner.cpp
    src/backend/logger/Logger.cpp
    src/backend/user/RoleInfo.cpp
    src/backend/user/UserSettings.cpp
    src/backend/user/UserAccount.cpp
    src/backend/voice/VoiceLibrary.cpp
)

set(BACKEND_HEADERS
    src/backend/sdcard/SDCardManager.h
    src/backend/sdcard/DeviceEventFilter.h
    src/backend/basic/BasicConfig.h
    src/backend/agent/AgentConfig.h
    src/backend/radio/RadioConfig.h
    src/backend/character/CharacterManager.h
    src/backend/image/ImageProcessor.h
    src/backend/maintenance/MaintenanceManager.h
    src/backend/python/PythonRunner.h
    src/backend/logger/Logger.h
    src/backend/user/RoleInfo.h
    src/backend/user/UserSettings.h
    src/backend/user/UserAccount.h
    src/backend/voice/VoiceLibrary.h
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
        src/frontend/qml/components/CustomTabBar.qml
        src/frontend/qml/components/LogPanel.qml
        src/frontend/qml/components/ApplyButton.qml
        src/frontend/qml/pages/BasicConfigPage.qml
        src/frontend/qml/pages/AgentConfigPage.qml
        src/frontend/qml/pages/RadioConfigPage.qml
        src/frontend/qml/pages/MaintenancePage.qml
        src/frontend/qml/pages/agent/AccountPage.qml
        src/frontend/qml/pages/agent/HotWordsPage.qml
        src/frontend/qml/pages/agent/KnowledgeBasePage.qml
        src/frontend/qml/pages/agent/RolePage.qml
        src/frontend/qml/pages/agent/VoiceLibraryPage.qml
        src/frontend/qml/pages/agent/OtherPage.qml
    RESOURCES
        src/frontend/fonts/SourceHanSansCN-Medium-2.otf
)

target_link_libraries(DeepSpaceAssistant PRIVATE
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Multimedia
    Qt6::Concurrent
)

set_target_properties(DeepSpaceAssistant PROPERTIES
    WIN32_EXECUTABLE TRUE
)

file(COPY scripts/dist/convert_image.exe scripts/dist/voice_clone.exe
     DESTINATION ${CMAKE_BINARY_DIR}/python)
if(EXISTS "${CMAKE_SOURCE_DIR}/scripts/dist/ffmpeg.exe")
    file(COPY scripts/dist/ffmpeg.exe DESTINATION ${CMAKE_BINARY_DIR}/python)
endif()

file(COPY materials/option.json
     DESTINATION ${CMAKE_BINARY_DIR}/materials)