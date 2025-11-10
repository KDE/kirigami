
add_library(KirigamiTemplates)
ecm_add_qml_module(KirigamiTemplates URI "org.kde.kirigami.templates"
    VERSION 2.0
    GENERATE_PLUGIN_SOURCE
    INSTALLED_PLUGIN_TARGET KF6KirigamiTemplates
)

set_source_files_properties(AppHeaderSizeGroup.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
)

ecm_target_qml_sources(KirigamiTemplates SOURCES
    AbstractApplicationHeader.qml
    AbstractCard.qml
    AppHeaderSizeGroup.qml
    Chip.qml
    InlineMessage.qml
    OverlayDrawer.qml
    OverlaySheet.qml
)

ecm_target_qml_sources(KirigamiTemplates PRIVATE PATH private SOURCES
    private/BorderPropertiesGroup.qml
    private/DrawerHandle.qml
    private/PassiveNotificationsManager.qml
)

set_target_properties(KirigamiTemplates PROPERTIES
    VERSION     ${PROJECT_VERSION}
    SOVERSION   6
    EXPORT_NAME "KirigamiTemplates"
)

target_include_directories(KirigamiTemplates PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/..)


ecm_finalize_qml_module(KirigamiTemplates EXPORT KirigamiTargets)

install(TARGETS KirigamiTemplates EXPORT KirigamiTargets ${KF_INSTALL_TARGETS_DEFAULT_ARGS})
