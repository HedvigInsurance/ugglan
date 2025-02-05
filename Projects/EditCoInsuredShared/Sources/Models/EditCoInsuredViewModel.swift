import Combine
import Foundation
import hCore
import hGraphQL

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
    public let editCoInsuredSharedService = EditCoInsuredSharedService()
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
                let activeContracts = try await editCoInsuredSharedService.fetchContracts()

                if let contract = fromContract {
                    editCoInsuredModelFullScreen = .init(contractsSupportingCoInsured: {
                        return [contract]
                    })
                } else {
                    let contractsSupportingCoInsured =
                        activeContracts
                        .filter({
                            $0.showEditCoInsuredInfo
                                && ($0.nbOfMissingCoInsuredWithoutTermination > 0 || !forMissingCoInsured)
                        })
                        .compactMap({
                            InsuredPeopleConfig(
                                contract: $0,
                                preSelectedCoInsuredList: existingCoInsured.get(contractId: $0.id),
                                fromInfoCard: true
                            )
                        })
                    let contractsSupportingCoInsured2 = contractsSupportingCoInsured.filter({ $0.contractId == "1" })
                    if contractsSupportingCoInsured2.count > 1 {
                        editCoInsuredModelDetent = .init(contractsSupportingCoInsured: {
                            return contractsSupportingCoInsured
                        })
                    } else if !contractsSupportingCoInsured2.isEmpty {
                        editCoInsuredModelFullScreen = .init(contractsSupportingCoInsured: {
                            return contractsSupportingCoInsured
                        })
                    } else {  //if empty
                        throw EditCoInsuedError.missingContracts
                    }
                }
            } catch {
                editCoInsuredModelError = .init(errorMessage: error.localizedDescription)
            }
        }
    }

    public func checkForAlert() {
        editCoInsuredModelDetent = nil
        editCoInsuredModelFullScreen = nil
        editCoInsuredModelMissingAlert = nil

        Task { @MainActor in
            let activeContracts = try await editCoInsuredSharedService.fetchContracts()
            let missingContract = activeContracts.first { contract in
                if contract.upcomingChangedAgreement != nil {
                    return false
                } else {
                    return contract.coInsured
                        .first(where: { coInsured in
                            coInsured.hasMissingInfo && contract.terminationDate == nil
                        }) != nil
                }
            }
            try await Task.sleep(nanoseconds: 400_000_000)

            if let missingContract {
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
    public var errorDescription: String? {
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
