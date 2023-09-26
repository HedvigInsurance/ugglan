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
}
