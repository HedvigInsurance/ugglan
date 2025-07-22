import ChangeTier
import Foundation
import hCore
import hCoreUI

public struct MoveQuotesModel: Sendable {
    let homeQuotes: [MovingFlowQuote]
    let mtaQuotes: [MovingFlowQuote]
    let changeTierModel: ChangeTierIntentModel?

    public init(
        homeQuotes: [MovingFlowQuote],
        mtaQuotes: [MovingFlowQuote],
        changeTierModel: ChangeTierIntentModel?
    ) {
        self.homeQuotes = homeQuotes
        self.mtaQuotes = mtaQuotes
        self.changeTierModel = changeTierModel
    }
}

public struct MovingFlowQuote: Codable, Equatable, Hashable, Sendable {
    typealias KeyValue = (key: String, value: String)
    let grossPremium: MonetaryAmount
    let netPremium: MonetaryAmount
    let startDate: String
    let displayName: String
    let insurableLimits: [InsurableLimits]
    let perils: [Perils]
    let documents: [InsuranceDocument]
    let contractType: TypeOfContract?
    let id: String
    let displayItems: [DisplayItem]
    let exposureName: String?
    let addons: [AddonDataModel]
    let discountDisplayItems: [DisplayItem]

    public init(
        grossPremium: MonetaryAmount,
        netPremium: MonetaryAmount,
        startDate: String,
        displayName: String,
        insurableLimits: [InsurableLimits],
        perils: [Perils],
        documents: [InsuranceDocument],
        contractType: TypeOfContract?,
        id: String,
        displayItems: [DisplayItem],
        exposureName: String?,
        addons: [AddonDataModel],
        discountDisplayItems: [DisplayItem]
    ) {
        self.grossPremium = grossPremium
        self.netPremium = netPremium
        self.startDate = startDate
        self.displayName = displayName
        self.insurableLimits = insurableLimits
        self.perils = perils
        self.documents = documents
        self.contractType = contractType
        self.id = id
        self.displayItems = displayItems
        self.exposureName = exposureName
        self.addons = addons
        self.discountDisplayItems = discountDisplayItems
    }
}

public struct InsuranceDocument: Codable, Equatable, Hashable, Sendable {
    let displayName: String
    let url: String

    public init(displayName: String, url: String) {
        self.displayName = displayName
        self.url = url
    }
}

public struct DisplayItem: Codable, Equatable, Hashable, Sendable {
    let displaySubtitle: String?
    let displayTitle: String
    let displayValue: String

    public init(displaySubtitle: String?, displayTitle: String, displayValue: String) {
        self.displaySubtitle = displaySubtitle
        self.displayTitle = displayTitle
        self.displayValue = displayValue
    }
}

public struct AddonDataModel: Codable, Equatable, Hashable, Sendable {
    let id: String
    let quoteInfo: InfoViewDataModel
    let displayItems: [DisplayItem]
    let coverageDisplayName: String
    let grossPremium: MonetaryAmount
    let netPremium: MonetaryAmount
    let addonVariant: AddonVariant
    let startDate: Date
    let removeDialogInfo: RemoveDialogInfo?
    let discountDisplayItems: [DisplayItem]

    public init(
        id: String,
        quoteInfo: InfoViewDataModel,
        displayItems: [DisplayItem],
        coverageDisplayName: String,
        grossPremium: MonetaryAmount,
        netPremium: MonetaryAmount,
        addonVariant: AddonVariant,
        startDate: Date,
        discountDisplayItems: [DisplayItem],
        removeDialogInfo: RemoveDialogInfo?,
    ) {
        self.id = id
        self.quoteInfo = quoteInfo
        self.displayItems = displayItems
        self.coverageDisplayName = coverageDisplayName
        self.grossPremium = grossPremium
        self.netPremium = netPremium
        self.addonVariant = addonVariant
        self.startDate = startDate
        self.discountDisplayItems = discountDisplayItems
        self.removeDialogInfo = removeDialogInfo
    }
}

public struct RemoveDialogInfo: Codable, Equatable, Hashable, Sendable {
    let title: String
    let description: String
    let confirmButtonTitle: String
    let cancelButtonTitle: String

    public init(title: String, description: String, confirmButtonTitle: String, cancelButtonTitle: String) {
        self.title = title
        self.description = description
        self.confirmButtonTitle = confirmButtonTitle
        self.cancelButtonTitle = cancelButtonTitle
    }
}
