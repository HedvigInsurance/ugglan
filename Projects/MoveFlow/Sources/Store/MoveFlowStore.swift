import Apollo
import Foundation
import Presentation
import hCore
import hCoreUI

public final class MoveFlowStore: LoadingStateStore<MoveFlowState, MoveFlowAction, MoveFlowLoadingAction> {
    @Inject var moveFlowService: MoveFlowService

    var addressInputModel = AddressInputModel()
    var houseInformationInputModel = HouseInformationInputModel()
    public override func effects(
        _ getState: @escaping () -> MoveFlowState,
        _ action: MoveFlowAction
    ) async {
        switch action {
        case .getMoveIntent:
            self.setLoading(for: .fetchMoveIntent)
            do {
                let movingFlowData = try await self.moveFlowService.sendMoveIntent()
                self.removeLoading(for: .fetchMoveIntent)
                send(.setMoveIntent(with: movingFlowData))
                self.addressInputModel.nbOfCoInsured = movingFlowData.suggestedNumberCoInsured
            } catch {
                if let error = error as? MovingFlowError {
                    self.setError(error.localizedDescription, for: .fetchMoveIntent)
                } else {
                    self.setError(L10n.General.errorBody, for: .fetchMoveIntent)
                }
            }
        case .requestMoveIntent:
            self.setLoading(for: .requestMoveIntent)
            do {
                let movingFlowData = try await self.moveFlowService.requestMoveIntent(
                    intentId: self.state.movingFlowModel?.id ?? "",
                    addressInputModel: self.addressInputModel,
                    houseInformationInputModel: self.houseInformationInputModel
                )
                self.send(.setMoveIntent(with: movingFlowData))
                self.send(.navigation(action: .openConfirmScreen))
                self.removeLoading(for: .requestMoveIntent)
            } catch {
                self.setError(error.localizedDescription, for: .requestMoveIntent)
            }
        case .confirmMoveIntent:
            self.setLoading(for: .confirmMoveIntent)
            do {
                let intentId = self.state.movingFlowModel?.id ?? ""
                try await self.moveFlowService.confirmMoveIntent(intentId: intentId)
                self.removeLoading(for: .confirmMoveIntent)
                AskForRating().askForReview()
            } catch {
                self.setError(error.localizedDescription, for: .confirmMoveIntent)
            }
        default:
            break
        }
    }

    public override func reduce(_ state: MoveFlowState, _ action: MoveFlowAction) -> MoveFlowState {
        var newState = state
        switch action {
        case .getMoveIntent:
            self.addressInputModel = AddressInputModel()
            self.houseInformationInputModel = HouseInformationInputModel()
        case let .setMoveIntent(model):
            newState.movingFromAddressModel = MovingFromAddressModel(id: model.currentHomeAddresses.first?.id ?? "")
            newState.movingFlowModel = model
        case let .setMovingFromAddress(model):
            newState.movingFromAddressModel = model
        case let .setHousingType(housingType):
            newState.selectedHousingType = housingType
        default:
            break
        }
        return newState
    }
}

public enum MoveFlowAction: ActionProtocol {
    case getMoveIntent
    case setMoveIntent(with: MovingFlowModel)
    case setHousingType(with: HousingType)
    case setExtraBuildingType(with: ExtraBuildingType)
    case requestMoveIntent

    case setMovingFromAddress(with: MovingFromAddressModel)

    case confirmMoveIntent
    case navigation(action: MoveFlowNavigationAction)
}

public enum MoveFlowNavigationAction: ActionProtocol, Hashable {
    case openHouseFillScreen
    case openConfirmScreen
    case openProcessingView
}

public enum MoveFlowLoadingAction: LoadingProtocol {
    case fetchMoveIntent
    case requestMoveIntent
    case confirmMoveIntent
}

public struct MoveFlowState: StateProtocol {

    public init() {}
    @Transient(defaultValue: .apartment) var selectedHousingType: HousingType
    @OptionalTransient var movingFlowModel: MovingFlowModel?
    @OptionalTransient var movingFromAddressModel: MovingFromAddressModel?
}
