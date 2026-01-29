
add_library(KirigamiControlsMaterial)
ecm_add_qml_module(KirigamiControlsMaterial URI "org.kde.kirigami.controls.Material"
    VERSION 2.0
    GENERATE_PLUGIN_SOURCE
    INSTALLED_PLUGIN_TARGET KF6KirigamiControlsMaterialplugin
    DEPENDENCIES QtQuick org.kde.kirigami.templates
)

ecm_target_qml_sources(KirigamiControlsMaterial SOURCES
    InlineMessage.qml
    Theme.qml
)

set_target_properties(KirigamiControlsMaterial PROPERTIES
    VERSION     ${PROJECT_VERSION}
    SOVERSION   6
    EXPORT_NAME "KirigamiControlsMaterial"
)

ecm_finalize_qml_module(KirigamiControlsMaterial EXPORT KirigamiTargets)

install(TARGETS KirigamiControlsMaterial EXPORT KirigamiTargets ${KF_INSTALL_DEFAULT_ARGUMENTS})
