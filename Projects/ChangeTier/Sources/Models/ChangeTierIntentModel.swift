import Foundation
import hCore
import hCoreUI
import hGraphQL

public struct ChangeTierIntentModel: Codable, Equatable, Hashable {
    let displayName: String
    let activationDate: Date
    let tiers: [Tier]
    let currentPremium: MonetaryAmount?
    let currentTier: Tier?
    let currentDeductible: Quote?
    let selectedTier: Tier?
    let selectedDeductible: Quote?
    let canEditTier: Bool
    let typeOfContract: TypeOfContract

    public init(
        displayName: String,
        activationDate: Date,
        tiers: [Tier],
        currentPremium: MonetaryAmount?,
        currentTier: Tier?,
        currentDeductible: Quote?,
        selectedTier: Tier?,
        selectedDeductible: Quote?,
        canEditTier: Bool,
        typeOfContract: TypeOfContract
    ) {
        self.displayName = displayName
        self.activationDate = activationDate
        self.tiers = tiers
        self.currentPremium = currentPremium
        self.currentTier = currentTier
        self.currentDeductible = currentDeductible
        self.selectedTier = selectedTier
        self.selectedDeductible = selectedDeductible
        self.canEditTier = canEditTier
        self.typeOfContract = typeOfContract
    }
}

public struct Tier: Codable, Equatable, Hashable, Identifiable {
    public var id: String
    let name: String
    let level: Int
    public let deductibles: [Quote]
    let exposureName: String?

    public init(
        id: String,
        name: String,
        level: Int,
        deductibles: [Quote],
        exposureName: String?
    ) {
        self.id = id
        self.name = name
        self.level = level
        self.deductibles = deductibles
        self.exposureName = exposureName
    }

    func getPremium() -> MonetaryAmount? {
        if deductibles.count == 1 {
            return deductibles.first?.premium
        }
        return nil
    }
}

public struct Quote: Codable, Hashable, Identifiable {
    public var id: String
    let deductibleAmount: MonetaryAmount?
    let deductiblePercentage: Int?
    let subTitle: String?
    let premium: MonetaryAmount

    let displayItems: [DisplayItem]
    public let productVariant: ProductVariant?

    public init(
        id: String,
        deductibleAmount: MonetaryAmount?,
        deductiblePercentage: Int?,
        subTitle: String?,
        premium: MonetaryAmount,
        displayItems: [DisplayItem],
        productVariant: ProductVariant?
    ) {
        self.id = id
        self.deductibleAmount = deductibleAmount
        self.deductiblePercentage = deductiblePercentage
        self.subTitle = subTitle
        self.premium = premium
        self.displayItems = displayItems
        self.productVariant = productVariant
    }

    public struct DisplayItem: Codable, Equatable, Hashable {
        public var id = UUID()

        public init(
            title: String,
            subTitle: String?,
            value: String
        ) {
            self.title = title
            self.subTitle = subTitle
            self.value = value
        }

        let title: String
        let subTitle: String?
        let value: String
    }
}

extension Quote: Equatable {
    static public func == (lhs: Quote, rhs: Quote) -> Bool {
        return lhs.deductibleAmount == rhs.deductibleAmount && lhs.deductiblePercentage == rhs.deductiblePercentage
    }
}
