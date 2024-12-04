/*
 *  SPDX-FileCopyrightText: 2018 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
 *  SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import org.kde.kirigami as Kirigami

//TODO KF6: move somewhere else? kirigami addons?
/*!
  \qmltype AboutPage
  \inqmlmodule org.kde.kirigami

  \brief An "About" page that is ready to integrate in a Kirigami app.

  Allows to have a page that will show the copyright notice of the application
  together with the contributors and some information of which platform it's
  running on.

  \since 5.52
 */
Kirigami.ScrollablePage {
    id: page

//BEGIN properties
    /*!
      \qmlproperty KAboutData AboutPage::aboutData
      \brief This property holds an object with the same shape as KAboutData.

      For example:
      \qml
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
       \endqml

      \sa KAboutData
     */
    property alias aboutData: aboutItem.aboutData

    /*!
      \qmlproperty url AboutPage::getInvolvedUrl

      \brief This property holds a link to a "Get Involved" page.

      default: "https://community.kde.org/Get_Involved when your application id starts with "org.kde.", otherwise is empty
     */
    property alias getInvolvedUrl: aboutItem.getInvolvedUrl

    /*!
      \qmlproperty url AboutPage::donateUrl

      \brief This property holds a link to a "Donate" page.
      \since 5.101

      default: "https://kde.org/community/donations" when application id starts with "org.kde.", otherwise it is empty.
     */
    property alias donateUrl: aboutItem.donateUrl

    /*!
      \qmlproperty bool AboutPage::loadAvatars

      \brief This property controls whether to load avatars by URL.

      If set to false, a fallback "user" icon will be displayed.

      default: \c false
     */
    property alias loadAvatars: aboutItem.loadAvatars

    default property alias _content: aboutItem._content
//END properties

    title: qsTr("About %1").arg(page.aboutData.displayName)

    Kirigami.AboutItem {
        id: aboutItem
        wideMode: page.width >= aboutItem.implicitWidth

        _usePageStack: applicationWindow().pageStack ? true : false
    }
}
