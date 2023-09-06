import Apollo
import Flow
import Foundation
import Presentation
import hCore
import hGraphQL

public final class MoveFlowStore: LoadingStateStore<MoveFlowState, MoveFlowAction, MoveFlowLoadingAction> {
    @Inject var giraffe: hGiraffe
    @Inject var octopus: hOctopus

    public override func effects(
        _ getState: @escaping () -> MoveFlowState,
        _ action: MoveFlowAction
    ) -> FiniteSignal<MoveFlowAction>? {
        return nil
    }

    public override func reduce(_ state: MoveFlowState, _ action: MoveFlowAction) -> MoveFlowState {
        var newState = state
        switch action {
        case .setMoveIntent:
            removeLoading(for: .fetchMoveIntent)
            newState.movingFlowModel = MovingFlowModel(
                id: "1",
                minMovingDate: "2023-05-13",
                maxMovingDate: "2024-05-13",
                numberCoInsured: 2,
                currentHomeAddresses: MoveAddress(
                    id: "111",
                    street: "Tullingebergsvägen",
                    postalCode: "14645",
                    city: "Tullinge",
                    bbrId: "11",
                    apartmentNumber: "13",
                    floor: "1"
                ),
                quotes: Quotes(
                    address: MoveAddress(
                        id: "2",
                        street: "Nyvägen 3",
                        postalCode: "11111",
                        city: "Stockholm",
                        bbrId: "3",
                        apartmentNumber: "3",
                        floor: "3"
                    ),
                    premium: MonetaryAmount(
                        amount: 223,
                        currency: "SEK"
                    ),
                    numberCoInsured: 2,
                    startDate: "2024-05-22",
                    termsVersion: TermsVersion(id: "")
                )
            )
        default:
            break
        }

        return newState
    }
}

public enum MoveFlowAction: ActionProtocol, Hashable {
    case getMoveIntent
    case setMoveIntent
    case navigation(action: MoveFlowNavigationAction)
}

public enum MoveFlowNavigationAction: ActionProtocol, Hashable {
    case openHousingTypeScreen
    case openAddressFillScreen
    case goToFreeTextChat
    case dismissMovingFlow
    case openDatePickerScreen
    case openConfirmScreen
    case openFailureScreen
}

public enum MoveFlowLoadingAction: LoadingProtocol {
    case fetchMoveIntent
}

public struct MoveFlowState: StateProtocol {

    public init() {}

    @Transient(defaultValue: false) public var hasLoadedContractBundlesOnce: Bool
    public var contractBundles: [ActiveContractBundle] = []
    public var contracts: [Contract] = []
    public var focusedCrossSell: CrossSell?
    public var signedCrossSells: [CrossSell] = []
    public var crossSells: [CrossSell] = []
    var currentTerminationContext: String?
    var terminationContractId: String? = ""

    var movingFlowModel: MovingFlowModel?

    func contractForId(_ id: String) -> Contract? {
        if let inBundleContract = contractBundles.flatMap({ $0.contracts })
            .first(where: { contract in
                contract.id == id
            })
        {
            return inBundleContract
        }

        return
            contracts
            .first { contract in
                contract.id == id
            }
    }
}
