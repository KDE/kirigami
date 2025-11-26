add_library(KirigamiFormsPrivateFlat)
ecm_add_qml_module(KirigamiFormsPrivateFlat URI "org.kde.kirigami.forms.private.flat"
    VERSION 2.0
    GENERATE_PLUGIN_SOURCE
    INSTALLED_PLUGIN_TARGET KF6KirigamiFormsPrivateFlatplugin
    DEPENDENCIES QtQuick org.kde.kirigami
)

set_target_properties(KirigamiFormsPrivateFlat PROPERTIES
    VERSION     ${PROJECT_VERSION}
    SOVERSION   6
    EXPORT_NAME "KirigamiFormsPrivateFlat"
)

ecm_target_qml_sources(KirigamiFormsPrivateFlat SOURCES
    flat/FormAction.qml
    flat/FormEntry.qml
    flat/FormGroup.qml
    flat/Form.qml
    flat/FormSeparator.qml
)

add_library(KirigamiFormsPrivateCards)
ecm_add_qml_module(KirigamiFormsPrivateCards URI "org.kde.kirigami.forms.private.cards"
    VERSION 2.0
    GENERATE_PLUGIN_SOURCE
    INSTALLED_PLUGIN_TARGET KF6KirigamiFormsPrivateCardsplugin
    DEPENDENCIES QtQuick org.kde.kirigami
)

set_target_properties(KirigamiFormsPrivateCards PROPERTIES
    VERSION     ${PROJECT_VERSION}
    SOVERSION   6
    EXPORT_NAME "KirigamiFormsPrivateCards"
)

ecm_target_qml_sources(KirigamiFormsPrivateCards SOURCES
    cards/FormAction.qml
    cards/FormEntry.qml
    cards/FormGroup.qml
    cards/Form.qml
    cards/FormSeparator.qml
)

add_library(KirigamiForms)

ecm_add_qml_module(KirigamiForms URI "org.kde.kirigami.forms" VERSION 2.0
    CLASS_NAME KirigamiFormsPlugin
    INSTALLED_PLUGIN_TARGET KF6KirigamiFormsplugin
    DEPENDENCIES
    "QtQuick.Controls"
    "org.kde.kirigami"
    "org.kde.kirigami.forms.private.flat"
    "org.kde.kirigami.forms.private.cards"
)

target_sources(KirigamiFormsplugin PRIVATE
    kirigamiformsplugin.cpp
    kirigamiformsplugin.h
)



install(TARGETS KirigamiFormsPrivateFlat EXPORT KirigamiTargets ${KF_INSTALL_DEFAULT_ARGUMENTS})
install(TARGETS KirigamiFormsPrivateCards EXPORT KirigamiTargets ${KF_INSTALL_DEFAULT_ARGUMENTS})
install(TARGETS KirigamiForms EXPORT KirigamiTargets ${KF_INSTALL_DEFAULT_ARGUMENTS})
ecm_finalize_qml_module(KirigamiFormsPrivateFlat DESTINATION ${KDE_INSTALL_QMLDIR} EXPORT KirigamiFormsPrivateFlat)
ecm_finalize_qml_module(KirigamiFormsPrivateCards DESTINATION ${KDE_INSTALL_QMLDIR} EXPORT KirigamiFormsPrivateCards)
ecm_finalize_qml_module(KirigamiForms DESTINATION ${KDE_INSTALL_QMLDIR} EXPORT KirigamiForms)
