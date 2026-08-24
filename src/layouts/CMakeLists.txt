
add_library(KirigamiLayoutsPrivate)
ecm_add_qml_module(KirigamiLayoutsPrivate URI "org.kde.kirigami.layouts.private"
    VERSION 2.0
    GENERATE_PLUGIN_SOURCE
    INSTALLED_PLUGIN_TARGET KF6KirigamiLayoutsPrivateplugin
    DEPENDENCIES
        QtQuick
        TARGET KirigamiPlatform
)

ecm_target_qml_sources(KirigamiLayoutsPrivate SOURCES
    ColumnViewSeparator.qml
)

set_target_properties(KirigamiLayoutsPrivate PROPERTIES
    VERSION     ${PROJECT_VERSION}
    SOVERSION   6
    EXPORT_NAME "KirigamiLayoutsPrivate"
)

target_include_directories(KirigamiLayoutsPrivate PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/..)

target_link_libraries(KirigamiLayoutsPrivate PRIVATE Qt6::Quick Qt6::QuickControls2 KirigamiPlatform)

ecm_finalize_qml_module(KirigamiLayoutsPrivate EXPORT KirigamiTargets)


add_library(KirigamiLayouts)
ecm_add_qml_module(KirigamiLayouts URI "org.kde.kirigami.layouts"
    VERSION 2.0
    GENERATE_PLUGIN_SOURCE
    INSTALLED_PLUGIN_TARGET KF6KirigamiLayoutsplugin
    DEPENDENCIES QtQuick org.kde.kirigami.platform org.kde.kirigami.layouts.private
)

ecm_qt_declare_logging_category(KirigamiLayouts
    HEADER loggingcategory.h
    IDENTIFIER KirigamiLayoutsLog
    CATEGORY_NAME kf.kirigami.layouts
    DESCRIPTION "KirigamiLayouts"
    EXPORT KIRIGAMI
)

target_sources(KirigamiLayouts PRIVATE
    columnview.cpp
    displayhint.cpp
    formlayoutattached.cpp
    headerfooterlayout.cpp
    padding.cpp
    sizegroup.cpp
    toolbarlayout.cpp
    toolbarlayoutdelegate.cpp
    pagestackattached.cpp
    pagestackattached.h
)

ecm_target_qml_sources(KirigamiLayouts SOURCES
    # Don't add ColumnViewSeparator here as is in a private module
    FormLayout.qml
)

set_target_properties(KirigamiLayouts PROPERTIES
    VERSION     ${PROJECT_VERSION}
    SOVERSION   6
    EXPORT_NAME "KirigamiLayouts"
)

target_include_directories(KirigamiLayouts PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/..)

target_link_libraries(KirigamiLayouts PRIVATE Qt6::Quick Qt6::QuickControls2 KirigamiPlatform KirigamiLayoutsPrivate)

ecm_finalize_qml_module(KirigamiLayouts EXPORT KirigamiTargets)

install(TARGETS KirigamiLayouts EXPORT KirigamiTargets ${KF_INSTALL_TARGETS_DEFAULT_ARGS})
install(TARGETS KirigamiLayoutsPrivate EXPORT KirigamiTargets ${KF_INSTALL_TARGETS_DEFAULT_ARGS})
