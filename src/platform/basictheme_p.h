/*
 *  SPDX-FileCopyrightText: 2017 by Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef BASICTHEME_H
#define BASICTHEME_H

#include "platformtheme.h"

#include "kirigamiplatform_export.h"

namespace Kirigami
{
namespace Platform
{
class BasicTheme;

class KIRIGAMIPLATFORM_EXPORT BasicThemeDefinition : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QColor textColor MEMBER textColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor disabledTextColor MEMBER disabledTextColor NOTIFY changed FINAL)

    Q_PROPERTY(QColor highlightColor MEMBER highlightColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor highlightedTextColor MEMBER highlightedTextColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor backgroundColor MEMBER backgroundColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor alternateBackgroundColor MEMBER alternateBackgroundColor NOTIFY changed FINAL)

    Q_PROPERTY(QColor focusColor MEMBER focusColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor hoverColor MEMBER hoverColor NOTIFY changed FINAL)

    Q_PROPERTY(QColor activeTextColor MEMBER activeTextColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor activeBackgroundColor MEMBER activeBackgroundColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor linkColor MEMBER linkColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor linkBackgroundColor MEMBER linkBackgroundColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor visitedLinkColor MEMBER visitedLinkColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor visitedLinkBackgroundColor MEMBER visitedLinkBackgroundColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor negativeTextColor MEMBER negativeTextColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor negativeBackgroundColor MEMBER negativeBackgroundColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor neutralTextColor MEMBER neutralTextColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor neutralBackgroundColor MEMBER neutralBackgroundColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor positiveTextColor MEMBER positiveTextColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor positiveBackgroundColor MEMBER positiveBackgroundColor NOTIFY changed FINAL)

    Q_PROPERTY(QColor buttonTextColor MEMBER buttonTextColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor buttonBackgroundColor MEMBER buttonBackgroundColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor buttonAlternateBackgroundColor MEMBER buttonAlternateBackgroundColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor buttonHoverColor MEMBER buttonHoverColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor buttonFocusColor MEMBER buttonFocusColor NOTIFY changed FINAL)

    Q_PROPERTY(QColor viewTextColor MEMBER viewTextColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor viewBackgroundColor MEMBER viewBackgroundColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor viewAlternateBackgroundColor MEMBER viewAlternateBackgroundColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor viewHoverColor MEMBER viewHoverColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor viewFocusColor MEMBER viewFocusColor NOTIFY changed FINAL)

    Q_PROPERTY(QColor selectionTextColor MEMBER selectionTextColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor selectionBackgroundColor MEMBER selectionBackgroundColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor selectionAlternateBackgroundColor MEMBER selectionAlternateBackgroundColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor selectionHoverColor MEMBER selectionHoverColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor selectionFocusColor MEMBER selectionFocusColor NOTIFY changed FINAL)

    Q_PROPERTY(QColor tooltipTextColor MEMBER tooltipTextColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor tooltipBackgroundColor MEMBER tooltipBackgroundColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor tooltipAlternateBackgroundColor MEMBER tooltipAlternateBackgroundColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor tooltipHoverColor MEMBER tooltipHoverColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor tooltipFocusColor MEMBER tooltipFocusColor NOTIFY changed FINAL)

    Q_PROPERTY(QColor complementaryTextColor MEMBER complementaryTextColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor complementaryBackgroundColor MEMBER complementaryBackgroundColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor complementaryAlternateBackgroundColor MEMBER complementaryAlternateBackgroundColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor complementaryHoverColor MEMBER complementaryHoverColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor complementaryFocusColor MEMBER complementaryFocusColor NOTIFY changed FINAL)

    Q_PROPERTY(QColor headerTextColor MEMBER headerTextColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor headerBackgroundColor MEMBER headerBackgroundColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor headerAlternateBackgroundColor MEMBER headerAlternateBackgroundColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor headerHoverColor MEMBER headerHoverColor NOTIFY changed FINAL)
    Q_PROPERTY(QColor headerFocusColor MEMBER headerFocusColor NOTIFY changed FINAL)

    Q_PROPERTY(QFont defaultFont MEMBER defaultFont NOTIFY changed FINAL)
    Q_PROPERTY(QFont smallFont MEMBER smallFont NOTIFY changed FINAL)

public:
    explicit BasicThemeDefinition(QObject *parent = nullptr);

    virtual void syncToQml(PlatformTheme *object);

    QColor textColor = QColor{0x31363b};
    QColor disabledTextColor = QColor{0x31, 0x36, 0x3b, 0x99};

    QColor highlightColor = QColor{0x2196F3};
    QColor highlightedTextColor = QColor{0xeff0fa};
    QColor backgroundColor = QColor{0xeff0f1};
    QColor alternateBackgroundColor = QColor{0xbdc3c7};

    QColor focusColor = QColor{0x2196F3};
    QColor hoverColor = QColor{0x2196F3};

    QColor activeTextColor = QColor{0x0176D3};
    QColor activeBackgroundColor = QColor{0x0176D3};
    QColor linkColor = QColor{0x2196F3};
    QColor linkBackgroundColor = QColor{0x2196F3};
    QColor visitedLinkColor = QColor{0x2196F3};
    QColor visitedLinkBackgroundColor = QColor{0x2196F3};
    QColor negativeTextColor = QColor{0xDA4453};
    QColor negativeBackgroundColor = QColor{0xDA4453};
    QColor neutralTextColor = QColor{0xF67400};
    QColor neutralBackgroundColor = QColor{0xF67400};
    QColor positiveTextColor = QColor{0x27AE60};
    QColor positiveBackgroundColor = QColor{0x27AE60};

    QColor buttonTextColor = QColor{0x31363b};
    QColor buttonBackgroundColor = QColor{0xeff0f1};
    QColor buttonAlternateBackgroundColor = QColor{0xbdc3c7};
    QColor buttonHoverColor = QColor{0x2196F3};
    QColor buttonFocusColor = QColor{0x2196F3};

    QColor viewTextColor = QColor{0x31363b};
    QColor viewBackgroundColor = QColor{0xfcfcfc};
    QColor viewAlternateBackgroundColor = QColor{0xeff0f1};
    QColor viewHoverColor = QColor{0x2196F3};
    QColor viewFocusColor = QColor{0x2196F3};

    QColor selectionTextColor = QColor{0xeff0fa};
    QColor selectionBackgroundColor = QColor{0x2196F3};
    QColor selectionAlternateBackgroundColor = QColor{0x1d99f3};
    QColor selectionHoverColor = QColor{0x2196F3};
    QColor selectionFocusColor = QColor{0x2196F3};

    QColor tooltipTextColor = QColor{0xeff0f1};
    QColor tooltipBackgroundColor = QColor{0x31363b};
    QColor tooltipAlternateBackgroundColor = QColor{0x4d4d4d};
    QColor tooltipHoverColor = QColor{0x2196F3};
    QColor tooltipFocusColor = QColor{0x2196F3};

    QColor complementaryTextColor = QColor{0xeff0f1};
    QColor complementaryBackgroundColor = QColor{0x31363b};
    QColor complementaryAlternateBackgroundColor = QColor{0x3b4045};
    QColor complementaryHoverColor = QColor{0x2196F3};
    QColor complementaryFocusColor = QColor{0x2196F3};

    QColor headerTextColor = QColor{0x232629};
    QColor headerBackgroundColor = QColor{0xe3e5e7};
    QColor headerAlternateBackgroundColor = QColor{0xeff0f1};
    QColor headerHoverColor = QColor{0x2196F3};
    QColor headerFocusColor = QColor{0x93cee9};

    QFont defaultFont;
    QFont smallFont;

    Q_SIGNAL void changed();
    Q_SIGNAL void sync(QQuickItem *object);
};

class BasicThemeInstance : public QObject
{
    Q_OBJECT

public:
    explicit BasicThemeInstance(QObject *parent = nullptr);

    BasicThemeDefinition &themeDefinition(QQmlEngine *engine);

    QList<BasicTheme *> watchers;

private:
    void onDefinitionChanged();

    std::unique_ptr<BasicThemeDefinition> m_themeDefinition;
};

class BasicTheme : public PlatformTheme
{
    Q_OBJECT

public:
    explicit BasicTheme(QObject *parent = nullptr);
    ~BasicTheme() override;

    void sync();

protected:
    bool event(QEvent *event) override;

private:
    QColor tint(const QColor &color);
};

}
}

#endif // BASICTHEME_H
