import Addons
import SwiftUI
import hCore
import hCoreUI

/// The "Addons" heading and one row per add-on, shown beneath a cross-sell list.
///
/// Add-ons open the purchase flow rather than a store URL, and building that flow's input
/// needs contract data this module cannot reach, so the tap is handed to the presenting
/// navigation through `onAddonTap`.
public struct CrossSellAddonsSection: View {
    private let addons: [AddonBanner]
    private let onAddonTap: (AddonBanner) -> Void

    public init(addons: [AddonBanner], onAddonTap: @escaping (AddonBanner) -> Void) {
        self.addons = addons
        self.onAddonTap = onAddonTap
    }

    public var body: some View {
        if !addons.isEmpty {
            hSection {
                VStack(spacing: .padding8) {
                    ForEach(addons, id: \.self) { banner in
                        CrossSellRow(
                            title: banner.displayTitle,
                            subtitle: banner.displayDescription,
                            buttonTitle: L10n.crossSellSeePrice,
                            variant: .secondary,
                            pillow: { AddonPillowView(type: banner.addonType) }
                        ) {
                            onAddonTap(banner)
                        }
                    }
                }
            }
            .withHeader(title: L10n.insuranceAddonsSubheading)
            .sectionContainerStyle(.transparent)
        }
    }
}
