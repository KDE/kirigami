add_library(KirigamiPlatform)
add_library(KF6::KirigamiPlatform ALIAS KirigamiPlatform)

ecm_add_qml_module(KirigamiPlatform
    URI "org.kde.kirigami.platform"
    VERSION 2.0
    GENERATE_PLUGIN_SOURCE
    INSTALLED_PLUGIN_TARGET KF6::KirigamiPlatformplugin
    DEPENDENCIES QtQuick
)

set_target_properties(KirigamiPlatform PROPERTIES
    VERSION     ${PROJECT_VERSION}
    SOVERSION   6
    EXPORT_NAME "KirigamiPlatform"
)

target_sources(KirigamiPlatform PRIVATE
    platformtheme.cpp
    platformtheme.h
    basictheme.cpp
    basictheme_p.h
    inputmethod.cpp
    inputmethod.h
    platformpluginfactory.cpp
    platformpluginfactory.h
    tabletmodewatcher.cpp
    tabletmodewatcher.h
    settings.cpp
    settings.h
    smoothscrollwatcher.cpp
    smoothscrollwatcher.h
    styleselector.cpp
    styleselector.h
    units.cpp
    units.h
    virtualkeyboardwatcher.cpp
    virtualkeyboardwatcher.h
    colorutils.cpp
    colorutils.h
)

set(libkirigami_extra_sources "")

if (WITH_DBUS)
    set_source_files_properties(org.freedesktop.portal.Settings.xml PROPERTIES INCLUDE dbustypes.h)
    qt_add_dbus_interface(libkirigami_extra_sources org.freedesktop.portal.Settings.xml settings_interface)
    set(LIBKIRIGAMKI_EXTRA_LIBS Qt6::DBus)
endif()

target_sources(KirigamiPlatform PRIVATE ${libkirigami_extra_sources})

ecm_qt_declare_logging_category(KirigamiPlatform
    HEADER kirigamiplatform_logging.h
    IDENTIFIER KirigamiPlatform
    CATEGORY_NAME kf.kirigami.platform
    DESCRIPTION "Kirigami Platform"
    DEFAULT_SEVERITY Warning
    EXPORT KIRIGAMI
)

ecm_setup_version(PROJECT
    VARIABLE_PREFIX KIRIGAMIPLATFORM
    VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/kirigamiplatform_version.h"
    PACKAGE_VERSION_FILE "${CMAKE_CURRENT_BINARY_DIR}/KF6KirigamiPlatformConfigVersion.cmake"
    SOVERSION 6
)

ecm_generate_export_header(KirigamiPlatform
    VERSION ${PROJECT_VERSION}
    BASE_NAME KirigamiPlatform
    USE_VERSION_HEADER
    DEPRECATION_VERSIONS 6.24
)

target_include_directories(KirigamiPlatform
    PUBLIC
    "$<INSTALL_INTERFACE:${KDE_INSTALL_INCLUDEDIR_KF}>"
    "$<INSTALL_INTERFACE:${KDE_INSTALL_INCLUDEDIR_KF}/Kirigami/Platform>"
)

target_link_libraries(KirigamiPlatform
    PUBLIC
    Qt6::Core
    Qt6::Qml
    Qt6::Quick
    PRIVATE
    Qt6::GuiPrivate
    Qt6::QuickControls2
    ${LIBKIRIGAMKI_EXTRA_LIBS}
)

ecm_generate_headers(KirigamiPlatform_CamelCase_HEADERS
    HEADER_NAMES
    PlatformTheme
    PlatformPluginFactory
    StyleSelector
    TabletModeWatcher
    Units
    VirtualKeyboardWatcher
    REQUIRED_HEADERS KirigamiPlatform_HEADERS
)

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/KF6KirigamiPlatformConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/KF6KirigamiPlatformConfig.cmake"
    INSTALL_DESTINATION ${KDE_INSTALL_CMAKEPACKAGEDIR}/KF6KirigamiPlatform
    PATH_VARS CMAKE_INSTALL_PREFIX
)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/KF6KirigamiPlatformConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/KF6KirigamiPlatformConfigVersion.cmake"
    DESTINATION ${KDE_INSTALL_CMAKEPACKAGEDIR}/KF6KirigamiPlatform
    COMPONENT Devel
)

install(TARGETS KirigamiPlatform EXPORT KF6KirigamiPlatformTargets ${KF_INSTALL_TARGETS_DEFAULT_ARGS})

install(EXPORT KF6KirigamiPlatformTargets
    DESTINATION ${KDE_INSTALL_CMAKEPACKAGEDIR}/KF6KirigamiPlatform
    FILE KF6KirigamiPlatformTargets.cmake
    NAMESPACE KF6::
)

install(FILES
    ${KirigamiPlatform_HEADERS}
    ${CMAKE_CURRENT_BINARY_DIR}/kirigamiplatform_export.h
    ${CMAKE_CURRENT_BINARY_DIR}/kirigamiplatform_version.h
    DESTINATION ${KDE_INSTALL_INCLUDEDIR_KF}/Kirigami/Platform # prefix matching C++ namespace
    COMPONENT Devel
)
install(FILES
    ${KirigamiPlatform_CamelCase_HEADERS}
    DESTINATION ${KDE_INSTALL_INCLUDEDIR_KF}/Kirigami/Platform # prefix matching C++ namespace
    COMPONENT Devel
)

ecm_qt_install_logging_categories(
    EXPORT KIRIGAMI
    FILE kirigami.categories
    DESTINATION ${KDE_INSTALL_LOGGINGCATEGORIESDIR}
)

ecm_finalize_qml_module(KirigamiPlatform EXPORT KF6KirigamiPlatformTargets)

ecm_generate_qdoc(KirigamiPlatform kirigamiplatform.qdocconf)
