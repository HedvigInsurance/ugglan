import hGraphQL

public struct TierModel: Codable, Equatable, Hashable {
    let id: String
    let insuranceDisplayName: String
    let streetName: String
    let premium: MonetaryAmount
}
