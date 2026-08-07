import SwiftUI
import hCoreUI

public struct AddonPillowView: View {
    private let type: AddonBanner.AddonType

    public init(type: AddonBanner.AddonType) {
        self.type = type
    }

    private var pillowAsset: ImageAsset {
        switch type {
        case .carPlus: hCoreUIAssets.bigPillowCar
        case .travelPlus: hCoreUIAssets.bigPillowVacationHome
        case .unknown: hCoreUIAssets.bigPillowHome
        }
    }

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            pillowAsset.view
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
                        .frame(width: 10, height: 10)
                        .foregroundColor(hFillColor.Opaque.primary)
                }
        }
        .hShadow(type: .custom(opacity: 0.05, radius: 5, xOffset: 0, yOffset: 4), show: true)
        .hShadow(type: .custom(opacity: 0.1, radius: 1, xOffset: 0, yOffset: 2), show: true)
    }
}

#Preview {
    VStack(spacing: .padding16) {
        AddonPillowView(type: .carPlus)
        AddonPillowView(type: .travelPlus)
        AddonPillowView(type: .unknown)
    }
    .padding()
}
