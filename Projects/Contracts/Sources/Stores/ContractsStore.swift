import Addons
import AppStateContainer
import EditStakeholders
import Foundation
import Observation
import hCore

@MainActor
@PersistableStore
@Observable
public final class ContractStore: AppStore {
    @ObservationIgnored @Inject private var fetchContractsService: FetchContractsClient

    public internal(set) var activeContracts: [Contract] = []
    public private(set) var terminatedContracts: [Contract] = []
    public private(set) var pendingContracts: [Contract] = []

    @Transient public private(set) var fetchContractsError: String?
    @Transient public private(set) var isFetchingContracts: Bool = false

    public init() {}

    public func fetchContracts() async {
        isFetchingContracts = true
        do {
            let data = try await fetchContractsService.getContracts()
            activeContracts = data.activeContracts
            terminatedContracts = data.terminatedContracts
            pendingContracts = data.pendingContracts
            fetchContractsError = nil
        } catch {
            fetchContractsError = error.localizedDescription
        }
        isFetchingContracts = false
    }

    public var hasActiveContracts: Bool {
        !activeContracts.isEmpty
    }

    public var allStakeholders: [Stakeholder] {
        let stakeholders = activeContracts.flatMap { contract in
            (contract.coInsured + contract.coOwners).filter { !$0.hasMissingData }
        }
        return Set(stakeholders).sorted(by: { $0.id > $1.id })
    }

    public func contractForId(_ id: String) -> Contract? {
        let all = activeContracts + terminatedContracts + pendingContracts
        return all.first(where: { $0.id == id })
    }

    public func fetchAllStakeholdersNotInContract(
        contractId: String,
        stakeholderType: StakeholderType
    ) -> [Stakeholder] {
        guard let contract = contractForId(contractId) else { return [] }
        let contractStakeholders =
            switch stakeholderType {
            case .coInsured: Set(contract.coInsured)
            case .coOwner: Set(contract.coOwners)
            }
        return allStakeholders.filter { !contractStakeholders.contains($0) }
    }

    public func getAddonContractInfosFor(contractIds ids: [String]) -> [AddonContractInfo] {
        ids
            .compactMap { contractForId($0) }
            .map(\.asAddonContractInfo)
    }
}

extension ContractStore: ExistingStakeholders {
    public func get(contractId: String, stakeholderType: StakeholderType) -> [Stakeholder] {
        fetchAllStakeholdersNotInContract(contractId: contractId, stakeholderType: stakeholderType)
    }
}
