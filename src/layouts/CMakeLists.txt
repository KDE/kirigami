
qt_add_resources(LAYOUTRESOURCES layout-resources.qrc)

add_library(KirigamiLayouts)
ecm_add_qml_module(KirigamiLayouts URI "org.kde.kirigami.layouts"
    VERSION 2.0
    GENERATE_PLUGIN_SOURCE
    INSTALLED_PLUGIN_TARGET KF6KirigamiLayoutsplugin
    DEPENDENCIES QtQuick org.kde.kirigami.platform
)

ecm_qt_declare_logging_category(KirigamiLayouts
    HEADER loggingcategory.h
    IDENTIFIER KirigamiLayoutsLog
    CATEGORY_NAME kf.kirigami.layouts
    DESCRIPTION "KirigamiLayouts"
    DEFAULT_SEVERITY Warning
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
    ${LAYOUTRESOURCES}
)

ecm_target_qml_sources(KirigamiLayouts SOURCES
    # Don't add ColumnViewSeparator here as is private in a qrc
    FormLayout.qml
)

set_target_properties(KirigamiLayouts PROPERTIES
    VERSION     ${PROJECT_VERSION}
    SOVERSION   6
    EXPORT_NAME "KirigamiLayouts"
)

target_include_directories(KirigamiLayouts PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/..)

target_link_libraries(KirigamiLayouts PRIVATE Qt6::Quick Qt6::QuickControls2 KirigamiPlatform)

if ("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
    set(_extra_options DEBUGINFO)
else()
    set(_extra_options PRECOMPILE OPTIMIZED)
endif()

ecm_finalize_qml_module(KirigamiLayouts EXPORT KirigamiTargets)

install(TARGETS KirigamiLayouts EXPORT KirigamiTargets ${KF_INSTALL_DEFAULT_ARGUMENTS})
