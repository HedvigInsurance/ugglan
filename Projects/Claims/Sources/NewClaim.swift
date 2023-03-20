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

public struct NewClaim: Codable, Equatable {

    public var dateOfOccurrence: String?
    public var location: NewClaimsInfo?
    public var listOfLocation: [NewClaimsInfo]?
    public var listOfDamage: [NewClaimsInfo]?
    public var listOfModels: [Model]?
    public var listOfBrands: [Brand]?
    public var dateOfPurchase: Date?
    public var priceOfPurchase: Double?
    public var chosenModel: Model?
    public var chosenDamages: [NewClaimsInfo]?

    init(
        dateOfOccurrence: String
    ) {
        self.dateOfOccurrence = dateOfOccurrence
    }

    init(
        location: NewClaimsInfo
    ) {
        self.location = location
    }

    init(
        listOfLocation: [NewClaimsInfo]
    ) {
        self.listOfLocation = listOfLocation
    }

    init(
        listOfModels: [Model]
    ) {
        self.listOfModels = listOfModels
    }

    init(
        listOfDamage: [NewClaimsInfo]
    ) {
        self.listOfDamage = listOfDamage
    }

    init(
        listOfBrands: [Brand]
    ) {
        self.listOfBrands = listOfBrands
    }

    init(
        dateOfPurchase: Date
    ) {
        self.dateOfPurchase = dateOfPurchase
    }

    init(
        priceOfPurchase: Double
    ) {
        self.priceOfPurchase = priceOfPurchase
    }
}
