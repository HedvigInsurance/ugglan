import Foundation
import hCore

public class EditCoInsuredViewModel: ObservableObject {
    @Published public var editCoInsuredModelDetent: EditCoInsuredNavigationModel?
    @Published public var editCoInsuredModelFullScreen: EditCoInsuredNavigationModel?
    @Published public var editCoInsuredModelMissingAlert: InsuredPeopleConfig?

    public var editCoInsuredSharedService = EditCoInsuredSharedService()

    public init() {}

    public func start(fromContract: InsuredPeopleConfig? = nil) {

        Task {
            let activeContracts = try await editCoInsuredSharedService.fetchContracts()

            if let contract = fromContract {
                editCoInsuredModelFullScreen = .init(contractsSupportingCoInsured: {
                    return [contract]
                })
            } else {
                let contractsSupportingCoInsured =
                    activeContracts
                    .filter({ $0.showEditCoInsuredInfo && $0.nbOfMissingCoInsuredWithoutTermination > 0 })
                    .compactMap({
                        InsuredPeopleConfig(contract: $0, fromInfoCard: true)
                    })

                if contractsSupportingCoInsured.count > 1 {
                    editCoInsuredModelDetent = .init(contractsSupportingCoInsured: {
                        return contractsSupportingCoInsured
                    })
                } else {
                    editCoInsuredModelFullScreen = .init(contractsSupportingCoInsured: {
                        return contractsSupportingCoInsured
                    })
                }
            }
        }
    }
}

public struct EditCoInsuredNavigationModel: Equatable, Identifiable {
    public var contractsSupportingCoInsured: [InsuredPeopleConfig]

    public init(
        contractsSupportingCoInsured: () -> [InsuredPeopleConfig]
    ) {
        self.contractsSupportingCoInsured = contractsSupportingCoInsured()
    }

    public var id: String = UUID().uuidString
}

public enum EditCoInsuredRedirectType: Hashable {
    case checkForAlert
}
