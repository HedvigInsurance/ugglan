#include <metal_stdlib>
using namespace metal;

// Squash-and-stretch "bounce" distortion for any SwiftUI view, consumed via
// `.distortionEffect`. `amount` is the signed bounce phase — positive
// stretches the view up, negative squashes it down — anchored at the
// bottom-center so the view appears to bounce off a surface. Volume
// preserving: the view thins as it stretches and widens as it squashes.
// Keep translation out of this shader: sampling outside the rasterized
// layer blanks the view.
[[ stitchable ]] float2 pillowBounce(
    float2 position,
    float2 size,
    float amount
) {
    float stretch = max(1.0 + amount, 1e-3);
    float2 anchor = float2(size.x * 0.5, size.y);
    float2 p = position - anchor;
    // Inverse mapping: to display content scaled by (1/stretch, stretch)
    // about the anchor, sample from the reciprocal.
    p.x *= stretch;
    p.y /= stretch;
    return anchor + p;
}
