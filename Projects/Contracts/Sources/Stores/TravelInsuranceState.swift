import Apollo
import Flow
import Presentation
import SwiftUI
import hCore
import hGraphQL

struct TravelInsuranceState: StateProtocol {
    init() {}
    @OptionalTransient var travelInsuranceModel: TravelInsuranceModel?
    @OptionalTransient var travelInsuranceConfig: TravelInsuranceConfig?

}

struct TravelInsuranceModel: Codable, Equatable, Hashable {
    var startDate: Date = Date()
    var endDate: Date?
    var isPolicyHolderIncluded: Bool = true
    var policyCoinsuredPersons: [PolicyCoinsuredPersonModel] = []
}

struct TravelInsuranceConfig: Codable, Equatable, Hashable {
    let minimumDate: Date
    let maximumDate: Date
    let maxNumberOfConisuredPersons: Int
    let maxTravelInsuraceDays: Int
    init(
        minimumDate: Date,
        maximumDate: Date,
        maxNumberOfConisuredPersons: Int,
        maxTravelInsuraceDays: Int
    ) {
        self.maxNumberOfConisuredPersons = maxNumberOfConisuredPersons
        self.maxTravelInsuraceDays = maxTravelInsuraceDays
        self.minimumDate =  minimumDate
        self.maximumDate =  maximumDate
    }
}

struct PolicyCoinsuredPersonModel: Codable, Equatable, Hashable {
    let fullName: String
    let personalNumber: String
}
