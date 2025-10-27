import ChangeTier
import Foundation
import hCore
import hCoreUI

public struct MoveQuotesModel: Sendable {
    var homeQuotes: [MovingFlowQuote]
    var mtaQuotes: [MovingFlowQuote]
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
    var totalPremium: Premium
    var baseGrossPremium: MonetaryAmount
    let startDate: Date
    let displayName: String
    let insurableLimits: [InsurableLimits]
    let documents: [InsuranceDocument]
    let contractType: TypeOfContract?
    let id: String
    let displayItems: [DisplayItem]
    let exposureName: String?
    let addons: [AddonDataModel]
    var priceBreakdownItems: [DisplayItem]

    public init(
        totalPremium: Premium,
        baseGrossPremium: MonetaryAmount,
        startDate: Date,
        displayName: String,
        insurableLimits: [InsurableLimits],
        documents: [InsuranceDocument],
        contractType: TypeOfContract?,
        id: String,
        displayItems: [DisplayItem],
        exposureName: String?,
        addons: [AddonDataModel],
        priceBreakdownItems: [DisplayItem]
    ) {
        self.totalPremium = totalPremium
        self.baseGrossPremium = baseGrossPremium
        self.startDate = startDate
        self.displayName = displayName
        self.insurableLimits = insurableLimits
        self.documents = documents
        self.contractType = contractType
        self.id = id
        self.displayItems = displayItems
        self.exposureName = exposureName
        self.addons = addons
        self.priceBreakdownItems = priceBreakdownItems
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
    let displayTitle: String
    let displayValue: String

    public init(displayTitle: String, displayValue: String) {
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
    let addonVariant: AddonVariant

    public init(
        id: String,
        quoteInfo: InfoViewDataModel,
        displayItems: [DisplayItem],
        coverageDisplayName: String,
        grossPremium: MonetaryAmount,
        addonVariant: AddonVariant
    ) {
        self.id = id
        self.quoteInfo = quoteInfo
        self.displayItems = displayItems
        self.coverageDisplayName = coverageDisplayName
        self.grossPremium = grossPremium
        self.addonVariant = addonVariant
    }
}
