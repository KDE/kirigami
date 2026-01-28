add_library(KirigamiControlsBasic)

target_include_directories(KirigamiControlsBasic PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/../platform
    ${CMAKE_CURRENT_BINARY_DIR}/../platform
)


ecm_add_qml_module(KirigamiControlsBasic URI "org.kde.kirigami.controls.Basic"
    VERSION 2.0
    GENERATE_PLUGIN_SOURCE
    INSTALLED_PLUGIN_TARGET KF6KirigamiControlsBasicplugin
    DEPENDENCIES
        QtQuick
        org.kde.kirigami.controls
        org.kde.kirigami.layouts
        org.kde.kirigami.platform
        org.kde.kirigami.primitives
        org.kde.kirigami.templates
)

ecm_qt_declare_logging_category(KirigamiControlsBasic
    HEADER loggingcategory.h
    IDENTIFIER KirigamiControlsBasicLog
    CATEGORY_NAME kf.kirigami.controls
    DESCRIPTION "KirigamiControlsBasic"
    DEFAULT_SEVERITY Warning
    EXPORT KIRIGAMI
)

ecm_target_qml_sources(KirigamiControlsBasic SOURCES
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

ecm_target_qml_sources(KirigamiControlsBasic PRIVATE PATH private SOURCES
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

ecm_target_qml_sources(KirigamiControlsBasic PRIVATE PATH private/globaltoolbar SOURCES
    private/globaltoolbar/BreadcrumbControl.qml
    private/globaltoolbar/HandleButton.qml
    private/globaltoolbar/NavigationButtons.qml
    private/globaltoolbar/PageRowGlobalToolBarStyleGroup.qml
    private/globaltoolbar/PageRowGlobalToolBarUI.qml
    private/globaltoolbar/ToolBarPageFooter.qml
    private/globaltoolbar/ToolBarPageHeader.qml
)

target_link_libraries(KirigamiControlsBasic
    PUBLIC
    KirigamiPlatform
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
)

set_target_properties(KirigamiControlsBasic PROPERTIES
    VERSION     ${PROJECT_VERSION}
    SOVERSION   6
    EXPORT_NAME "KirigamiControlsBasic"
)

ecm_finalize_qml_module(KirigamiControlsBasic DESTINATION ${KDE_INSTALL_QMLDIR} EXPORT KirigamiTargets)

install(TARGETS KirigamiControlsBasic EXPORT KirigamiTargets ${KF_INSTALL_TARGETS_DEFAULT_ARGS})
