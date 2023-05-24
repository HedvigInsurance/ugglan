import Apollo
import Flow
import Presentation
import SwiftUI
import hCore
import hGraphQL

struct TravelInsuranceState: StateProtocol {
    init() {}
    @OptionalTransient var travelInsuranceModel: TravelInsuranceModel?
    @OptionalTransient var travelInsuranceConfigs: [TravelInsuranceConfig]?
    @OptionalTransient var travelInsuranceConfig: TravelInsuranceConfig?
    @Transient(defaultValue: [:]) var loadingStates: [TravelInsuranceLoadingAction: LoadingState<String>]
}

struct TravelInsuranceModel: Codable, Equatable, Hashable {
    var startDate: Date
    var isPolicyHolderIncluded: Bool = true
    var email: String
    var policyCoinsuredPersons: [PolicyCoinsuredPersonModel] = []
}

struct TravelInsuranceConfig: Codable, Equatable, Hashable {
    let contractId: String
    let minStartDate: Date
    let maxStartDate: Date
    let numberOfCoInsured: Int
    let maxDuration: Int
    let street: String
    let email: String
    init(contractId: String, minStartDate: Date, maxStartDate: Date, numberOfCoInsured: Int, maxDuration: Int, street: String, email: String) {
        self.contractId = contractId
        self.minStartDate = minStartDate
        self.maxStartDate = maxStartDate
        self.numberOfCoInsured = numberOfCoInsured
        self.maxDuration = maxDuration
        self.street = street
        self.email = email
    }
    
    init(model: OctopusGraphQL.CurrentMemberQuery.Data.CurrentMember.TravelCertificateSpecification, email: String) {
        self.contractId = model.contractId
        self.minStartDate = model.minStartDate.localDateToDate ?? Date()
        self.maxStartDate = model.maxStartDate.localDateToDate ?? Date().addingTimeInterval(60 * 60 * 24 * 90)
        self.numberOfCoInsured = model.numberOfCoInsured
        self.maxDuration = model.maxDurationDays
        self.street = model.location?.street ?? ""
        self.email = email
        
    }
}

struct PolicyCoinsuredPersonModel: Codable, Equatable, Hashable {
    var fullName: String
    var personalNumber: String
}
