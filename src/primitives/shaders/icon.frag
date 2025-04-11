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

layout(binding = 1) uniform sampler2D texture_source_0;
#ifdef ENABLE_MIX
layout(binding = 2) uniform sampler2D texture_source_1;
#endif

layout(location = 0) in mediump vec2 uv0;
#ifdef ENABLE_MIX
layout(location = 1) in mediump vec2 uv1;
#endif
layout(location = 0) out mediump vec4 out_color;

const mediump float desaturate_opacity = 0.5;

mediump vec4 texture_color(sampler2D texture_source, mediump vec2 uv)
{
    mediump vec4 color = texture(texture_source, uv);
#ifdef ENABLE_MASK
    color = vec4(uniforms.mask_color.xyz * color.a, color.a);
#endif

    // Highlight effect
    const mediump float gamma = 1.0 / (2.0 * max(0.25, uniforms.highlight_amount * color.a) + 0.5);
    color.rgb = pow(color.rgb, vec3(gamma));

    // Desaturate effect
    color = mix(color, vec4(vec3(dot(color.rgb, vec3(0.2126, 0.7152, 0.0722))) * desaturate_opacity, color.a * desaturate_opacity), uniforms.desaturate_amount);

    return color;
}

void main()
{
#ifdef ENABLE_MIX
    mediump vec4 col = mix(texture_color(texture_source_1, uv1), texture_color(texture_source_0, uv0), uniforms.mix_amount);
#else
    mediump vec4 col = texture_color(texture_source_0, uv0);
#endif

    out_color = col * uniforms.opacity;
}
