import SwiftUI
import hCore

/// 48pt insurance pillow with a "plus" badge, used for addon rows.
public struct AddonPillowView: View {
    private let pillow: PillowType

    public init(pillow: PillowType) {
        self.pillow = pillow
    }

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            pillow.bgImage
                .resizable()
                .frame(width: 48, height: 48)
            Circle()
                .foregroundColor(hFillColor.Opaque.negative)
                .frame(width: 17, height: 17)
                .overlay {
                    Circle().stroke(hBorderColor.primary, lineWidth: 1)
                }
                .overlay {
                    hCoreUIAssets.plus.view
                        .resizable()
                        .frame(width: 17, height: 17)
                        .foregroundColor(hFillColor.Opaque.primary)
                }
        }
        .hCardShadow()
        .accessibilityHidden(true)
    }
}

#Preview {
    VStack(spacing: .padding16) {
        AddonPillowView(pillow: .car)
        AddonPillowView(pillow: .travel)
        AddonPillowView(pillow: .unknown)
    }
    .padding()
}
