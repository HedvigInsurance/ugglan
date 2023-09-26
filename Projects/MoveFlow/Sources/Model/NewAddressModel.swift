import Foundation
import hGraphQL

public struct NewAddressModel: Codable, Equatable, Hashable {
    let address: String
    let postalCode: String
    let movingDate: String
    let numberOfCoinsured: Int
    let squareMeters: Int
    let isStudent: Bool
    init(
        address: String,
        postalCode: String,
        movingDate: String,
        numberOfCoinsured: Int,
        squareMeters: Int,
        isStudent: Bool
    ) {
        self.address = address
        self.postalCode = postalCode
        self.movingDate = movingDate
        self.numberOfCoinsured = numberOfCoinsured
        self.squareMeters = squareMeters
        self.isStudent = isStudent
    }

    init() {
        address = ""
        postalCode = ""
        movingDate = ""
        numberOfCoinsured = 0
        squareMeters = 0
        isStudent = false
    }
}
