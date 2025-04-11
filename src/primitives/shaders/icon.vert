/*
 *  SPDX-FileCopyrightText: 2025 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#version 440

layout(std140, binding = 0) uniform buf {
    highp mat4 matrix;
    mediump float opacity;

    mediump float mix_amount;
    mediump float highlight_amount;
    mediump float desaturate_amount;
    mediump vec4 mask_color;
} uniforms;

layout(location = 0) in highp vec4 in_vertex;
layout(location = 1) in mediump vec2 in_uv0;
layout(location = 0) out mediump vec2 uv0;

#ifdef ENABLE_MIX
layout(location = 2) in mediump vec2 in_uv1;
layout(location = 1) out mediump vec2 uv1;
#endif

out gl_PerVertex { vec4 gl_Position; };

void main() {
    uv0 = in_uv0;
#ifdef ENABLE_MIX
    uv1 = in_uv1;
#endif
    gl_Position = uniforms.matrix * in_vertex;
}

