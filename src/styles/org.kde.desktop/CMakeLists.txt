
add_library(KirigamiControlsOrgKdeDesktop)
ecm_add_qml_module(KirigamiControlsOrgKdeDesktop URI "org.kde.kirigami.controls.org.kde.desktop"
    VERSION 2.0
    GENERATE_PLUGIN_SOURCE
    INSTALLED_PLUGIN_TARGET KF6KirigamiControlsOrgKdeDesktopplugin
    DEPENDENCIES QtQuick org.kde.kirigami.controls.templates
)

ecm_target_qml_sources(KirigamiControlsOrgKdeDesktop SOURCES
    AbstractApplicationHeader.qml
    Theme.qml
)

set_target_properties(KirigamiControlsOrgKdeDesktop PROPERTIES
    VERSION     ${PROJECT_VERSION}
    SOVERSION   6
    EXPORT_NAME "KirigamiControlsOrgKdeDesktop"
)

ecm_finalize_qml_module(KirigamiControlsOrgKdeDesktop EXPORT KirigamiTargets)

install(TARGETS KirigamiControlsOrgKdeDesktop EXPORT KirigamiTargets ${KF_INSTALL_DEFAULT_ARGUMENTS})
