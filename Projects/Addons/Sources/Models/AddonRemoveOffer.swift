import Foundation
import hCore

/// Returns offer with removable addons and pricing to show in the removal page.
public struct AddonRemoveOffer: Equatable, Sendable {
    /// Title to show in removal page.
    let pageTitle: String

    /// Description to show in removal page.
    let pageDescription: String

    /// Current agreement total cost.
    let currentTotalCost: ItemCost

    /// Base insurance cost after removal of removable addons.
    let baseCost: ItemCost

    /// Product variant.
    let productVariant: ProductVariant

    /// The date the removal will take effect.
    let activationDate: Date

    /// Addons available for removal.
    let removableAddons: [ActiveAddon]

    public init(
        pageTitle: String,
        pageDescription: String,
        currentTotalCost: ItemCost,
        baseCost: ItemCost,
        productVariant: ProductVariant,
        activationDate: Date,
        removableAddons: [ActiveAddon]
    ) {
        self.pageTitle = pageTitle
        self.pageDescription = pageDescription
        self.currentTotalCost = currentTotalCost
        self.baseCost = baseCost
        self.productVariant = productVariant
        self.activationDate = activationDate
        self.removableAddons = removableAddons
    }
}
