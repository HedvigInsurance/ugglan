import Combine
import Foundation
import hCore

@MainActor
public protocol ExistingStakeHolders {
    func get(contractId: String) -> [StakeHolder]
}

@MainActor
public class EditCoInsuredViewModel: ObservableObject {
    @Published public var editCoInsuredModelDetent: EditCoInsuredNavigationModel?
    @Published public var editCoInsuredModelFullScreen: EditCoInsuredNavigationModel?
    @Published public var editCoInsuredModelMissingAlert: StakeHoldersConfig?
    @Published public var editCoInsuredModelError: EditCoInsuredErrorWrapper?
    private let service = EditCoInsuredService()
    public static var updatedCoInsuredForContractId = PassthroughSubject<String?, Never>()
    let existingStakeHolders: ExistingStakeHolders

    @MainActor
    public init(
        existingStakeHolders: ExistingStakeHolders
    ) {
        self.existingStakeHolders = existingStakeHolders
    }

    public func start(
        fromContract: StakeHoldersConfig? = nil,
        forMissingStakeHolders: Bool = false
    ) {
        Task { @MainActor in
            do {
                let activeContracts = try await service.fetchContracts()

                if let contract = fromContract {
                    editCoInsuredModelFullScreen = .init(contractsSupportingCoInsured: {
                        [contract]
                    })
                } else {
                    let contractsSupportingStakeHolders =
                        activeContracts
                        .filter {
                            $0.showEditStakeHoldersInfo
                                && ($0.nbOfMissingCoInsuredWithoutTermination > 0
                                    || $0.nbOfMissingCoOwnersWithoutTermination > 0
                                    || !forMissingStakeHolders)
                        }
                        .compactMap { contract -> StakeHoldersConfig? in
                            guard let stakeHolderType = contract.stakeHolderType else { return nil }
                            return StakeHoldersConfig(
                                contract: contract,
                                preSelectedStakeHolders: existingStakeHolders.get(contractId: contract.id),
                                fromInfoCard: true,
                                stakeHolderType: stakeHolderType
                            )
                        }
                    if contractsSupportingStakeHolders.count > 1 {
                        editCoInsuredModelDetent = .init(contractsSupportingCoInsured: {
                            contractsSupportingStakeHolders
                        })
                    } else if !contractsSupportingStakeHolders.isEmpty {
                        editCoInsuredModelFullScreen = .init(contractsSupportingCoInsured: {
                            contractsSupportingStakeHolders
                        })
                    } else {  // if empty
                        throw EditStakeHolderError.missingContracts
                    }
                }
            } catch {
                editCoInsuredModelError = .init(errorMessage: error.localizedDescription)
            }
        }
    }

    public func checkForAlert(excludingContractId: String? = nil) {
        editCoInsuredModelDetent = nil
        editCoInsuredModelFullScreen = nil
        editCoInsuredModelMissingAlert = nil

        Task { @MainActor in
            let activeContracts = try await service.fetchContracts()
            let missingContract = activeContracts.first { contract in
                if contract.id == excludingContractId {
                    return false
                }
                if contract.upcomingChangedAgreement != nil {
                    return false
                }
                return switch contract.stakeHolderType {
                case .coInsured: contract.nbOfMissingCoInsuredWithoutTermination > 0
                case .coOwner: contract.nbOfMissingCoOwnersWithoutTermination > 0
                case .none: false
                }
            }

            if let missingContract {
                guard let stakeHolderType = missingContract.stakeHolderType else { return }
                try await Task.sleep(seconds: 0.4)
                let missingContractConfig = StakeHoldersConfig(
                    contract: missingContract,
                    preSelectedStakeHolders: existingStakeHolders.get(contractId: missingContract.id),
                    fromInfoCard: false,
                    stakeHolderType: stakeHolderType,
                )
                editCoInsuredModelMissingAlert = missingContractConfig
            }
        }
    }
}

enum EditStakeHolderError: Error {
    case missingContracts
}

extension Contract {
    var stakeHolderType: StakeHolderType? {
        switch true {
        case supportsCoInsured: .coInsured
        case supportsCoOwners: .coOwner
        default: nil
        }
    }
}

extension EditStakeHolderError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingContracts:
            return L10n.General.defaultError
        }
    }
}

public struct EditCoInsuredNavigationModel: Equatable, Identifiable {
    public var contractsSupportingCoInsured: [StakeHoldersConfig]
    public let openSpecificScreen: EditCoInsuredScreenType
    public init(
        openSpecificScreen: EditCoInsuredScreenType = .none,
        contractsSupportingCoInsured: () -> [StakeHoldersConfig]
    ) {
        self.openSpecificScreen = openSpecificScreen
        self.contractsSupportingCoInsured = contractsSupportingCoInsured()
    }

    public var id: String = UUID().uuidString
}

public enum EditCoInsuredRedirectType: Hashable {
    case checkForAlert
}

public enum EditCoInsuredScreenType {
    case newInsurance
    case none
}

public struct EditCoInsuredErrorWrapper: Equatable, Identifiable {
    public let id: String = UUID().uuidString
    public let errorMessage: String
}
