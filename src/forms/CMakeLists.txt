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

add_library(KirigamiFormsCardsFlat)
ecm_add_qml_module(KirigamiFormsCardsFlat URI "org.kde.kirigami.forms.private.cards"
    VERSION 2.0
    GENERATE_PLUGIN_SOURCE
    INSTALLED_PLUGIN_TARGET KF6KirigamiFormsCardsFlatplugin
    DEPENDENCIES QtQuick org.kde.kirigami
)

set_target_properties(KirigamiFormsCardsFlat PROPERTIES
    VERSION     ${PROJECT_VERSION}
    SOVERSION   6
    EXPORT_NAME "KirigamiFormsCardsFlat"
)

ecm_target_qml_sources(KirigamiFormsCardsFlat SOURCES
    cards/FormAction.qml
    cards/FormEntry.qml
    cards/FormGroup.qml
    cards/Form.qml
    cards/FormSeparator.qml
)

add_library(KirigamiFormsPrivateHybrid)
ecm_add_qml_module(KirigamiFormsPrivateHybrid URI "org.kde.kirigami.forms.private.hybrid"
    VERSION 2.0
    GENERATE_PLUGIN_SOURCE
    INSTALLED_PLUGIN_TARGET KF6KirigamiFormsPrivateHybridplugin
    DEPENDENCIES QtQuick org.kde.kirigami
)

set_target_properties(KirigamiFormsPrivateHybrid PROPERTIES
    VERSION     ${PROJECT_VERSION}
    SOVERSION   6
    EXPORT_NAME "KirigamiFormsPrivateHybrid"
)

ecm_target_qml_sources(KirigamiFormsPrivateHybrid SOURCES
    hybrid/FormAction.qml
    hybrid/FormEntry.qml
    hybrid/FormGroup.qml
    hybrid/Form.qml
    hybrid/FormSeparator.qml
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
    "org.kde.kirigami.forms.private.hybrid"
)

target_sources(KirigamiFormsplugin PRIVATE
    kirigamiformsplugin.cpp
    kirigamiformsplugin.h
)



install(TARGETS KirigamiFormsPrivateFlat EXPORT KirigamiTargets ${KF_INSTALL_DEFAULT_ARGUMENTS})
install(TARGETS KirigamiFormsCardsFlat EXPORT KirigamiTargets ${KF_INSTALL_DEFAULT_ARGUMENTS})
install(TARGETS KirigamiFormsPrivateHybrid EXPORT KirigamiTargets ${KF_INSTALL_DEFAULT_ARGUMENTS})
install(TARGETS KirigamiForms EXPORT KirigamiTargets ${KF_INSTALL_DEFAULT_ARGUMENTS})
ecm_finalize_qml_module(KirigamiFormsPrivateFlat DESTINATION ${KDE_INSTALL_QMLDIR} EXPORT KirigamiFormsPrivateFlat)
ecm_finalize_qml_module(KirigamiFormsCardsFlat DESTINATION ${KDE_INSTALL_QMLDIR} EXPORT KirigamiFormsCardsFlat)
ecm_finalize_qml_module(KirigamiFormsPrivateHybrid DESTINATION ${KDE_INSTALL_QMLDIR} EXPORT KirigamiFormsPrivateHybrid)
ecm_finalize_qml_module(KirigamiForms DESTINATION ${KDE_INSTALL_QMLDIR} EXPORT KirigamiForms)
