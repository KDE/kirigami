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
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives
import org.kde.kirigami.layouts as KL
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
       \sa FormLayout::wideMode
     */
    property alias wideMode: form.wideMode

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

        RowLayout {
            id: delegate

            // type: KAboutPerson | { name?, task?, emailAddress?, webAddress?, avatarUrl? }
            required property var modelData

            property bool hasAvatar: aboutItem.__hasAvatar(modelData)

            Layout.fillWidth: true

            spacing: Platform.Units.smallSpacing * 2

            Primitives.Icon {
                id: avatarIcon

                implicitWidth: Platform.Units.iconSizes.medium
                implicitHeight: implicitWidth

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
                implicitWidth: Platform.Units.iconSizes.medium
                implicitHeight: implicitWidth

                visible: avatarIcon.status === Primitives.Icon.Loading
                running: visible
            }

            QQC2.Label {
                Layout.fillWidth: true
                readonly property bool withTask: typeof(delegate.modelData.task) !== "undefined" && delegate.modelData.task.length > 0
                text: withTask ? qsTr("%1 (%2)").arg(delegate.modelData.name).arg(delegate.modelData.task) : delegate.modelData.name
                wrapMode: Text.WordWrap
            }

            QQC2.ToolButton {
                enabled: typeof(delegate.modelData.webAddress) !== "undefined" && delegate.modelData.webAddress.length > 0
                opacity: enabled ? 1 : 0
                icon.name: "globe"
                QQC2.ToolTip.delay: Platform.Units.toolTipDelay
                QQC2.ToolTip.visible: hovered
                QQC2.ToolTip.text: (typeof(delegate.modelData.webAddress) === "undefined" && delegate.modelData.webAddress.length > 0) ? "" : delegate.modelData.webAddress
                onClicked: Qt.openUrlExternally(delegate.modelData.webAddress)
            }

            QQC2.ToolButton {
                enabled: typeof(delegate.modelData.emailAddress) !== "undefined" && delegate.modelData.emailAddress.length > 0
                opacity: enabled ? 1 : 0
                icon.name: "mail-sent"
                QQC2.ToolTip.delay: Platform.Units.toolTipDelay
                QQC2.ToolTip.visible: hovered
                QQC2.ToolTip.text: qsTr("Send an email to %1").arg(delegate.modelData.emailAddress)
                onClicked: Qt.openUrlExternally("mailto:%1".arg(delegate.modelData.emailAddress))
            }
        }
    }

    KL.FormLayout {
        id: form

        anchors.fill: parent

        GridLayout {
            columns: 2
            Layout.fillWidth: true

            Primitives.Icon {
                Layout.rowSpan: 3
                Layout.preferredHeight: Platform.Units.iconSizes.huge
                Layout.preferredWidth: height
                Layout.maximumWidth: aboutItem.width / 3;
                Layout.rightMargin: Platform.Units.largeSpacing
                source: Platform.Settings.applicationWindowIcon || aboutItem.aboutData.programLogo || aboutItem.aboutData.componentName
            }

            KC.Heading {
                Layout.fillWidth: true
                text: aboutItem.aboutData.displayName + " " + aboutItem.aboutData.version
                wrapMode: Text.WordWrap
            }

            KC.Heading {
                Layout.fillWidth: true
                level: 3
                type: KC.Heading.Type.Secondary
                wrapMode: Text.WordWrap
                text: aboutItem.aboutData.shortDescription
            }

            RowLayout {
                spacing: Platform.Units.largeSpacing * 2

                UrlButton {
                    text: qsTr("Get Involved")
                    url: aboutItem.getInvolvedUrl
                    visible: url.toString().length > 0
                }

                UrlButton {
                    text: qsTr("Donate")
                    url: aboutItem.donateUrl
                    visible: url.toString().length > 0
                }

                UrlButton {
                    readonly property string theUrl: {
                        if (aboutItem.aboutData.bugAddress !== "submit@bugs.kde.org") {
                            return aboutItem.aboutData.bugAddress
                        }
                        const elements = aboutItem.aboutData.productName.split('/');
                        let url = `https://bugs.kde.org/enter_bug.cgi?format=guided&product=${elements[0]}&version=${aboutItem.aboutData.version}`;
                        if (elements.length === 2) {
                            url += "&component=" + elements[1];
                        }
                        return url;
                    }
                    text: qsTr("Report a Bug")
                    url: theUrl
                    visible: theUrl.toString().length > 0
                }
            }
        }

        Primitives.Separator {
            Layout.fillWidth: true
        }

        KC.Heading {
            KL.FormData.isSection: true
            text: qsTr("Copyright")
        }

        QQC2.Label {
            Layout.leftMargin: Platform.Units.gridUnit
            text: aboutItem.aboutData.otherText
            visible: text.length > 0
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        QQC2.Label {
            Layout.leftMargin: Platform.Units.gridUnit
            text: aboutItem.aboutData.copyrightStatement
            visible: text.length > 0
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        UrlButton {
            Layout.leftMargin: Platform.Units.gridUnit
            url: aboutItem.aboutData.homepage
            visible: url.length > 0
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            Layout.maximumWidth: aboutItem.width
        }

        OverlaySheet {
            id: licenseSheet
            property alias text: bodyLabel.text

            contentItem: SelectableLabel {
                id: bodyLabel
                text: licenseSheet.text
                wrapMode: Text.Wrap
            }
        }

        Component {
            id: licenseLinkButton

            RowLayout {
                id: licenseLinkLayout

                required property var modelData

                Layout.leftMargin: Platform.Units.smallSpacing

                QQC2.Label { text: qsTr("License:") }

                LinkButton {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    text: licenseLinkLayout.modelData.name
                    onClicked: mouse => {
                        licenseSheet.text = licenseLinkLayout.modelData.text
                        licenseSheet.title = licenseLinkLayout.modelData.name
                        licenseSheet.open()
                    }
                }
            }
        }

        Component {
            id: licenseTextItem

            QQC2.Label {
                required property var modelData
                Layout.leftMargin: Platform.Units.smallSpacing
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: qsTr("License: %1").arg(modelData.name)
            }
        }

        Repeater {
            model: aboutItem.aboutData.licenses
            delegate: aboutItem._usePageStack ? licenseLinkButton : licenseTextItem
        }

        KC.Heading {
            KL.FormData.isSection: visible
            text: qsTr("Libraries in use")
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            visible: Platform.Settings.information
        }

        Repeater {
            model: Platform.Settings.information
            delegate: QQC2.Label {
                required property string modelData
                Layout.leftMargin: Platform.Units.gridUnit
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                id: libraries
                text: modelData
            }
        }

        Repeater {
            model: aboutItem.aboutData.components
            delegate: QQC2.Label {
                required property var modelData
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                Layout.leftMargin: Platform.Units.gridUnit
                text: modelData.name + (modelData.version.length === 0 ? "" : " %1".arg(modelData.version))
            }
        }

        KC.Heading {
            Layout.fillWidth: true
            KL.FormData.isSection: visible
            text: qsTr("Authors")
            wrapMode: Text.WordWrap
            visible: aboutItem.aboutData.authors.length > 0
        }

        QQC2.CheckBox {
            id: remoteAvatars
            visible: aboutItem.__hasAvatars
            checked: aboutItem.loadAvatars
            onToggled: aboutItem.loadAvatars = checked
            text: qsTr("Show author photos")
        }

        Repeater {
            id: authorsRepeater
            model: aboutItem.aboutData.authors
            delegate: personDelegate
        }

        KC.Heading {
            KL.FormData.isSection: visible
            text: qsTr("Credits")
            visible: repCredits.count > 0
        }

        Repeater {
            id: repCredits
            model: aboutItem.aboutData.credits
            delegate: personDelegate
        }

        KC.Heading {
            KL.FormData.isSection: visible
            text: qsTr("Translators")
            visible: repTranslators.count > 0
        }

        Repeater {
            id: repTranslators
            model: aboutItem.aboutData.translators
            delegate: personDelegate
        }
    }
}
