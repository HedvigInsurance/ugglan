import Apollo
import Flow
import Presentation
import SwiftUI
import hCore
import hGraphQL

struct TravelInsuranceState: StateProtocol {
    init() {}
    @OptionalTransient var travelInsuranceModel: TravelInsuranceModel?
}

struct TravelInsuranceModel: Codable, Equatable, Hashable {
    var startDate: String
    var endDate: String?
    var isPolicyHolderIncluded: Bool = true
    let maxNumberOfConisuredPersons: Int
    let maxTravelInsuraceDays: Int
    var policyCoinsuredPersons: [PolicyCoinsuredPersonModel] = []
    init(
        startDate: String,
        maxNumberOfConisuredPersons: Int,
        maxTravelInsuraceDays: Int
    ) {
        self.startDate = startDate
        self.maxNumberOfConisuredPersons = maxNumberOfConisuredPersons
        self.maxTravelInsuraceDays = maxTravelInsuraceDays
    }
}

struct PolicyCoinsuredPersonModel: Codable, Equatable, Hashable {
    var id = UUID()
    let fullName: String
    let personalNumber: String
}
