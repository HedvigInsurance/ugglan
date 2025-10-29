import Combine
import Foundation
import hCore

@MainActor
public protocol ExistingCoInsured {
    func get(contractId: String) -> [CoInsuredModel]
}

@MainActor
public class EditCoInsuredViewModel: ObservableObject {
    @Published public var editCoInsuredModelDetent: EditCoInsuredNavigationModel?
    @Published public var editCoInsuredModelFullScreen: EditCoInsuredNavigationModel?
    @Published public var editCoInsuredModelMissingAlert: InsuredPeopleConfig?
    @Published public var editCoInsuredModelError: EditCoInsuredErrorWrapper?
    private let service = EditCoInsuredService()
    public static var updatedCoInsuredForContractId = PassthroughSubject<String?, Never>()
    let existingCoInsured: ExistingCoInsured

    @MainActor
    public init(
        existingCoInsured: ExistingCoInsured
    ) {
        self.existingCoInsured = existingCoInsured
    }

    public func start(fromContract: InsuredPeopleConfig? = nil, forMissingCoInsured: Bool = false) {
        Task { @MainActor in
            do {
                let activeContracts = try await service.fetchContracts()

                if let contract = fromContract {
                    editCoInsuredModelFullScreen = .init(contractsSupportingCoInsured: {
                        [contract]
                    })
                } else {
                    let contractsSupportingCoInsured =
                        activeContracts
                        .filter {
                            $0.showEditCoInsuredInfo
                                && ($0.nbOfMissingCoInsuredWithoutTermination > 0 || !forMissingCoInsured)
                        }
                        .compactMap {
                            InsuredPeopleConfig(
                                contract: $0,
                                preSelectedCoInsuredList: existingCoInsured.get(contractId: $0.id),
                                fromInfoCard: true
                            )
                        }
                    if contractsSupportingCoInsured.count > 1 {
                        editCoInsuredModelDetent = .init(contractsSupportingCoInsured: {
                            contractsSupportingCoInsured
                        })
                    } else if !contractsSupportingCoInsured.isEmpty {
                        editCoInsuredModelFullScreen = .init(contractsSupportingCoInsured: {
                            contractsSupportingCoInsured
                        })
                    } else {  // if empty
                        throw EditCoInsuedError.missingContracts
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
                } else {
                    return contract.coInsured
                        .first(where: { coInsured in
                            coInsured.hasMissingInfo && contract.terminationDate == nil
                        }) != nil
                }
            }

            if let missingContract {
                try await Task.sleep(nanoseconds: 400_000_000)
                let missingContractConfig = InsuredPeopleConfig(
                    contract: missingContract,
                    preSelectedCoInsuredList: existingCoInsured.get(contractId: missingContract.id),
                    fromInfoCard: false
                )
                editCoInsuredModelMissingAlert = missingContractConfig
            }
        }
    }
}

enum EditCoInsuedError: Error {
    case missingContracts
}

extension EditCoInsuedError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingContracts:
            return L10n.General.defaultError
        }
    }
}

public struct EditCoInsuredNavigationModel: Equatable, Identifiable {
    public var contractsSupportingCoInsured: [InsuredPeopleConfig]
    public let openSpecificScreen: EditCoInsuredScreenType
    public init(
        openSpecificScreen: EditCoInsuredScreenType = .none,
        contractsSupportingCoInsured: () -> [InsuredPeopleConfig]
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
