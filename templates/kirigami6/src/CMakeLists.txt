# SPDX-License-Identifier: BSD-2-Clause
# SPDX-FileCopyrightText: %{CURRENT_YEAR} %{AUTHOR} <%{EMAIL}>

# Target: static library
qt_add_qml_module(%{APPNAMELC}_static
    STATIC
    URI org.kde.%{APPNAMELC}
    VERSION 1.0
    QML_FILES
        contents/ui/Main.qml
        contents/ui/About.qml
)

target_sources(%{APPNAMELC}_static PUBLIC
    app.cpp
)

target_link_libraries(%{APPNAMELC}_static PUBLIC
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Svg
    KF6::I18n
    KF6::I18nQml
    KF6::CoreAddons
    KF6::ConfigCore
    KF6::ConfigGui
)
target_include_directories(%{APPNAMELC}_static PUBLIC ${CMAKE_BINARY_DIR})

if (ANDROID)
    kirigami_package_breeze_icons(ICONS
        list-add
        help-about
        application-exit
        applications-graphics
    )
else()
    target_link_libraries(%{APPNAMELC}_static PUBLIC Qt::Widgets)
endif()

kconfig_add_kcfg_files(%{APPNAMELC}_static GENERATE_MOC %{APPNAMELC}config.kcfgc)

# Target: main executable
add_executable(%{APPNAMELC} main.cpp)
target_link_libraries(%{APPNAMELC} PUBLIC %{APPNAMELC}_static %{APPNAMELC}_staticplugin)
install(TARGETS %{APPNAMELC} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
