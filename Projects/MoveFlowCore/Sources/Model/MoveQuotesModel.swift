import ChangeTierCore
import Foundation
import hCore

public struct MoveQuotesModel: Sendable {
    public var homeQuotes: [MovingFlowQuote]
    public var mtaQuotes: [MovingFlowQuote]
    public let changeTierModel: ChangeTierIntentModel?

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
    public var totalPremium: Premium
    public var baseGrossPremium: MonetaryAmount
    public let startDate: Date
    public let displayName: String
    public let insurableLimits: [InsurableLimits]
    public let documents: [InsuranceDocument]
    public let contractType: TypeOfContract?
    public let id: String
    public let displayItems: [DisplayItem]
    public let exposureName: String?
    public let addons: [AddonDataModel]
    public var priceBreakdownItems: [DisplayItem]

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
    public let displayName: String
    public let url: String

    public init(displayName: String, url: String) {
        self.displayName = displayName
        self.url = url
    }
}

public struct DisplayItem: Codable, Equatable, Hashable, Sendable {
    public let displayTitle: String
    public let displayValue: String

    public init(displayTitle: String, displayValue: String) {
        self.displayTitle = displayTitle
        self.displayValue = displayValue
    }
}

public struct AddonDataModel: Codable, Equatable, Hashable, Sendable {
    public let id: String
    public let grossPremium: MonetaryAmount
    public let addonVariant: AddonVariant

    public init(
        id: String,
        grossPremium: MonetaryAmount,
        addonVariant: AddonVariant
    ) {
        self.id = id
        self.grossPremium = grossPremium
        self.addonVariant = addonVariant
    }
}
