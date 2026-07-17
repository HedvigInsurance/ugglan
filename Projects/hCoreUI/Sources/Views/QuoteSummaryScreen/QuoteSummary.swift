import SwiftUI
import hCore

public struct QuoteSummary: Equatable {
    public let contracts: [ContractInfo]
    public let activationDate: Date?
    let noticeInfo: String?
    let totalPrice: TotalPrice

    public init(
        contracts: [ContractInfo],
        activationDate: Date?,
        noticeInfo: String? = nil,
        totalPrice: TotalPrice
    ) {
        self.contracts = contracts
        self.activationDate = activationDate
        self.noticeInfo = noticeInfo
        self.totalPrice = totalPrice
    }

    public struct ContractInfo: Identifiable, Equatable {
        public let id: String
        let title: String
        let subtitle: String
        public let premium: Premium?
        let displayItems: [QuoteDisplayItem]
        let documents: [hPDFDocument]
        let insuranceLimits: [InsurableLimits]
        let typeOfContract: TypeOfContract?
        let shouldShowDetails: Bool
        let priceBreakdownItems: [QuoteDisplayItem]

        public init(
            id: String,
            title: String,
            subtitle: String,
            premium: Premium?,
            documents: [hPDFDocument],
            displayItems: [QuoteDisplayItem],
            insuranceLimits: [InsurableLimits],
            typeOfContract: TypeOfContract?,
            priceBreakdownItems: [QuoteDisplayItem]
        ) {
            self.id = id
            self.title = title
            self.subtitle = subtitle
            self.premium = premium
            self.documents = documents
            self.displayItems = displayItems
            self.insuranceLimits = insuranceLimits
            self.typeOfContract = typeOfContract
            self.shouldShowDetails = !(documents.isEmpty && displayItems.isEmpty && insuranceLimits.isEmpty)
            self.priceBreakdownItems = priceBreakdownItems
        }
    }

    public enum TotalPrice: Equatable {
        case comparison(old: MonetaryAmount, new: MonetaryAmount)
        case change(amount: MonetaryAmount)
        case none
    }
}

public struct QuoteDisplayItem: Identifiable, Equatable, Sendable {
    public let id: String
    public let displayTitle: String
    public let displayValue: String
    let crossDisplayTitle: Bool

    public init(
        title displayTitle: String,
        value displayValue: String,
        crossDisplayTitle: Bool = false,
        id: String? = nil,
    ) {
        self.displayTitle = displayTitle
        self.displayValue = displayValue
        self.crossDisplayTitle = crossDisplayTitle
        self.id = id ?? UUID().uuidString
    }
}

public struct FAQ: Codable, Equatable, Hashable, Sendable {
    public var title: String
    public var description: String?

    public init(
        title: String,
        description: String?
    ) {
        self.title = title
        self.description = description
    }
}
