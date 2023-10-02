import Apollo
import Flow
import Foundation
import Presentation
import hCore
import hGraphQL

public final class MoveFlowStore: LoadingStateStore<MoveFlowState, MoveFlowAction, MoveFlowLoadingAction> {
    @Inject var giraffe: hGiraffe
    @Inject var octopus: hOctopus
    var addressInputModel = AddressInputModel()
    var houseInformationInputModel = HouseInformationInputModel()
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
                            self.addressInputModel.nbOfCoInsured = moveIntent.suggestedNumberCoInsured
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
                let mutation = self.moveIntentRequestMutation()
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
                //                let intentId = self.state.movingFlowModel?.id ?? ""
                //                let mutation = OctopusGraphQL.MoveIntentCommitMutation(intentId: intentId)
                //                let graphQlMutation = self.octopus.client.perform(mutation: mutation)
                let minimumTime = Signal(after: 1.5).future
                disposeBag += minimumTime.onValue({ [weak self] _ in
                    self?.removeLoading(for: .confirmMoveIntent)
                    callback(.end)
                })
                //                disposeBag += combineLatest(graphQlMutation.resultSignal, minimumTime.resultSignal)
                //                    .onValue { [weak self] mutation, minimumTime in
                //                        if let data = mutation.value {
                //                            if let userError = data.moveIntentCommit.userError?.message {
                //                                self?.setError(userError, for: .confirmMoveIntent)
                //                                callback(.end(MovingFlowError.serverError(message: userError)))
                //                            } else {
                //                                self?.removeLoading(for: .confirmMoveIntent)
                //                                callback(.end)
                //                            }
                //                        } else if let _ = mutation.error {
                //                            self?.setError(L10n.General.errorBody, for: .confirmMoveIntent)
                //                        }
                //                    }
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
    case openAddressFillScreen
    case openHouseFillScreen
    case openAddBuilding
    case dismissAddBuilding
    case openConfirmScreen
    case openProcessingView
    case openFailureScreen(error: String)
    case openTypeOfBuilding(for: ExtraBuildingType?)
    case dismissTypeOfBuilding
    case goToFreeTextChat
    case dismissMovingFlow
    case document(url: URL, title: String)
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
}

extension MoveFlowStore {
    func moveIntentRequestMutation() -> OctopusGraphQL.MoveIntentRequestMutation {
        OctopusGraphQL.MoveIntentRequestMutation(
            intentId: state.movingFlowModel?.id ?? "",
            input: moveIntentRequestInput()
        )
    }

    private func moveIntentRequestInput() -> OctopusGraphQL.MoveIntentRequestInput {
        OctopusGraphQL.MoveIntentRequestInput(
            moveToAddress: .init(
                street: addressInputModel.address,
                postalCode: addressInputModel.postalCode
            ),
            moveFromAddressId: state.movingFromAddressModel?.id ?? "",
            movingDate: addressInputModel.accessDate?.localDateString ?? "",
            numberCoInsured: addressInputModel.nbOfCoInsured,
            squareMeters: Int(addressInputModel.squareArea) ?? 0,
            apartment: apartmentInput(),
            house: houseInput()
        )
    }

    private func apartmentInput() -> OctopusGraphQL.MoveToApartmentInput? {
        switch state.selectedHousingType {
        case .apartmant, .rental:
            return OctopusGraphQL.MoveToApartmentInput(
                subType: state.selectedHousingType.asMoveApartmentSubType,
                isStudent: addressInputModel.isStudent
            )
        case .house:
            return nil
        }
    }

    private func houseInput() -> OctopusGraphQL.MoveToHouseInput? {
        switch state.selectedHousingType {
        case .apartmant, .rental:
            return nil
        case .house:
            return OctopusGraphQL.MoveToHouseInput(
                ancillaryArea: Int(houseInformationInputModel.ancillaryArea) ?? 0,
                yearOfConstruction: Int(houseInformationInputModel.yearOfConstruction) ?? 0,
                numberOfBathrooms: houseInformationInputModel.bathrooms,
                isSubleted: houseInformationInputModel.isSubleted,
                extraBuildings: houseInformationInputModel.extraBuildings.map({
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
