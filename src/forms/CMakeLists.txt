add_library(KirigamiFormsPrivateTemplates)
ecm_add_qml_module(KirigamiFormsPrivateTemplates URI "org.kde.kirigami.forms.private.templates"
    VERSION 2.0
    GENERATE_PLUGIN_SOURCE
    INSTALLED_PLUGIN_TARGET KF6KirigamiFormsPrivateTemplatesplugin
    DEPENDENCIES QtQuick org.kde.kirigami.platform org.kde.kirigami.primitives org.kde.kirigami.layouts
)

set_target_properties(KirigamiFormsPrivateTemplates PROPERTIES
    VERSION     ${PROJECT_VERSION}
    SOVERSION   6
    EXPORT_NAME "KirigamiFormsPrivateTemplates"
)

ecm_target_qml_sources(KirigamiFormsPrivateTemplates SOURCES
    templates/FormAction.qml
    templates/FormEntry.qml
    templates/FormGroup.qml
    templates/Form.qml
    templates/FormSeparator.qml
)

add_library(KirigamiFormsPrivateFlat)
ecm_add_qml_module(KirigamiFormsPrivateFlat URI "org.kde.kirigami.forms.private.flat"
    VERSION 2.0
    GENERATE_PLUGIN_SOURCE
    INSTALLED_PLUGIN_TARGET KF6KirigamiFormsPrivateFlatplugin
    DEPENDENCIES QtQuick org.kde.kirigami.platform org.kde.kirigami.primitives org.kde.kirigami.layouts
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
    DEPENDENCIES QtQuick org.kde.kirigami.platform org.kde.kirigami.primitives org.kde.kirigami.layouts
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
    "org.kde.kirigami.platform"
    "org.kde.kirigami.primitives"
    "org.kde.kirigami.layouts"
    "org.kde.kirigami.forms.private.flat"
    "org.kde.kirigami.forms.private.cards"
    "org.kde.kirigami.forms.private.templates"
)

set_target_properties(KirigamiForms PROPERTIES
    VERSION     ${PROJECT_VERSION}
    SOVERSION   6
    EXPORT_NAME "KirigamiForms"
)


target_sources(KirigamiFormsplugin PRIVATE
    kirigamiformsplugin.cpp
    kirigamiformsplugin.h
)

if (NOT BUILD_SHARED_LIBS)
    # Ensure we install the plugin library file as that's required to link
    # against for static builds to work properly
    target_link_libraries(KirigamiFormsplugin
        PRIVATE
            KirigamiFormsPrivateTemplatesplugin
            KirigamiFormsPrivateFlatplugin
            KirigamiFormsPrivateCardsplugin
    )
    # for tests to find this under the name it's actually installed with'
    add_library(KF6KirigamiFormsplugin ALIAS KirigamiFormsplugin)
else()
    target_link_libraries(KirigamiForms
        PRIVATE
            KirigamiFormsPrivateTemplates
            KirigamiFormsPrivateFlat
            KirigamiFormsPrivateCards
    )
endif()

ecm_finalize_qml_module(KirigamiFormsPrivateTemplates DESTINATION ${KDE_INSTALL_QMLDIR} EXPORT KirigamiTargets)
ecm_finalize_qml_module(KirigamiFormsPrivateFlat DESTINATION ${KDE_INSTALL_QMLDIR} EXPORT KirigamiTargets)
ecm_finalize_qml_module(KirigamiFormsPrivateCards DESTINATION ${KDE_INSTALL_QMLDIR} EXPORT KirigamiTargets)
ecm_finalize_qml_module(KirigamiForms DESTINATION ${KDE_INSTALL_QMLDIR} EXPORT KirigamiTargets)

install(TARGETS KirigamiFormsPrivateTemplates EXPORT KirigamiTargets ${KF_INSTALL_DEFAULT_ARGUMENTS})
install(TARGETS KirigamiFormsPrivateFlat EXPORT KirigamiTargets ${KF_INSTALL_DEFAULT_ARGUMENTS})
install(TARGETS KirigamiFormsPrivateCards EXPORT KirigamiTargets ${KF_INSTALL_DEFAULT_ARGUMENTS})
install(TARGETS KirigamiForms EXPORT KirigamiTargets ${KF_INSTALL_DEFAULT_ARGUMENTS})
