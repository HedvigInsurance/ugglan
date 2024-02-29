import Presentation
import hCore
import hGraphQL

public class MoveFlowServiceOctopus: MoveFlowService {
    @Inject var octopus: hOctopus
    @PresentableStore var store: MoveFlowStore

    public init() {}

    public func sendMoveIntent() async throws -> MovingFlowModel {
        let mutation = OctopusGraphQL.MoveIntentCreateMutation()
        let data = try await octopus.client.perform(mutation: mutation)

        if let moveIntentFragment = data.moveIntentCreate.moveIntent?.fragments.moveIntentFragment {
            return MovingFlowModel(from: moveIntentFragment)
        } else if let userError = data.moveIntentCreate.userError?.message {
            throw MovingFlowError.serverError(message: userError)
        }
        throw MovingFlowError.missingDataError(message: L10n.General.errorBody)
    }

    public func requestMoveIntent(
        intentId: String,
        addressInputModel: AddressInputModel,
        houseInformationInputModel: HouseInformationInputModel
    ) async throws -> MovingFlowModel {

        let moveIntentRequestInput = OctopusGraphQL.MoveIntentRequestInput(
            moveToAddress: .init(
                street: addressInputModel.address,
                postalCode: addressInputModel.postalCode.replacingOccurrences(of: " ", with: "")
            ),
            moveFromAddressId: store.state.movingFromAddressModel?.id ?? "",
            movingDate: addressInputModel.accessDate?.localDateString ?? "",
            numberCoInsured: addressInputModel.nbOfCoInsured,
            squareMeters: Int(addressInputModel.squareArea) ?? 0,
            apartment: GraphQLNullable(optionalValue: apartmentInput(addressInputModel: addressInputModel)),
            house: GraphQLNullable(optionalValue: houseInput(houseInformationInputModel: houseInformationInputModel))
        )

        let mutation = OctopusGraphQL.MoveIntentRequestMutation(
            intentId: intentId,
            input: moveIntentRequestInput
        )

        let data = try await octopus.client.perform(mutation: mutation)
        if let moveIntentFragment = data.moveIntentRequest.moveIntent?.fragments.moveIntentFragment {
            return MovingFlowModel(from: moveIntentFragment)
        } else if let userError = data.moveIntentRequest.userError?.message {
            throw MovingFlowError.serverError(message: userError)
        }
        throw MovingFlowError.missingDataError(message: L10n.General.errorBody)
    }

    public func confirmMoveIntent(intentId: String) async throws {

        let mutation = OctopusGraphQL.MoveIntentCommitMutation(intentId: intentId)
        let data = try await octopus.client.perform(mutation: mutation)

        if let userError = data.moveIntentCommit.userError {
            throw MovingFlowError.serverError(message: userError.message ?? "")
        }
    }

    private func apartmentInput(addressInputModel: AddressInputModel) -> OctopusGraphQL.MoveToApartmentInput? {
        switch store.state.selectedHousingType {
        case .apartmant, .rental:
            return OctopusGraphQL.MoveToApartmentInput(
                subType: store.state.selectedHousingType.asMoveApartmentSubType,
                isStudent: addressInputModel.isStudent
            )
        case .house:
            return nil
        }
    }

    private func houseInput(houseInformationInputModel: HouseInformationInputModel) -> OctopusGraphQL.MoveToHouseInput?
    {
        switch store.state.selectedHousingType {
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
                        type: GraphQLEnum<OctopusGraphQL.MoveExtraBuildingType>(rawValue: $0.type),
                        hasWaterConnected: $0.connectedToWater
                    )
                })

            )
        }
    }
}
