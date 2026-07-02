import SwiftUI

private final class PillowBundleToken {}

extension Bundle {
    static let hCoreUIPillow = Bundle(for: PillowBundleToken.self)
}

struct PillowHighlightsOverlay: View {
    var highlightStyle: PillowHighlightStyle
    var contrast: Double
    var highlightGrain: Double
    var grainMixer: Double

    private var image: Image {
        Image("PillowHighlights", bundle: .hCoreUIPillow)
    }

    private func layer(
        blend: BlendMode,
        opacity: Double,
        scale: CGFloat = 1,
        blur: CGFloat = 0
    ) -> some View {
        image
            .resizable()
            .scaledToFill()
            .blendMode(blend)
            .opacity(opacity)
            .scaleEffect(scale)
            .blur(radius: blur)
            .allowsHitTesting(false)
    }

    private var isShiny: Bool { highlightStyle == .shiny }

    var body: some View {
        ZStack {
            // Style-specific sheen stack (matches GradientCanvas.tsx).
            if isShiny {
                layer(blend: .screen, opacity: 1)
                layer(blend: .screen, opacity: 0.35 + 0.45 * highlightGrain)
                layer(blend: .screen, opacity: 0.35 * highlightGrain, scale: 1.004, blur: 0.45)
            } else {
                layer(blend: .softLight, opacity: 0.55 + 0.35 * highlightGrain)
                layer(blend: .screen, opacity: 0.18 + 0.22 * highlightGrain, scale: 1.002, blur: 0.35)
            }

            // Common contrast/saturation sheen pass. The filter is FIXED per style
            // in the web tool (independent of the Contrast slider).
            image
                .resizable()
                .scaledToFill()
                .blendMode(.overlay)
                .opacity((isShiny ? 0.55 : 0.45) * grainMixer)
                .scaleEffect(1.002)
                .contrast(isShiny ? 1.25 : 1.2)
                .saturation(1.1)
                .allowsHitTesting(false)

            // Contrast slider: solid black, overlay blend, opacity == contrast.
            if contrast > 0 {
                Color.black
                    .blendMode(.overlay)
                    .opacity(contrast)
                    .allowsHitTesting(false)
            }
        }
    }
}
