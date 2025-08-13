import SwiftUI
import hCore

public class QuoteSummaryViewModel: ObservableObject, Identifiable {
    @Published public var contracts: [ContractInfo]
    @Published var total: MonetaryAmount = .init(amount: "", currency: "")
    @Published var expandedContracts: [String] = []
    @Published var removedContracts: [String] = []
    public var onConfirmClick: () -> Void
    let isAddon: Bool
    let showNoticeCard: Bool
    @Published public var removeModel: QuoteSummaryViewModel.ContractInfo.RemoveModel? = nil

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

    func strikeThroughPriceType(_ contractId: String) -> StrikeThroughPriceType {
        if removedContracts.contains(contractId) {
            return .crossNewPrice
        }
        if isAddon {
            return .crossOldPrice
        }
        return .none
    }

    public struct ContractInfo: Identifiable {
        public var id: String
        let displayName: String
        let exposureName: String
        let newPremium: MonetaryAmount?
        let currentPremium: MonetaryAmount?
        let displayItems: [QuoteDisplayItem]
        let documents: [hPDFDocument]
        let onDocumentTap: (_ document: hPDFDocument) -> Void
        let insuranceLimits: [InsurableLimits]
        let typeOfContract: TypeOfContract?
        let shouldShowDetails: Bool
        let removeModel: RemoveModel?
        let isAddon: Bool
        public init(
            id: String,
            displayName: String,
            exposureName: String,
            newPremium: MonetaryAmount?,
            currentPremium: MonetaryAmount?,
            documents: [hPDFDocument],
            onDocumentTap: @escaping (_ document: hPDFDocument) -> Void,
            displayItems: [QuoteDisplayItem],
            insuranceLimits: [InsurableLimits],
            typeOfContract: TypeOfContract?,
            isAddon: Bool = false,
            removeModel: RemoveModel? = nil
        ) {
            self.id = id
            self.displayName = displayName
            self.exposureName = exposureName
            self.newPremium = newPremium
            self.currentPremium = currentPremium
            self.documents = documents
            self.onDocumentTap = onDocumentTap
            self.displayItems = displayItems
            self.insuranceLimits = insuranceLimits
            self.typeOfContract = typeOfContract
            shouldShowDetails = !(documents.isEmpty && displayItems.isEmpty && insuranceLimits.isEmpty)
            self.isAddon = isAddon
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
    }

    public init(
        contract: [ContractInfo],
        total: MonetaryAmount? = nil,
        isAddon: Bool? = false,
        onConfirmClick: (() -> Void)? = nil
    ) {
        contracts = contract
        self.isAddon = isAddon ?? false
        self.onConfirmClick = onConfirmClick ?? {}
        showNoticeCard = (contract.filter { !$0.isAddon }.count > 1 || isAddon ?? false)
        if let total = total {
            self.total = total
        } else {
            calculateTotal()
        }
    }

    func calculateTotal() {
        let totalValue = contracts.filter { !removedContracts.contains($0.id) }
            .reduce(0) { $0 + ($1.newPremium?.value ?? 0) }
        total = .init(amount: totalValue, currency: contracts.first?.newPremium?.currency ?? "")
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
