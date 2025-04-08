/*
 *  SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

layout(std140, binding = 0) uniform buf {
    highp mat4 matrix;
    mediump float opacity;

    mediump vec2 aspect;

    mediump float size;
    mediump vec4 radius;
    mediump vec2 offset;

    mediump vec4 color;
    mediump vec4 shadowColor;

    mediump float borderWidth;
    mediump vec4 borderColor;
} ubuf; // size 160
