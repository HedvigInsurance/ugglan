import Combine
import Foundation
import hCore

@MainActor
public protocol ExistingStakeholders {
    func get(contractId: String, stakeholderType: StakeholderType) -> [Stakeholder]
}

@MainActor
public class EditStakeholdersViewModel: ObservableObject {
    @Published public var editStakeholderModelDetent: EditStakeholdersNavigationModel?
    @Published public var editStakeholderModelFullScreen: EditStakeholdersNavigationModel?
    @Published public var editStakeholderModelMissingAlert: StakeholdersConfig?
    @Published public var editStakeholderModelError: EditStakeholdersErrorWrapper?
    private let service = EditStakeholdersService()
    public static var updatedStakeholderForContractId = PassthroughSubject<String?, Never>()
    let existingStakeholders: ExistingStakeholders
    var stakeholderType: StakeholderType!

    @MainActor
    public init(existingStakeholders: ExistingStakeholders) {
        self.existingStakeholders = existingStakeholders
    }

    public func start(
        fromContract: StakeholdersConfig
    ) {
        stakeholderType = fromContract.stakeholderType
        editStakeholderModelFullScreen = .init(contractsSupportingStakeholders: {
            [fromContract]
        })
    }

    public func start(
        stakeholderType: StakeholderType,
        forMissingStakeholders: Bool = false
    ) {
        self.stakeholderType = stakeholderType
        Task { @MainActor in
            do {
                let activeContracts = try await service.fetchContracts()

                let contractsSupportingStakeholders =
                    activeContracts
                    .filter {
                        $0.showEditStakeholdersInfo(for: stakeholderType)
                            && (missingCount(for: stakeholderType, in: $0) > 0 || !forMissingStakeholders)
                    }
                    .compactMap { contract in
                        StakeholdersConfig(
                            contract: contract,
                            preSelectedStakeholders: existingStakeholders.get(
                                contractId: contract.id,
                                stakeholderType: stakeholderType
                            ),
                            fromInfoCard: true,
                            stakeholderType: stakeholderType
                        )
                    }
                if contractsSupportingStakeholders.count > 1 {
                    editStakeholderModelDetent = .init(contractsSupportingStakeholders: {
                        contractsSupportingStakeholders
                    })
                } else if !contractsSupportingStakeholders.isEmpty {
                    editStakeholderModelFullScreen = .init(contractsSupportingStakeholders: {
                        contractsSupportingStakeholders
                    })
                } else {  // if empty
                    throw EditStakeholderError.missingContracts
                }
            } catch {
                editStakeholderModelError = .init(errorMessage: error.localizedDescription)
            }
        }
    }

    private func missingCount(for stakeholderType: StakeholderType, in contract: Contract) -> Int {
        switch stakeholderType {
        case .coInsured: contract.nbOfMissingCoInsuredWithoutTermination
        case .coOwner: contract.nbOfMissingCoOwnersWithoutTermination
        }
    }

    public func checkForAlert(excludingContractId: String? = nil) {
        editStakeholderModelDetent = nil
        editStakeholderModelFullScreen = nil
        editStakeholderModelMissingAlert = nil

        Task { @MainActor in
            let activeContracts = try await service.fetchContracts()
            let missingContract = activeContracts.first { contract in
                if contract.id == excludingContractId {
                    return false
                }
                if contract.upcomingChangedAgreement != nil {
                    return false
                }
                return switch stakeholderType {
                case .none: false
                case .coInsured: contract.nbOfMissingCoInsuredWithoutTermination > 0
                case .coOwner: contract.nbOfMissingCoOwnersWithoutTermination > 0
                }
            }

            if let missingContract {
                try await Task.sleep(seconds: 0.4)
                let missingContractConfig = StakeholdersConfig(
                    contract: missingContract,
                    preSelectedStakeholders: existingStakeholders.get(
                        contractId: missingContract.id,
                        stakeholderType: stakeholderType
                    ),
                    fromInfoCard: false,
                    stakeholderType: stakeholderType,
                )
                editStakeholderModelMissingAlert = missingContractConfig
            }
        }
    }
}

enum EditStakeholderError: Error {
    case missingContracts
}

extension EditStakeholderError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingContracts:
            return L10n.General.defaultError
        }
    }
}

public struct EditStakeholdersNavigationModel: Equatable, Identifiable {
    public var contractsSupportingStakeholders: [StakeholdersConfig]
    public let openSpecificScreen: EditStakeholdersScreenType
    public init(
        openSpecificScreen: EditStakeholdersScreenType = .none,
        contractsSupportingStakeholders: () -> [StakeholdersConfig]
    ) {
        self.openSpecificScreen = openSpecificScreen
        self.contractsSupportingStakeholders = contractsSupportingStakeholders()
    }

    public var id: String = UUID().uuidString
}

public enum EditStakeholdersRedirectType: Hashable {
    case checkForAlert
}

public enum EditStakeholdersScreenType {
    case newInsurance
    case none
}

public struct EditStakeholdersErrorWrapper: Equatable, Identifiable {
    public let id: String = UUID().uuidString
    public let errorMessage: String
}
