# SPDX-FileCopyrightText: 2025 James Graham <james.h.graham@protonmail.com>
# SPDX-License-Identifier: LGPL-2.0-or-later

add_library(KirigamiContentItems)
ecm_add_qml_module(KirigamiContentItems URI "org.kde.kirigami.contentitems"
    GENERATE_PLUGIN_SOURCE
    INSTALLED_PLUGIN_TARGET KF6KirigamiContentItems
    QML_FILES
        ActionTextField.qml
        Heading.qml
        IconTitleSubtitle.qml
        InlineMessage.qml
        InlineViewHeader.qml
        LinkButton.qml
        ListItemDragHandle.qml
        ListSectionHeader.qml
        LoadingPlaceholder.qml
        PasswordField.qml
        PlaceholderMessage.qml
        SearchField.qml
        SelectableLabel.qml
        TitleSubtitle.qml
        UrlButton.qml
    DEPENDENCIES
        QtQuick
        org.kde.kirigami.platform
        org.kde.kirigami.primitives
        org.kde.kirigami.private
        org.kde.kirigami.templates.private
)

ecm_target_qml_sources(KirigamiContentItems PRIVATE PATH templates SOURCES
    templates/InlineMessage.qml
)

set_target_properties(KirigamiContentItems PROPERTIES
    VERSION     ${PROJECT_VERSION}
    SOVERSION   6
    EXPORT_NAME "KirigamiContentItems"
)

ecm_finalize_qml_module(KirigamiContentItems EXPORT KirigamiTargets)

install(TARGETS KirigamiContentItems EXPORT KirigamiTargets ${KF_INSTALL_TARGETS_DEFAULT_ARGS})
