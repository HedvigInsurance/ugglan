import SwiftUI
import hCore

@MainActor
public class QuoteSummaryViewModel: ObservableObject, Identifiable {
    @Published public var contracts: [ContractInfo]
    @Published public var activationDate: Date?
    @Published var premium: Premium
    @Published var isConfirmChangesPresented: Bool = false
    @Published var isShowDetailsPresented: QuoteSummaryViewModel.ContractInfo? = nil

    public var onConfirmClick: () -> Void
    let isAddon: Bool
    let showNoticeCard: Bool

    public struct ContractInfo: Identifiable, Equatable {
        public var id: String
        let displayName: String
        let exposureName: String
        public let premium: Premium?
        let displayItems: [QuoteDisplayItem]
        let documentSection: DocumentSection
        let insuranceLimits: [InsurableLimits]
        let typeOfContract: TypeOfContract?
        let shouldShowDetails: Bool
        let isAddon: Bool
        let priceBreakdownItems: [QuoteDisplayItem]

        public init(
            id: String,
            displayName: String,
            exposureName: String,
            premium: Premium?,
            documentSection: DocumentSection,
            displayItems: [QuoteDisplayItem],
            insuranceLimits: [InsurableLimits],
            typeOfContract: TypeOfContract?,
            isAddon: Bool? = false,
            priceBreakdownItems: [QuoteDisplayItem]
        ) {
            self.id = id
            self.displayName = displayName
            self.exposureName = exposureName
            self.premium = premium
            self.documentSection = documentSection
            self.displayItems = displayItems
            self.insuranceLimits = insuranceLimits
            self.typeOfContract = typeOfContract
            self.shouldShowDetails =
                !(documentSection.documents.isEmpty && displayItems.isEmpty
                && insuranceLimits.isEmpty)
            self.isAddon = isAddon ?? false
            self.priceBreakdownItems = priceBreakdownItems
        }

        public static func == (lhs: QuoteSummaryViewModel.ContractInfo, rhs: QuoteSummaryViewModel.ContractInfo) -> Bool
        {
            lhs.id == rhs.id
        }

        public struct DocumentSection {
            public let documents: [hPDFDocument]
            public let onTap: (_ document: hPDFDocument) -> Void

            public init(documents: [hPDFDocument], onTap: @escaping (_: hPDFDocument) -> Void) {
                self.documents = documents
                self.onTap = onTap
            }
        }
    }

    public init(
        contract: [ContractInfo],
        activationDate: Date?,
        premium: Premium,
        isAddon: Bool? = false,
        onConfirmClick: (() -> Void)? = nil
    ) {
        self.contracts = contract
        self.isAddon = isAddon ?? false
        self.activationDate = activationDate
        self.onConfirmClick = onConfirmClick ?? {}
        self.premium = premium
        self.showNoticeCard = (contract.filter({ !$0.isAddon }).count > 1 || isAddon ?? false)
    }
}

public struct QuoteDisplayItem: Identifiable, Equatable, Sendable {
    public let id: String
    let displayTitle: String
    let displayValue: String
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
