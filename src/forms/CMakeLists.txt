add_library(KirigamiFormsFlat)
ecm_add_qml_module(KirigamiFormsFlat URI "org.kde.kirigami.forms.flat"
    VERSION 2.0
    GENERATE_PLUGIN_SOURCE
    INSTALLED_PLUGIN_TARGET KF6KirigamiFormsFlatplugin
    DEPENDENCIES QtQuick org.kde.kirigami
)

ecm_target_qml_sources(KirigamiFormsFlat SOURCES
    flat/FormAction.qml
    flat/FormEntry.qml
    flat/FormGroup.qml
    flat/Form.qml
    flat/FormSeparator.qml
)

add_library(KirigamiFormsCards)
ecm_add_qml_module(KirigamiFormsCards URI "org.kde.kirigami.forms.cards"
    VERSION 2.0
    GENERATE_PLUGIN_SOURCE
    INSTALLED_PLUGIN_TARGET KF6KirigamiFormsCardsplugin
    DEPENDENCIES QtQuick org.kde.kirigami
)

ecm_target_qml_sources(KirigamiFormsCards SOURCES
    cards/FormAction.qml
    cards/FormEntry.qml
    cards/FormGroup.qml
    cards/Form.qml
    cards/FormSeparator.qml
)

add_library(KirigamiFormsHybrid)
ecm_add_qml_module(KirigamiFormsHybrid URI "org.kde.kirigami.forms.hybrid"
    VERSION 2.0
    GENERATE_PLUGIN_SOURCE
    INSTALLED_PLUGIN_TARGET KF6KirigamiFormsHybridplugin
    DEPENDENCIES QtQuick org.kde.kirigami
)

ecm_target_qml_sources(KirigamiFormsHybrid SOURCES
    hybrid/FormAction.qml
    hybrid/FormEntry.qml
    hybrid/FormGroup.qml
    hybrid/Form.qml
    hybrid/FormSeparator.qml
)

install(TARGETS KirigamiFormsFlat EXPORT KirigamiTargets ${KF_INSTALL_DEFAULT_ARGUMENTS})
install(TARGETS KirigamiFormsCards EXPORT KirigamiTargets ${KF_INSTALL_DEFAULT_ARGUMENTS})
install(TARGETS KirigamiFormsHybrid EXPORT KirigamiTargets ${KF_INSTALL_DEFAULT_ARGUMENTS})
