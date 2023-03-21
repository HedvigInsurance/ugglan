import Foundation

public struct NewClaimsInfo: Decodable, Encodable, Equatable, Hashable {
    public var displayValue: String
    public var value: String
}

public struct Brand: Decodable, Encodable, Equatable, Hashable {
    public var displayName: String
    public var itemBrandId: String?
    public var itemTypeId: String?
}

public struct Model: Decodable, Encodable, Equatable, Hashable {
    public var displayName: String
    public var imageURL: String?
    public var itemBrandId: String
    public var itemModelId: String
    public var itemTypeID: String
}

public struct Damage: Decodable, Encodable, Equatable, Hashable {
    public var displayName: String
    public var itemProblemId: String
}

public struct NewClaim: Codable, Equatable {

    public let id: String
    public var dateOfOccurrence: String?
    public var location: NewClaimsInfo?
    public var listOfLocation: [NewClaimsInfo]?
    public var listOfDamage: [Damage]?
    public var listOfModels: [Model]?
    public var filteredListOfModels: [Model]?
    public var listOfBrands: [Brand]?
    public var dateOfPurchase: Date?
    public var priceOfPurchase: Double?
    public var chosenModel: Model?
    public var chosenBrand: Brand?
    public var chosenDamages: [Damage]?

    init(
        id: String
    ) {
        self.id = id
    }
}
