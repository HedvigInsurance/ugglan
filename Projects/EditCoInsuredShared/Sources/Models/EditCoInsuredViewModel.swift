import Combine
import Foundation
import hCore

public class EditCoInsuredViewModel: ObservableObject {
    @Published public var editCoInsuredModelDetent: EditCoInsuredNavigationModel?
    @Published public var editCoInsuredModelFullScreen: EditCoInsuredNavigationModel?
    @Published public var editCoInsuredModelMissingAlert: InsuredPeopleConfig?
    public var editCoInsuredSharedService = EditCoInsuredSharedService()
    public static var updatedCoInsuredForContractId = PassthroughSubject<String?, Never>()

    public init() {}

    public func start(fromContract: InsuredPeopleConfig? = nil, forMissingCoInsured: Bool = false) {

        Task { @MainActor in
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
                        InsuredPeopleConfig(contract: $0, fromInfoCard: true)
                    })

                if contractsSupportingCoInsured.count > 1 {
                    editCoInsuredModelDetent = .init(contractsSupportingCoInsured: {
                        return contractsSupportingCoInsured
                    })
                } else if !contractsSupportingCoInsured.isEmpty {
                    editCoInsuredModelFullScreen = .init(contractsSupportingCoInsured: {
                        return contractsSupportingCoInsured
                    })
                }
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
                let missingContractConfig = InsuredPeopleConfig(contract: missingContract, fromInfoCard: false)
                editCoInsuredModelMissingAlert = missingContractConfig
            }
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
