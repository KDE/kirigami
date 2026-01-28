add_library(KirigamiControls)

target_include_directories(KirigamiControls PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/../platform
    ${CMAKE_CURRENT_BINARY_DIR}/../platform
)


ecm_add_qml_module(KirigamiControls URI "org.kde.kirigami.controls"
    CLASS_NAME KirigamiControlsPlugin
    INSTALLED_PLUGIN_TARGET KF6KirigamiControlsplugin
    DEPENDENCIES
        QtQuick
        org.kde.kirigami.layouts
        org.kde.kirigami.platform
        org.kde.kirigami.primitives
        org.kde.kirigami.templates
)

ecm_qt_declare_logging_category(KirigamiControls
    HEADER loggingcategory.h
    IDENTIFIER KirigamiControlsLog
    CATEGORY_NAME kf.kirigami.controls
    DESCRIPTION "KirigamiControls"
    DEFAULT_SEVERITY Warning
    EXPORT KIRIGAMI
)

target_sources(KirigamiControls PRIVATE
    enums.h
    pagepool.cpp
    pagepool.h
    kirigamicontrolsplugin.cpp
    kirigamicontrolsplugin.h
)

target_sources(KirigamiControlsplugin PRIVATE
    kirigamicontrolsplugin.cpp
    kirigamicontrolsplugin.h
)

target_link_libraries(KirigamiControls
    PUBLIC
    KirigamiPlatform
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
)

set_target_properties(KirigamiControls PROPERTIES
    VERSION     ${PROJECT_VERSION}
    SOVERSION   6
    EXPORT_NAME "KirigamiControls"
)

ecm_finalize_qml_module(KirigamiControls DESTINATION ${KDE_INSTALL_QMLDIR} EXPORT KirigamiTargets)

install(TARGETS KirigamiControls EXPORT KirigamiTargets ${KF_INSTALL_TARGETS_DEFAULT_ARGS})

add_subdirectory(styles)
