import Foundation
import hCore

/// Reports each offer as shown at most once per visit to the surface it is on.
///
/// Keep one per visit, never one per row: for a list, from when it appears on screen until it disappears;
/// for a sheet, one opening.
@MainActor
public final class CrossSellShownTracker {
    private var shownOfferIds = Set<String>()

    public init() {}

    public func offerWasShown(_ crossSell: CrossSell) {
        guard shownOfferIds.insert(crossSell.id).inserted else { return }
        crossSell.track(.shown)
    }

    /// Add-on recommendations are not tracked as cross-sells.
    public func offerWasShown(_ recommended: RecommendedCrossSell) {
        if case let .insurance(crossSell) = recommended {
            offerWasShown(crossSell)
        }
    }

    public func endVisit() {
        shownOfferIds.removeAll()
    }
}
