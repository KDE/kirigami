
add_library(KirigamiDialogs)
ecm_add_qml_module(KirigamiDialogs URI "org.kde.kirigami.dialogs"
    VERSION 2.0
    GENERATE_PLUGIN_SOURCE
    INSTALLED_PLUGIN_TARGET KF6KirigamiDialogsplugin
    DEPENDENCIES QtQuick org.kde.kirigami.platform
)



ecm_target_qml_sources(KirigamiDialogs SOURCES
    DialogHeader.qml
    DialogHeaderTopContent.qml
    DialogFooter.qml
    DialogFooterButtonContent.qml
    Dialog.qml
    MenuDialog.qml
    PromptDialog.qml
    SearchDialog.qml
)

set_target_properties(KirigamiDialogs PROPERTIES
    VERSION     ${PROJECT_VERSION}
    SOVERSION   6
    EXPORT_NAME "KirigamiDialogs"
)

target_include_directories(KirigamiDialogs PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/..)

target_link_libraries(KirigamiDialogs PRIVATE Qt6::Quick KirigamiPlatform)

ecm_finalize_qml_module(KirigamiDialogs EXPORT KirigamiTargets)

install(TARGETS KirigamiDialogs EXPORT KirigamiTargets ${KF_INSTALL_DEFAULT_ARGUMENTS})
