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
    var isPolicyHolderIncluded: Bool = true
    var policyCoinsuredPersons: [PolicyCoinsuredPersonModel] = []
}

struct TravelInsuranceConfig: Codable, Equatable, Hashable {
    let contractId: String
    let minStartDate: Date
    let maxStartDate: Date
    let numberOfCoInsured: Int
    let maxDuration: Int
    let email: String
    init(contractId: String, minStartDate: Date, maxStartDate: Date, numberOfCoInsured: Int, maxDuration: Int, email: String) {
        self.contractId = contractId
        self.minStartDate = minStartDate
        self.maxStartDate = maxStartDate
        self.numberOfCoInsured = numberOfCoInsured
        self.maxDuration = maxDuration
        self.email = email
    }
}

struct PolicyCoinsuredPersonModel: Codable, Equatable, Hashable {
    let fullName: String
    let personalNumber: String
}
