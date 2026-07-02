#include <metal_stdlib>
using namespace metal;

// Faithful port of the Pillowmaker web tool's mesh-gradient fragment shader.
// Consumed from SwiftUI via `.colorEffect`.

#define PW_TWO_PI 6.28318530718

static float pw_hash21(float2 p) {
    p = fract(p * float2(0.3183099, 0.3678794)) + 0.1;
    p += dot(p, p + 19.19);
    return fract(p.x * p.y);
}

static float pw_valueNoise(float2 st) {
    float2 i = floor(st);
    float2 f = fract(st);
    float a = pw_hash21(i);
    float b = pw_hash21(i + float2(1.0, 0.0));
    float c = pw_hash21(i + float2(0.0, 1.0));
    float d = pw_hash21(i + float2(1.0, 1.0));
    float2 u = f * f * (3.0 - 2.0 * f);
    float x1 = mix(a, b, u.x);
    float x2 = mix(c, d, u.x);
    return mix(x1, x2, u.y);
}

// Matches GLSL mat2(c, -s, s, c): columns are (c, -s) and (s, c).
static float2x2 pw_rotate2(float a) {
    float s = sin(a);
    float c = cos(a);
    return float2x2(c, -s, s, c);
}

[[ stitchable ]] half4 pillowMesh(
    float2 position,
    half4 currentColor,
    float2 size,
    device const float *colorData, int colorLen,   // flattened rgba
    device const float *pointData, int pointLen,    // flattened xy
    float waveX, float waveXShift, float waveY, float waveYShift,
    float mixing, float grainMixer, float grainOverlay, float ditherSeed,
    float uScale, float uRotation, float uOffsetX, float uOffsetY
) {
    // Reconstruct the web tool's `v_objectUV`: a centered, transformed UV.
    // For the default square / scale 1 / no rotation / no offset case this
    // collapses to the raw normalized position.
    float2 centered = position / size;      // 0...1, top-left origin
    centered.y = 1.0 - centered.y;          // flip to GL-style (y up)
    centered -= 0.5;
    centered += float2(-uOffsetX, uOffsetY);
    centered /= max(uScale, 1e-3);
    float r = uRotation * 3.14159265358979 / 180.0;
    centered = pw_rotate2(r) * centered;

    float2 uv = centered + 0.5;             // back to 0...1
    float2 grainUV = uv * 1000.0;

    float grain = pw_valueNoise(grainUV);
    float mixerGrain = 0.4 * grainMixer * (grain - 0.5);

    float radius = smoothstep(0.0, 1.0, length(uv - 0.5));
    float center = 1.0 - radius;
    for (float i = 1.0; i <= 2.0; i += 1.0) {
        uv.x += waveX * center / i * cos(PW_TWO_PI * waveXShift + i * 2.0 * smoothstep(0.0, 1.0, uv.y));
        uv.y += waveY * center / i * cos(PW_TWO_PI * waveYShift + i * 2.0 * smoothstep(0.0, 1.0, uv.x));
    }

    int count = colorLen / 4;

    float3 color = float3(0.0);
    float opacity = 0.0;
    float totalWeight = 0.0;

    float m = pow(mixing, 0.7);
    float power = mix(2.0, 1.0, m);

    for (int i = 0; i < 10; i++) {
        if (i >= count) break;

        float2 pos = float2(pointData[i * 2], pointData[i * 2 + 1]) + mixerGrain;
        float dist = length(uv - pos);

        float4 col = float4(colorData[i * 4], colorData[i * 4 + 1],
                            colorData[i * 4 + 2], colorData[i * 4 + 3]);
        float3 colorFraction = col.rgb * col.a;
        float opacityFraction = col.a;

        dist = pow(dist, power);

        float w = 1.0 / (dist + 1e-3);
        float baseSharpness = mix(0.0, 8.0, clamp(w, 0.0, 1.0));
        float sharpness = mix(baseSharpness, 1.0, m);
        w = pow(w, sharpness);

        color += colorFraction * w;
        opacity += opacityFraction * w;
        totalWeight += w;
    }

    color /= max(1e-4, totalWeight);
    opacity /= max(1e-4, totalWeight);

    float go = pw_valueNoise(pw_rotate2(1.0) * grainUV + float2(3.0));
    go = mix(go, pw_valueNoise(pw_rotate2(2.0) * grainUV + float2(-1.0)), 0.5);
    go = pow(go, 1.3);

    float gv = go * 2.0 - 1.0;
    float3 goColor = float3(step(0.0, gv));
    float goStrength = grainOverlay * abs(gv);
    goStrength = pow(goStrength, 0.8);
    color = mix(color, goColor, 0.35 * goStrength);

    opacity += 0.5 * goStrength;
    opacity = clamp(opacity, 0.0, 1.0);

    // Dither to kill banding (web's applyBandingFix, using fragment coords).
    float dither = (fract(sin(dot(0.014 * position + float2(ditherSeed), float2(12.9898, 78.233))) * 43758.5453123) - 0.5) / 256.0;
    color = clamp(color + dither, 0.0, 1.0);

    // colorEffect expects premultiplied alpha.
    return half4(half3(color) * half(opacity), half(opacity));
}
