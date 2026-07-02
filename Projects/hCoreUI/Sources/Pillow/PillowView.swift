import SwiftUI

public struct PillowView: View {
    private let configuration: PillowConfiguration

    public init(_ configuration: PillowConfiguration) {
        self.configuration = configuration
    }

    public var body: some View {
        ZStack {
            gradient
            PillowHighlightsOverlay(
                highlightStyle: configuration.highlightStyle,
                contrast: configuration.contrast,
                highlightGrain: configuration.highlightGrain,
                grainMixer: configuration.grainMixer
            )
        }
        .compositingGroup()
        .mask(PillowShape())
        .aspectRatio(1, contentMode: .fit)
    }

    @ViewBuilder
    private var gradient: some View {
        if #available(iOS 17.0, *) {
            PillowMeshView(configuration: configuration)
        } else {
            PillowFallbackView(configuration: configuration)
        }
    }
}

#if DEBUG
    #Preview("Car") {
        VStack(spacing: 16) {
            PillowView(.car)
                .frame(width: 240, height: 240)
            PillowView(.car)
                .frame(width: 96, height: 96)
        }
        .padding()
    }
#endif
