import Foundation
import hGraphQL

public struct MovingFlowModel: Codable, Equatable, Hashable {
    let id: String
    let minMovingDate: String
    let maxMovingDate: String
    let numberCoInsured: Int
    let currentHomeAddresses: MoveAddress
    let quotes: Quotes

    //    init(
    //        with data: OctopusGraphQL.FlowTerminationSuccessFragment
    //    ) {
    //        self.terminationDate = data.terminationDate
    //        self.surveyUrl = data.surveyUrl
    //    }
}

struct MoveAddress: Codable, Equatable, Hashable {
    let id: String
    let street: String
    let postalCode: String
    let city: String?
    let bbrId: String?
    let apartmentNumber: String?
    let floor: String?
}

struct Quotes: Codable, Equatable, Hashable {
    let address: MoveAddress
    let premium: MonetaryAmount  //?
    let numberCoInsured: Int
    let startDate: String
    let termsVersion: TermsVersion
}

struct TermsVersion: Codable, Equatable, Hashable {
    let id: String
}
