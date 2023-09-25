import Foundation
import hGraphQL

public struct NewAddressModel: Codable, Equatable, Hashable {
    var address: String
    var postalCode: String
    var movingDate: String
    var numberOfCoinsured: Int
    var squareMeters: Int

    init(
        address: String,
        postalCode: String,
        movingDate: String,
        numberOfCoinsured: Int,
        squareMeters: Int
    ) {
        self.address = address
        self.postalCode = postalCode
        self.movingDate = movingDate
        self.numberOfCoinsured = numberOfCoinsured
        self.squareMeters = squareMeters
    }

    init() {
        address = ""
        postalCode = ""
        movingDate = ""
        numberOfCoinsured = 0
        squareMeters = 0
    }

    func toGraphQLInput(from addressId: String, with type: HousingType) -> OctopusGraphQL.MoveIntentRequestInput {
        return OctopusGraphQL.MoveIntentRequestInput(
            moveToAddress: .init(street: address, postalCode: postalCode),
            moveFromAddressId: addressId,
            movingDate: movingDate,
            numberCoInsured: numberOfCoinsured,
            squareMeters: squareMeters,
            apartment: .init(subType: type.asMoveApartmentSubType, isStudent: false)
        )
    }
}
