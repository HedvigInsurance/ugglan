import Addons
import ChangeTier
import Contracts
import Foundation
import hCore
import hCoreUI
import hGraphQL

public struct MoveQuotesModel {
    let homeQuotes: [MovingFlowQuote]
    let mtaQuotes: [MovingFlowQuote]
    let changeTierModel: ChangeTierIntentModel?

    init(homeQuotes: [MovingFlowQuote], mtaQuotes: [MovingFlowQuote], changeTierModel: ChangeTierIntentModel?) {
        self.homeQuotes = homeQuotes
        self.mtaQuotes = mtaQuotes
        self.changeTierModel = changeTierModel
    }
}

struct MovingFlowQuote: Codable, Equatable, Hashable {
    typealias KeyValue = (key: String, value: String)
    let premium: MonetaryAmount
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
}

struct InsuranceDocument: Codable, Equatable, Hashable {
    let displayName: String
    let url: String
}

struct DisplayItem: Codable, Equatable, Hashable {
    let displaySubtitle: String?
    let displayTitle: String
    let displayValue: String
}

struct AddonDataModel: Codable, Equatable, Hashable {
    let id: String
    let quoteInfo: InfoViewDataModel
    let displayItems: [DisplayItem]
    let coverageDisplayName: String
    let price: MonetaryAmount
    let addonVariant: AddonVariant
    let startDate: Date
    let removeDialogInfo: RemoveDialogInfo?
}

struct RemoveDialogInfo: Codable, Equatable, Hashable {
    let title: String
    let description: String
    let confirmButtonTitle: String
    let cancelButtonTitle: String
}
