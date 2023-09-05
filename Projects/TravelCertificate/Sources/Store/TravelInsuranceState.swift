import Apollo
import Flow
import Presentation
import SwiftUI
import hCore
import hGraphQL

struct TravelInsuranceState: StateProtocol {
    init() {}
    @OptionalTransient var travelInsuranceModel: TravelInsuranceModel?
    @OptionalTransient var travelInsuranceConfigs: TravelInsuranceSpecification?
    @OptionalTransient var travelInsuranceConfig: TravelInsuranceContractSpecification?
    @OptionalTransient var downloadURL: URL?
}

struct TravelInsuranceModel: Codable, Equatable, Hashable {
    var startDate: Date
    var minStartDate: Date
    var maxStartDate: Date
    var isPolicyHolderIncluded: Bool = true
    var email: String
    let fullName: String
    var policyCoinsuredPersons: [PolicyCoinsuredPersonModel] = []

    func isValidWithMessage() -> (valid: Bool, message: String?) {
        let isValid = isPolicyHolderIncluded || policyCoinsuredPersons.count > 0
        var message: String? = nil
        if !isValid {
            message = L10n.TravelCertificate.coinsuredErrorLabel
        }
        return (isValid, message)
    }
}

public struct TravelInsuranceSpecification: Codable, Equatable, Hashable {
    let infoSpecifications: [TravelInsuranceInfoSpecification]
    let travelCertificateSpecifications: [TravelInsuranceContractSpecification]
    let email: String?
    let fullName: String
    public init(
        _ data: OctopusGraphQL.TravelCertificateQuery.Data.CurrentMember,
        email: String
    ) {
        self.email = email
        self.fullName = data.firstName + " " + data.lastName
        infoSpecifications = data.travelCertificateSpecifications.infoSpecifications.map({
            TravelInsuranceInfoSpecification($0)
        })
        travelCertificateSpecifications = data.travelCertificateSpecifications.contractSpecifications.map({
            TravelInsuranceContractSpecification($0)
        })
    }
}

public struct TravelInsuranceInfoSpecification: Codable, Equatable, Hashable {
    let title: String
    let body: String

    init(
        _ data: OctopusGraphQL.TravelCertificateQuery.Data.CurrentMember.TravelCertificateSpecification
            .InfoSpecification
    ) {
        title = data.title
        body = data.body
    }
}

public struct TravelInsuranceContractSpecification: Codable, Equatable, Hashable {
    let contractId: String
    let minStartDate: Date
    let maxStartDate: Date
    let numberOfCoInsured: Int
    let maxDuration: Int
    let street: String
    init(
        contractId: String,
        minStartDate: Date,
        maxStartDate: Date,
        numberOfCoInsured: Int,
        maxDuration: Int,
        street: String
    ) {
        self.contractId = contractId
        self.minStartDate = minStartDate
        self.maxStartDate = maxStartDate
        self.numberOfCoInsured = numberOfCoInsured
        self.maxDuration = maxDuration
        self.street = street
    }

    init(
        _ data: OctopusGraphQL.TravelCertificateQuery.Data.CurrentMember.TravelCertificateSpecification
            .ContractSpecification
    ) {
        self.contractId = data.contractId
        self.minStartDate = data.minStartDate.localDateToDate ?? Date()
        self.maxStartDate = data.maxStartDate.localDateToDate ?? Date().addingTimeInterval(60 * 60 * 24 * 90)
        self.numberOfCoInsured = data.numberOfCoInsured
        self.maxDuration = data.maxDurationDays
        self.street = data.location?.street ?? ""

    }
}

struct PolicyCoinsuredPersonModel: Codable, Equatable, Hashable {
    var fullName: String
    var personalNumber: String
}
