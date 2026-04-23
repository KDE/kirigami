/*
    SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami.dialogs as KirigamiDialogs
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.controls as KirigamiControls
import org.kde.kirigami.primitives as Primitives
import org.kde.kirigami.layouts as KirigamiLayouts

/*!
  \qmltype PromptDialog
  \inqmlmodule org.kde.kirigami.dialogs

  \brief A simple dialog to quickly prompt a user with information,
  and possibly perform an action.

  Provides content padding (instead of padding outside of the scroll
  area). Also has a default preferredWidth, as well as the subtitle property.

  \note If a mainItem is specified, it will replace
  the subtitle label, and so the respective property will have no effect.

  \sa Dialog
  \sa MenuDialog

  Example usage:

  \qml
  Kirigami.PromptDialog {
      title: "Reset settings?"
      subtitle: "The stored settings for the application will be deleted, with the defaults restored."
      standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel

      onAccepted: console.log("Accepted")
      onRejected: console.log("Rejected")
  }
  \endqml

  Text field prompt dialog:

  \qml
  Kirigami.PromptDialog {
      id: textPromptDialog
      title: qsTr("New Folder")

      standardButtons: Kirigami.Dialog.NoButton
      customFooterActions: [
          Kirigami.Action {
              text: qsTr("Create Folder")
              icon.name: "dialog-ok"
              onTriggered: {
                  showPassiveNotification("Created");
                  textPromptDialog.close();
              }
          },
          Kirigami.Action {
              text: qsTr("Cancel")
              icon.name: "dialog-cancel"
              onTriggered: {
                  textPromptDialog.close();
              }
          }
      ]

      QQC2.TextField {
          placeholderText: qsTr("Folder name…")
      }
  }
  \endqml
 */
KirigamiDialogs.Dialog {
    id: root

    default property alias mainItem: mainLayout.data

    enum DialogType {
        Success,
        Warning,
        Error,
        Information,
        None
    }

    /*!
      This property holds the dialogType. It can be either:
      \list
      \li PromptDialog.Success: For a success message
      \li PromptDialog.Warning: For a warning message
      \li PromptDialog.Error: For an actual error
      \li PromptDialog.Information: For an informational message
      \li PromptDialog.None: No specific dialog type.
      \endlist

      By default, the dialogType is PromptDialog.None
     */
    property int dialogType: PromptDialog.None

    /*!
      The text to use in the dialog's contents.
     */
    property string subtitle

    /*!
      The padding around the content, within the scroll area.

      Default is Kirigami.Units.largeSpacing.
     */
    property real contentPadding: Platform.Units.largeSpacing

    /*!
      The top padding of the content, within the scroll area.
     */
    property real contentTopPadding: contentPadding

    /*!
      The bottom padding of the content, within the scroll area.
     */
    property real contentBottomPadding: footer.padding === 0 ? contentPadding : 0 // add bottom padding if there is no footer

    /*!
      The left padding of the content, within the scroll area.
     */
    property real contentLeftPadding: contentPadding

    /*!
      The right padding of the content, within the scroll area.
     */
    property real contentRightPadding: contentPadding

    /*!
      This property holds the icon name used by the PromptDialog.
     */
    property string iconName: switch (dialogType) {
    case PromptDialog.Success:
        return "data-success";
    case PromptDialog.Warning:
        return "data-warning";
    case PromptDialog.Error:
        return "data-error";
    case PromptDialog.Information:
        return "data-information";
    default:
        return "";
    }

    padding: 0

    header: null

    KirigamiLayouts.Padding {
        id: wrapper

        topPadding: root.contentTopPadding
        leftPadding: root.contentLeftPadding
        rightPadding: root.contentRightPadding
        bottomPadding: root.contentBottomPadding

        contentItem: RowLayout {
            spacing: Platform.Units.largeSpacing

            Primitives.Icon {
                source: root.iconName
                visible: root.iconName.length > 0

                Layout.preferredWidth: Platform.Units.iconSizes.huge
                Layout.preferredHeight: Platform.Units.iconSizes.huge
                Layout.alignment: Qt.AlignTop
            }

            ColumnLayout {
                id: mainLayout

                spacing: Platform.Units.smallSpacing

                Layout.fillWidth: true

                ColumnLayout {
                    spacing: 0

                    KirigamiControls.Heading {
                        text: root.title
                        visible: (!root.hasOwnProperty("popupType") || root.popupType === QQC2.Popup.Item) && root.title.length > 0
                        elide: QQC2.Label.ElideRight
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    KirigamiControls.SelectableLabel {
                        text: root.subtitle
                        wrapMode: TextEdit.Wrap
                        visible: text.length > 0
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }
}
