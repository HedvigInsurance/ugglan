import Foundation
import hCore

/// Returns offer with removable addons and pricing to show in the removal page.
public struct AddonRemoveOffer: Equatable, Sendable {
    /// Title to show in removal page.
    let pageTitle: String

    /// Description to show in removal page.
    let pageDescription: String

    /// Contact info
    let contractInfo: AddonConfig

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
        contractInfo: AddonConfig,
        currentTotalCost: ItemCost,
        baseCost: ItemCost,
        productVariant: ProductVariant,
        activationDate: Date,
        removableAddons: [ActiveAddon]
    ) {
        self.pageTitle = pageTitle
        self.pageDescription = pageDescription
        self.contractInfo = contractInfo
        self.currentTotalCost = currentTotalCost
        self.baseCost = baseCost
        self.productVariant = productVariant
        self.activationDate = activationDate
        self.removableAddons = removableAddons
    }
}

public struct RemoveAddonInput: Identifiable, Equatable {
    public var id: String { contractInfo.contractId }
    public let contractInfo: AddonConfig
    public let preselectedAddons: Set<String>

    public init(contractInfo: AddonConfig, preselectedAddons: Set<String>) {
        self.contractInfo = contractInfo
        self.preselectedAddons = preselectedAddons
    }
}

public struct AddonRemoveOfferWithSelectedItems: Equatable, Identifiable {
    public let id = UUID().uuidString
    let offer: AddonRemoveOffer
    let preselectedAddons: Set<String>
    let cost: ItemCost?

    public init(offer: AddonRemoveOffer, preselectedAddons: Set<String>, cost: ItemCost?) {
        self.offer = offer
        self.cost = cost
        self.preselectedAddons = preselectedAddons
    }
}
