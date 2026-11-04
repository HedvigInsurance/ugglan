import Foundation
import hCore

/// Returns offer with removable addons and pricing to show in the removal page.
public struct AddonRemoveOffer: Equatable, Sendable {
    /// Title to show in removal page.
    public let pageTitle: String

    /// Description to show in removal page.
    public let pageDescription: String

    /// Contact info
    public let contractInfo: AddonContractInfo

    /// Current agreement total cost.
    public let currentTotalCost: ItemCost

    /// Base insurance cost after removal of removable addons.
    public let baseCost: ItemCost

    /// Product variant.
    public let productVariant: ProductVariant

    /// The date the removal will take effect.
    public let activationDate: Date

    /// Addons available for removal.
    public let removableAddons: [ActiveAddon]

    public init(
        pageTitle: String,
        pageDescription: String,
        contractInfo: AddonContractInfo,
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
    public let contractInfo: AddonContractInfo
    public let preselectedAddons: Set<String>

    public init(contractInfo: AddonContractInfo, preselectedAddons: Set<String>) {
        self.contractInfo = contractInfo
        self.preselectedAddons = preselectedAddons
    }
}

public struct AddonRemoveOfferWithSelectedItems: Equatable, Identifiable {
    public let id = UUID().uuidString
    public let offer: AddonRemoveOffer
    public let preselectedAddons: Set<String>
    public let cost: ItemCost?

    public init(offer: AddonRemoveOffer, preselectedAddons: Set<String>, cost: ItemCost?) {
        self.offer = offer
        self.cost = cost
        self.preselectedAddons = preselectedAddons
    }
}
