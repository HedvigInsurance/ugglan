import SwiftUI
import hCore

@MainActor
public class QuoteSummaryViewModel: ObservableObject, Identifiable {
    @Published public var contracts: [ContractInfo]
    @Published public var activationDate: Date?
    @Published var netTotal: MonetaryAmount = .init(amount: "", currency: "")
    @Published var grossTotal: MonetaryAmount = .init(amount: "", currency: "")
    @Published var expandedContracts: [String] = []
    @Published var removedContracts: [String] = []
    @Published public var removeModel: QuoteSummaryViewModel.ContractInfo.RemoveModel? = nil
    @Published var isConfirmChangesPresented: Bool = false

    public var onConfirmClick: () -> Void
    let isAddon: Bool
    let showNoticeCard: Bool

    let summaryDataProvider: QuoteSummaryDataProvider

    func toggleContract(_ contract: ContractInfo) {
        if expandedContracts.contains(contract.id) {
            collapseContract(contract)
        } else {
            expandContract(contract)
        }
    }

    public func getRemovedContractsIds() -> [String] {
        removedContracts
    }

    private func expandContract(_ contract: ContractInfo) {
        expandedContracts.append(contract.id)
    }

    private func collapseContract(_ contract: ContractInfo) {
        expandedContracts.removeAll(where: { $0 == contract.id })
    }

    func removeContract(_ contractId: String) {
        expandedContracts.removeAll(where: { $0 == contractId })
        removedContracts.append(contractId)
        calculateTotal()
    }

    func addContract(_ contract: ContractInfo) {
        removedContracts.removeAll(where: { $0 == contract.id })
        calculateTotal()
    }

    public struct ContractInfo: Identifiable {
        public var id: String
        let displayName: String
        let exposureName: String
        public let premium: Premium?
        let displayItemSection: DisplayItemsSection
        let documentSection: DocumentSection
        let insuranceLimits: [InsurableLimits]
        let typeOfContract: TypeOfContract?
        let shouldShowDetails: Bool
        let removeModel: RemoveModel?
        let isAddon: Bool

        public init(
            id: String,
            displayName: String,
            exposureName: String,
            premium: Premium?,
            documentSection: DocumentSection,
            displayItemSection: DisplayItemsSection,
            insuranceLimits: [InsurableLimits],
            typeOfContract: TypeOfContract?,
            isAddon: Bool? = false,
            removeModel: RemoveModel? = nil,
        ) {
            self.id = id
            self.displayName = displayName
            self.exposureName = exposureName
            self.premium = premium
            self.documentSection = documentSection
            self.displayItemSection = displayItemSection
            self.insuranceLimits = insuranceLimits
            self.typeOfContract = typeOfContract
            self.shouldShowDetails =
                !(documentSection.documents.isEmpty && displayItemSection.displayItems.isEmpty
                && insuranceLimits.isEmpty)
            self.isAddon = isAddon ?? false
            self.removeModel = removeModel
        }

        public struct RemoveModel: Identifiable, Equatable {
            public var id: String
            let title: String
            let description: String
            let confirmButtonTitle: String
            let cancelRemovalButtonTitle: String

            public init(
                id: String,
                title: String,
                description: String,
                confirmButtonTitle: String,
                cancelRemovalButtonTitle: String
            ) {
                self.id = id
                self.title = title
                self.description = description
                self.confirmButtonTitle = confirmButtonTitle
                self.cancelRemovalButtonTitle = cancelRemovalButtonTitle
            }
        }

        public struct DocumentSection {
            public let documents: [hPDFDocument]
            public let onTap: (_ document: hPDFDocument) -> Void

            public init(documents: [hPDFDocument], onTap: @escaping (_: hPDFDocument) -> Void) {
                self.documents = documents
                self.onTap = onTap
            }
        }

        public struct DisplayItemsSection {
            public let displayItems: [QuoteDisplayItem]
            public let discountDisplayItems: [QuoteDisplayItem]

            public init(displayItems: [QuoteDisplayItem], discountDisplayItems: [QuoteDisplayItem]) {
                self.displayItems = displayItems
                self.discountDisplayItems = discountDisplayItems
            }
        }
    }

    public init(
        contract: [ContractInfo],
        activationDate: Date?,
        isAddon: Bool? = false,
        summaryDataProvider: QuoteSummaryDataProvider,
        onConfirmClick: (() -> Void)? = nil
    ) {
        self.contracts = contract
        self.isAddon = isAddon ?? false
        self.activationDate = activationDate
        self.onConfirmClick = onConfirmClick ?? {}
        self.showNoticeCard = (contract.filter({ !$0.isAddon }).count > 1 || isAddon ?? false)
        self.summaryDataProvider = summaryDataProvider
        calculateTotal()
    }
    private var calculateTotalTask: Task<(), any Error>?
    private func calculateTotal() {
        calculateTotalTask?.cancel()
        calculateTotalTask = Task { [weak self] in
            guard let self = self else { return }
            let includedAddonIds = self.contracts
                .filter(\.isAddon)
                .filter { !removedContracts.contains($0.id) }
                .map(\.id)
            do {
                let data = try await summaryDataProvider.getTotal(includedAddonIds: includedAddonIds)
                withAnimation {
                    grossTotal = data.totalGross
                    netTotal = data.totalNet
                }
            } catch _ {
                // we don't care about the error here, we just want to recalculate the totals
                self.calculateTotal()
            }
        }
    }

    deinit {
        calculateTotalTask?.cancel()
    }
}

public struct QuoteDisplayItem: Identifiable, Equatable, Sendable {
    public let id: String?
    let displayTitle: String
    let displayValue: String
    let displayValueOld: String?

    public init(
        title displayTitle: String,
        value displayValue: String,
        displayValueOld: String? = nil,
        id: String? = nil
    ) {
        self.displayTitle = displayTitle
        self.displayValue = displayValue
        self.displayValueOld = displayValueOld
        self.id = id
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
