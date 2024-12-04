// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-License-Identifier: LGPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

/*!
  \qmltype PlaceholderMessage
  \inqmlmodule org.kde.kirigami

  \brief A placeholder for loading pages.

  Example usage:
  \qml
      Kirigami.Page {
          Kirigami.LoadingPlaceholder {
              anchors.centerIn: parent
          }
      }
  \endqml

  \qml
      Kirigami.Page {
          Kirigami.LoadingPlaceholder {
              anchors.centerIn: parent
              determinate: true
              progressBar.value: loadingValue
          }
      }
  \endqml
 */
Kirigami.PlaceholderMessage {
    id: loadingPlaceholder

    /*!
      \brief This property holds whether the loading message shows a
      determinate progress bar or not.

      This should be true if you want to display the actual
      percentage when it's loading.

      \default false
     */
    property bool determinate: false

    /*!
      \qmlproperty ProgressBar LoadingPlaceholder::progressBar

      \brief This property holds a progress bar.

      This should be used to access the progress bar to change its value.
     */
    property alias progressBar: _progressBar

    text: qsTr("Loading…")

    QQC2.ProgressBar {
        id: _progressBar
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
        Layout.maximumWidth: Kirigami.Units.gridUnit * 20
        indeterminate: !determinate
        from: 0
        to: 100
    }
}
