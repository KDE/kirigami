
add_library(KirigamiControls)
ecm_add_qml_module(KirigamiControls URI "org.kde.kirigami.controls" VERSION 2.0
    CLASS_NAME KirigamiControlsPlugin
    INSTALLED_PLUGIN_TARGET KF6KirigamiControlsplugin
    DEPENDENCIES
        QtQuick
        org.kde.kirigami.layouts
        org.kde.kirigami.platform
        org.kde.kirigami.primitives
        org.kde.kirigami.templates
)

ecm_qt_declare_logging_category(KirigamiControls
    HEADER loggingcategory.h
    IDENTIFIER KirigamiControlsLog
    CATEGORY_NAME kf.kirigami.controls
    DESCRIPTION "KirigamiControls"
    DEFAULT_SEVERITY Warning
    EXPORT KIRIGAMI
)

ecm_target_qml_sources(KirigamiControls SOURCES
    AboutItem.qml
    AboutPage.qml
    AbstractApplicationHeader.qml
    AbstractApplicationItem.qml
    AbstractApplicationWindow.qml
    AbstractCard.qml
    Action.qml
    ActionTextField.qml
    ActionToolBar.qml
    ApplicationItem.qml
    ApplicationWindow.qml
    Card.qml
    CardsLayout.qml
    CardsListView.qml
    Chip.qml
    ContextDrawer.qml
    ContextualHelpButton.qml
    FlexColumn.qml
    GlobalDrawer.qml
    Heading.qml
    InlineMessage.qml
    InlineViewHeader.qml
    LinkButton.qml
    ListItemDragHandle.qml
    ListSectionHeader.qml
    LoadingPlaceholder.qml
    NavigationTabBar.qml
    NavigationTabButton.qml
    OverlayDrawer.qml
    OverlaySheet.qml
    Page.qml
    PagePoolAction.qml
    PageRow.qml
    PasswordField.qml
    PlaceholderMessage.qml
    ScrollablePage.qml
    SearchField.qml
    SelectableLabel.qml
    SwipeListItem.qml
    UrlButton.qml
)

ecm_target_qml_sources(KirigamiControls PRIVATE PATH private SOURCES
    private/ActionMenuItem.qml
    private/ActionsMenu.qml
    private/BannerImage.qml
    private/ContextDrawerActionItem.qml
    private/DefaultCardBackground.qml
    private/DefaultChipBackground.qml
    private/DefaultPageTitleDelegate.qml
    private/EdgeShadow.qml
    private/GlobalDrawerActionItem.qml
    private/MobileDialogLayer.qml
    private/PassiveNotificationsManager.qml
    private/PrivateActionToolButton.qml
    private/PullDownIndicator.qml
    private/SwipeItemEventFilter.qml
)

ecm_target_qml_sources(KirigamiControls PRIVATE PATH private/globaltoolbar SOURCES
    private/globaltoolbar/BreadcrumbControl.qml
    private/globaltoolbar/HandleButton.qml
    private/globaltoolbar/NavigationButtons.qml
    private/globaltoolbar/PageRowGlobalToolBarStyleGroup.qml
    private/globaltoolbar/PageRowGlobalToolBarUI.qml
    private/globaltoolbar/ToolBarPageFooter.qml
    private/globaltoolbar/ToolBarPageHeader.qml
)

target_include_directories(KirigamiControlsplugin PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/..)

target_sources(KirigamiControls PRIVATE
    enums.h
    pagepool.cpp
    pagepool.h
)

target_sources(KirigamiControlsplugin PRIVATE
    kirigamicontrolsplugin.cpp
    kirigamicontrolsplugin.h
)

target_link_libraries(KirigamiControls
    PUBLIC
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    KirigamiPlatform
)

set_target_properties(KirigamiControls PROPERTIES
    VERSION     ${PROJECT_VERSION}
    SOVERSION   6
    EXPORT_NAME "KirigamiControls"
)

target_include_directories(KirigamiControls PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/..)

ecm_finalize_qml_module(KirigamiControls EXPORT KirigamiTargets)

install(TARGETS KirigamiControls EXPORT KirigamiTargets ${KF_INSTALL_TARGETS_DEFAULT_ARGS})

