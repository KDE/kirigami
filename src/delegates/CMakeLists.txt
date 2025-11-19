
add_library(KirigamiDelegates)
ecm_add_qml_module(KirigamiDelegates URI "org.kde.kirigami.delegates"
    GENERATE_PLUGIN_SOURCE
    INSTALLED_PLUGIN_TARGET KF6KirigamiDelegates
    DEPENDENCIES QtQuick org.kde.kirigami.platform org.kde.kirigami.primitives
)

ecm_target_qml_sources(KirigamiDelegates SOURCES
    IconTitleSubtitle.qml
    TitleSubtitle.qml
    TitleSubtitleWithActions.qml

    SubtitleDelegate.qml
    CheckSubtitleDelegate.qml
    RadioSubtitleDelegate.qml
    SwitchSubtitleDelegate.qml
)

set_target_properties(KirigamiDelegates PROPERTIES
    VERSION     ${PROJECT_VERSION}
    SOVERSION   6
    EXPORT_NAME "KirigamiDelegates"
)

ecm_finalize_qml_module(KirigamiDelegates EXPORT KirigamiTargets)

install(TARGETS KirigamiDelegates EXPORT KirigamiTargets ${KF_INSTALL_TARGETS_DEFAULT_ARGS})
