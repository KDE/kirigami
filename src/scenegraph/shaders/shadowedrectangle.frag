/*
 *  SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

// See sdf.glsl for the SDF related functions.

// This shader renders a rectangle with rounded corners and a shadow below it.

uniform lowp float opacity;
uniform lowp float size;
uniform lowp vec4 radius;
uniform lowp vec4 color;
uniform lowp vec4 shadowColor;
uniform lowp vec2 offset;
uniform lowp vec2 aspect;

#ifdef CORE_PROFILE
in lowp vec2 uv;
out lowp vec4 out_color;
#else
varying lowp vec2 uv;
#define out_color gl_FragColor
#endif

const lowp float minimum_shadow_radius = 0.05;

void main()
{
    // Scaling factor that is the inverse of the amount of scaling applied to the geometry.
    lowp float inverse_scale = 1.0 / (1.0 + size + length(offset) * 2.0);

    // Correction factor to round the corners of a larger shadow.
    // We want to account for size in regards to shadow radius, so that a larger shadow is
    // more rounded, but only if we are not already rounding the corners due to corner radius.
    lowp vec4 size_factor = 0.5 * (minimum_shadow_radius / max(radius, minimum_shadow_radius));
    lowp vec4 shadow_radius = radius + size * size_factor;

    lowp vec4 col = vec4(0.0);

    // Calculate the shadow's distance field.
    lowp float shadow = sdf_rounded_rectangle(uv - offset * 2.0 * inverse_scale, aspect * inverse_scale, shadow_radius * inverse_scale);
    // Render it, interpolating the color over the distance.
    col = mix(col, shadowColor * sign(size), 1.0 - smoothstep(-size * 0.5, size * 0.5, shadow));

    // Calculate the main rectangle distance field and render it.
    lowp float rect = sdf_rounded_rectangle(uv, aspect * inverse_scale, radius * inverse_scale);

    col = sdf_render(rect, col, color);

    out_color = col * opacity;
}
