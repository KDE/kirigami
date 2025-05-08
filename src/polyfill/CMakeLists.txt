# SPDX-FileCopyrightText: ⓒ 2025 Volker Krause <vkrause@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

add_library(KirigamiPolyfill)

ecm_add_qml_module(KirigamiPolyfill URI "org.kde.kirigami.private.polyfill"
    VERSION 1.0
    GENERATE_PLUGIN_SOURCE
    INSTALLED_PLUGIN_TARGET KF6KirigamiPolyfillplugin
    DEPENDENCIES QtQuick
)

if (Qt6Quick_VERSION VERSION_LESS 6.9.0)
    target_sources(KirigamiPolyfill PRIVATE
        safearea.cpp
    )
endif()

set_target_properties(KirigamiPolyfill PROPERTIES
    VERSION     ${PROJECT_VERSION}
    SOVERSION   6
    EXPORT_NAME "KirigamiPolyfill"
)

target_link_libraries(KirigamiPolyfill PRIVATE Qt6::Quick)

ecm_finalize_qml_module(KirigamiPolyfill EXPORT KirigamiTargets)

install(TARGETS KirigamiPolyfill EXPORT KirigamiTargets ${KF_INSTALL_DEFAULT_ARGUMENTS})
