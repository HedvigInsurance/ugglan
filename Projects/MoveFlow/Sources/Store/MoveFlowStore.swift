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
        switch action {
        case .getMoveIntent:
            self.setLoading(for: .fetchMoveIntent)
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                let mutation = OctopusGraphQL.MoveIntentCreateMutation()
                disposeBag += self.octopus.client.perform(mutation: mutation)
                    .map { data in
                        if let moveIntent = data.moveIntentCreate.moveIntent?.fragments.moveIntentFragment {
                            self.removeLoading(for: .fetchMoveIntent)
                            callback(.value(.setMoveIntent(with: .init(from: moveIntent))))
                            callback(.end)
                        } else if let userError = data.moveIntentCreate.userError?.message {
                            self.setError(userError, for: .fetchMoveIntent)
                            callback(.end(MovingFlowError.serverError(message: userError)))
                        }
                    }
                    .onError({ error in
                        if let error = error as? MovingFlowError {
                            self.setError(error.localizedDescription, for: .fetchMoveIntent)
                        } else {
                            self.setError(L10n.General.errorBody, for: .fetchMoveIntent)
                        }

                    })
                return disposeBag
            }
        case .requestMoveIntent:
            self.setLoading(for: .requestMoveIntent)
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                let mutation = self.state.moveIntentRequestMutation()
                disposeBag += self.octopus.client.perform(mutation: mutation)
                    .onValue({ [weak self] value in
                        if let fragment = value.moveIntentRequest.moveIntent?.fragments.moveIntentFragment {
                            let model = MovingFlowModel(from: fragment)
                            self?.send(.setMoveIntent(with: model))
                            self?.send(.navigation(action: .openConfirmScreen))
                            self?.removeLoading(for: .requestMoveIntent)
                        } else if let error = value.moveIntentRequest.userError?.message {
                            self?.setError(error, for: .requestMoveIntent)
                        }
                    })
                    .onError({ [weak self] error in
                        self?.setError(L10n.generalError, for: .requestMoveIntent)
                    })
                return disposeBag
            }
        case .confirmMoveIntent:
            self.setLoading(for: .confirmMoveIntent)
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                let intentId = self.state.movingFlowModel?.id ?? ""
                let mutation = OctopusGraphQL.MoveIntentCommitMutation(intentId: intentId)
                let graphQlMutation = self.octopus.client.perform(mutation: mutation)
                let minimumTime = Signal(after: 1.5).future
                disposeBag += combineLatest(graphQlMutation.resultSignal, minimumTime.resultSignal)
                    .onValue { [weak self] mutation, minimumTime in
                        if let data = mutation.value {
                            if let userError = data.moveIntentCommit.userError?.message {
                                self?.setError(userError, for: .confirmMoveIntent)
                                callback(.end(MovingFlowError.serverError(message: userError)))
                            } else {
                                self?.removeLoading(for: .confirmMoveIntent)
                                callback(.end)
                            }
                        } else if let _ = mutation.error {
                            self?.setError(L10n.General.errorBody, for: .confirmMoveIntent)
                        }
                    }
                return disposeBag
            }
        default:
            return nil
        }
    }

    public override func reduce(_ state: MoveFlowState, _ action: MoveFlowAction) -> MoveFlowState {
        var newState = state
        switch action {
        case .getMoveIntent:
            newState.newAddressModel = NewAddressModel()
            newState.houseInformationModel = HouseInformationModel()
        case let .setMoveIntent(model):
            newState.movingFromAddressModel = MovingFromAddressModel(id: model.currentHomeAddresses.first?.id ?? "")
            newState.movingFlowModel = model
        case let .setMovingFromAddress(model):
            newState.movingFromAddressModel = model
        case let .setNewAddress(model):
            newState.newAddressModel = model
            switch newState.selectedHousingType {
            case .apartmant, .rental:
                send(.requestMoveIntent)
            case .house:
                send(.navigation(action: .openHouseFillScreen))
            }
        case let .setHousingType(housingType):
            newState.selectedHousingType = housingType
        case let .setHouseInformation(model):
            newState.houseInformationModel = model
            send(.requestMoveIntent)
        case let .addExtraBuilding(model):
            newState.houseInformationModel.extraBuildings.append(model)
        case let .removeExtraBuilding(model):
            newState.houseInformationModel.removeExtraBuilding(model)
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
    case addExtraBuilding(with: HouseInformationModel.ExtraBuilding)
    case removeExtraBuilding(with: HouseInformationModel.ExtraBuilding)
    case setExtraBuildingType(with: ExtraBuildingType)
    case requestMoveIntent

    case setMovingFromAddress(with: MovingFromAddressModel)
    case setNewAddress(with: NewAddressModel)
    case setHouseInformation(with: HouseInformationModel)

    case confirmMoveIntent
    case navigation(action: MoveFlowNavigationAction)
}

public enum MoveFlowNavigationAction: ActionProtocol, Hashable {
    case openAddressFillScreen
    case openHouseFillScreen
    case openAddBuilding
    case openConfirmScreen
    case openProcessingView
    case openFailureScreen(error: String)
    case openTypeOfBuilding(for: ExtraBuildingType?)
    case dismissTypeOfBuilding
    case goToFreeTextChat
    case dismissMovingFlow
    case goBack
}

public enum MoveFlowLoadingAction: LoadingProtocol {
    case fetchMoveIntent
    case requestMoveIntent
    case confirmMoveIntent
}

public struct MoveFlowState: StateProtocol {

    public init() {}
    @Transient(defaultValue: .apartmant) var selectedHousingType: HousingType
    @OptionalTransient var movingFlowModel: MovingFlowModel?
    @OptionalTransient var movingFromAddressModel: MovingFromAddressModel?
    @Transient(defaultValue: NewAddressModel()) var newAddressModel: NewAddressModel
    @Transient(defaultValue: HouseInformationModel()) var houseInformationModel: HouseInformationModel

}

extension MoveFlowState {
    func moveIntentRequestMutation() -> OctopusGraphQL.MoveIntentRequestMutation {
        OctopusGraphQL.MoveIntentRequestMutation(
            intentId: movingFlowModel?.id ?? "",
            input: moveIntentRequestInput()
        )
    }

    private func moveIntentRequestInput() -> OctopusGraphQL.MoveIntentRequestInput {
        OctopusGraphQL.MoveIntentRequestInput(
            moveToAddress: .init(
                street: newAddressModel.address,
                postalCode: newAddressModel.postalCode
            ),
            moveFromAddressId: movingFromAddressModel?.id ?? "",
            movingDate: newAddressModel.movingDate,
            numberCoInsured: newAddressModel.numberOfCoinsured,
            squareMeters: newAddressModel.numberOfCoinsured,
            apartment: apartmentInput(),
            house: houseInput()
        )
    }

    private func apartmentInput() -> OctopusGraphQL.MoveToApartmentInput? {
        switch selectedHousingType {
        case .apartmant, .rental:
            return OctopusGraphQL.MoveToApartmentInput(
                subType: selectedHousingType.asMoveApartmentSubType,
                isStudent: false
            )
        case .house:
            return nil
        }
    }

    private func houseInput() -> OctopusGraphQL.MoveToHouseInput? {
        switch selectedHousingType {
        case .apartmant, .rental:
            return nil
        case .house:
            return OctopusGraphQL.MoveToHouseInput(
                ancillaryArea: houseInformationModel.ancillaryArea,
                yearOfConstruction: houseInformationModel.yearOfConstruction,
                numberOfBathrooms: houseInformationModel.numberOfBathrooms,
                isSubleted: false,
                extraBuildings: houseInformationModel.extraBuildings.map({
                    OctopusGraphQL.MoveExtraBuildingInput(
                        area: $0.livingArea,
                        type: OctopusGraphQL.MoveExtraBuildingType(rawValue: $0.type) ?? .garage,
                        hasWaterConnected: $0.connectedToWater
                    )
                })
            )
        }
    }
}
