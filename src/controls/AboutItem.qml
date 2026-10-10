/*
 *  SPDX-FileCopyrightText: 2018 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Window
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives
import org.kde.kirigami.forms as KF
import org.kde.kirigami.controls as KC

//TODO: Kf6: move somewhere else which can depend from KAboutData?
/*!
  \qmltype AboutItem
  \inqmlmodule org.kde.kirigami
  \brief An about item that displays the about data.

  Allows to show the copyright notice of the application
  together with the contributors and some information of which platform it's
  running on.

  \since 5.87
 */
Item {
    id: aboutItem
    /*!
      \brief This property holds an object with the same shape as KAboutData.

      Example usage:
      \badcode
      aboutData: {
          "displayName" : "KirigamiApp",
          "productName" : "kirigami/app",
          "componentName" : "kirigamiapp",
          "shortDescription" : "A Kirigami example",
          "homepage" : "",
          "bugAddress" : "submit@bugs.kde.org",
          "version" : "5.14.80",
          "otherText" : "",
          "authors" : [
              {
                  "name" : "...",
                  "task" : "",
                  "emailAddress" : "somebody@kde.org",
                  "webAddress" : "",
                  "ocsUsername" : ""
              }
          ],
          "credits" : [],
          "translators" : [],
          "licenses" : [
              {
                  "name" : "GPL v2",
                  "text" : "long, boring, license text",
                  "spdx" : "GPL-2.0"
              }
          ],
          "copyrightStatement" : "© 2010-2018 Plasma Development Team",
          "desktopFileName" : "org.kde.kirigamiapp"
       }
       \endcode

      \sa KAboutData
     */
    property var aboutData

    /*!
      \brief This property holds a link to a "Get Involved" page.

      default: "https://community.kde.org/Get_Involved" when application id starts with "org.kde.", otherwise it is empty.
     */
    property url getInvolvedUrl: aboutData.desktopFileName.startsWith("org.kde.") ? "https://community.kde.org/Get_Involved" : ""

    /*!
      \brief This property holds a link to a "Donate" page.

      default: "https://kde.org/community/donations" when application id starts with "org.kde.", otherwise it is empty.
     */
    property url donateUrl: aboutData.desktopFileName.startsWith("org.kde.") ? "https://kde.org/community/donations" : ""

    property bool _usePageStack: false

    /*!
       \qmlproperty bool wideMode
       Deprecated: this property has no effect
     */
    property bool wideMode: false

    default property alias _content: form.data

    // if aboutData is a native KAboutData object, avatarUrl should be a proper url instance,
    // otherwise if it was defined as a string in pure JavaScript it should work too.
    readonly property bool __hasAvatars: aboutItem.aboutData.authors.some(__hasAvatar)

    function __hasAvatar(person): bool {
        return typeof person.avatarUrl !== "undefined"
            && person.avatarUrl.toString().length > 0;
    }

    /*!
      \brief This property controls whether to load avatars by URL.

      If set to false, a fallback "user" icon will be displayed.

      default: false
     */
    property bool loadAvatars: false

    implicitHeight: form.implicitHeight
    implicitWidth: form.implicitWidth

    Component {
        id: personDelegate

        KF.FormEntry {
            id: delegate

            // type: KAboutPerson | { name?, task?, emailAddress?, webAddress?, avatarUrl? }
            required property var modelData

            property bool hasAvatar: aboutItem.__hasAvatar(modelData)


            leadingItems: Item {
                implicitWidth: Platform.Units.iconSizes.medium
                implicitHeight: implicitWidth

                Primitives.Icon {
                    id: avatarIcon

                    anchors.fill: parent

                    fallback: "user"
                    source: {
                        if (delegate.hasAvatar && aboutItem.loadAvatars) {
                            // Appending to the params of the url does not work, thus the search is set
                            const url = new URL(delegate.modelData.avatarUrl);
                            const params = new URLSearchParams(url.search);
                            params.append("s", width);
                            url.search = params.toString();
                            return url;
                        } else {
                            return "user"
                        }
                    }
                    visible: status !== Primitives.Icon.Loading
                }

                // So it's clear that something is happening while avatar images are loaded
                QQC2.BusyIndicator {
                    anchors.centerIn: parent
                    implicitWidth: Platform.Units.iconSizes.medium
                    implicitHeight: implicitWidth

                    visible: avatarIcon.status === Primitives.Icon.Loading
                    running: visible
                }
            }

            contentItem: QQC2.Label {
                readonly property bool withTask: typeof(delegate.modelData.task) !== "undefined" && delegate.modelData.task.length > 0
                text: delegate.modelData.name
                wrapMode: Text.WordWrap
            }

            subtitle: delegate.modelData.task

            trailingItems: [
                QQC2.ToolButton {
                    visible: typeof(delegate.modelData.ocsUsername) !== "undefined" && delegate.modelData.ocsUsername.length > 0
                    icon.name: "get-hot-new-stuff-symbolic"
                    QQC2.ToolTip.delay: Platform.Units.toolTipDelay
                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.text: qsTr("Visit %1's KDE Store page").arg(delegate.modelData.name)
                    onClicked: Qt.openUrlExternally("https://store.kde.org/u/%1".arg(delegate.modelData.ocsUsername))
                },
                QQC2.ToolButton {
                    visible: typeof(delegate.modelData.webAddress) !== "undefined" && delegate.modelData.webAddress.length > 0
                    icon.name: "globe"
                    QQC2.ToolTip.delay: Platform.Units.toolTipDelay
                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.text: (typeof(delegate.modelData.webAddress) === "undefined" && delegate.modelData.webAddress.length > 0) ? "" : delegate.modelData.webAddress
                    onClicked: Qt.openUrlExternally(delegate.modelData.webAddress)
                },
                QQC2.ToolButton {
                    visible: typeof(delegate.modelData.emailAddress) !== "undefined" && delegate.modelData.emailAddress.length > 0
                    icon.name: "mail-sent"
                    QQC2.ToolTip.delay: Platform.Units.toolTipDelay
                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.text: qsTr("Send an email to %1").arg(delegate.modelData.emailAddress)
                    onClicked: Qt.openUrlExternally("mailto:%1".arg(delegate.modelData.emailAddress))
                }
            ]
        }
    }

    KF.Form {
        id: form

        anchors.fill: parent

        KF.FormGroup {
            KF.FormEntry {
                contentItem: ColumnLayout {
                    KC.Heading {
                        Layout.fillWidth: true
                        text: aboutItem.aboutData.displayName + " " + aboutItem.aboutData.version
                    }
                    KC.Heading {
                        Layout.fillWidth: true
                        level: 3
                        type: KC.Heading.Type.Secondary
                        wrapMode: Text.WordWrap
                        text: aboutItem.aboutData.shortDescription
                    }
                }
                leadingItems: Primitives.Icon {
                    Layout.preferredHeight: Platform.Units.iconSizes.huge
                    Layout.preferredWidth: height
                    Layout.maximumWidth: aboutItem.width / 3;
                    Layout.rightMargin: Platform.Units.largeSpacing
                    source: aboutItem.aboutData.programLogo || Platform.Settings.applicationWindowIcon || aboutItem.aboutData.componentName
                }
            }
            KF.FormSeparator {}
            KF.FormEntry {
                contentItem: QQC2.Label {
                    text: qsTr("Copyright")
                }
                // FIXME
                subtitle: aboutItem.aboutData.copyrightStatement
                visible: subtitle.length > 0
            }
        }

        KF.FormGroup {
            title: qsTr("License")
            Repeater {
                model: aboutItem.aboutData.licenses
                delegate: KF.FormAction {
                    id: licenseLinkButton
                    required property var modelData
                    action: KC.Action {
                        text: licenseLinkButton.modelData.name
                        onTriggered: {
                            licenseSheet.text = licenseLinkButton.modelData.text
                            licenseSheet.title = licenseLinkButton.modelData.name
                            licenseSheet.open()
                        }
                    }
                }
            }
        }

        KF.FormGroup {
            KF.FormAction {
                action: KC.Action {
                    icon.name: "globe-symbolic"
                    text: qsTr("Homepage")
                    onTriggered: {
                        Qt.openUrlExternally(aboutItem.aboutData.homepage)
                    }
                }
                triggerIcon.name: "open-link-symbolic"
                visible: aboutItem.aboutData.homepage.toString().length > 0
            }
            KF.FormSeparator {
                visible: aboutItem.aboutData.homepage.toString().length > 0
            }
            KF.FormAction {
                action: KC.Action {
                    icon.name: "donate-symbolic"
                    text: qsTr("Donate")
                    onTriggered: {
                        Qt.openUrlExternally(aboutItem.donateUrl + "?app=" + aboutItem.aboutData.componentName)
                    }
                }
                triggerIcon.name: "open-link-symbolic"
                visible: aboutItem.donateUrl.toString().length > 0
            }
            KF.FormSeparator {
                visible: aboutItem.donateUrl.toString().length > 0
            }
            KF.FormAction {
                action: KC.Action {
                    icon.name: "applications-development-symbolic"
                    text: qsTr("Get Involved")
                    onTriggered: {
                        Qt.openUrlExternally(aboutItem.getInvolvedUrl)
                    }
                }
                triggerIcon.name: "open-link-symbolic"
                visible: aboutItem.getInvolvedUrl.toString().length > 0
            }
            KF.FormSeparator {
                visible: aboutItem.getInvolvedUrl.toString().length > 0
            }
            KF.FormAction {
                action: KC.Action {
                    icon.name: "tools-report-bug-symbolic"
                    text: qsTr("Report a bug")
                    onTriggered: {
                        if (aboutItem.aboutData.bugAddress !== "submit@bugs.kde.org") {
                            Qt.openUrlExternally(aboutItem.aboutData.bugAddress)
                        }
                        const elements = aboutItem.aboutData.productName.split('/');
                        let url = `https://bugs.kde.org/enter_bug.cgi?format=guided&product=${elements[0]}&version=${aboutItem.aboutData.version}`;
                        if (elements.length === 2) {
                            url += "&component=" + elements[1];
                        }
                        Qt.openUrlExternally(url)
                    }
                }
                triggerIcon.name: "open-link-symbolic"
            }
        }

        KF.FormGroup {
            title: qsTr("Libraries in use")
            Repeater {
                model: Platform.Settings.information
                delegate: KF.FormEntry {
                    id: delegate
                    required property string modelData
                    contentItem:  QQC2.Label {
                        wrapMode: Text.WordWrap
                        id: libraries
                        text: delegate.modelData
                    }
                }
            }
            Repeater {
                model: aboutItem.aboutData.components
                delegate: KF.FormEntry {
                    id: delegate
                    required property var modelData
                    contentItem:  QQC2.Label {
                        wrapMode: Text.WordWrap
                        text: "%1 %2".arg(delegate.modelData.name, delegate.modelData.version)
                    }
                }
            }
        }

        QQC2.CheckBox {
            id: remoteAvatars
            visible: aboutItem.__hasAvatars
            checked: aboutItem.loadAvatars
            onToggled: aboutItem.loadAvatars = checked
            text: qsTr("Show author photos")
        }
        KF.FormGroup {
            title: qsTr("Authors")
            visible: repAuthors.count > 0
            Repeater {
                id: repAuthors
                model: aboutItem.aboutData.authors
                delegate: personDelegate
            }
        }

        KF.FormGroup {
            title: qsTr("Credits")
            visible: repCredits.count > 0
            Repeater {
                id: repCredits
                model: aboutItem.aboutData.credits
                delegate: personDelegate
            }
        }

        KF.FormGroup {
            title: qsTr("Translators")
            visible: repTranslators.count > 0
            Repeater {
                id: repTranslators
                model: aboutItem.aboutData.translators
                delegate: personDelegate
            }
        }

        OverlaySheet {
            id: licenseSheet
            width: Math.min(aboutItem.width - Platform.Units.gridUnit * 2, bodyLabel.implicitWidth)
            height: parent.Window.window.height - Platform.Units.gridUnit * 8
            property alias text: bodyLabel.text

            SelectableLabel {
                id: bodyLabel
                text: licenseSheet.text
                wrapMode: Text.Wrap
            }
        }
    }
}
