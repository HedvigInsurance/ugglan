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
    @Transient(defaultValue: [:]) var loadingStates: [TravelInsuranceLoadingAction: LoadingState<String>]
}

struct TravelInsuranceModel: Codable, Equatable, Hashable {
    var startDate: Date
    var isPolicyHolderIncluded: Bool = true
    var email: String
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
    public init(_ data: OctopusGraphQL.TravelCertificateQuery.Data.CurrentMember.TravelCertificateSpecification, email: String) {
        self.email = email
        infoSpecifications = data.infoSpecifications.map({TravelInsuranceInfoSpecification($0)})
        travelCertificateSpecifications = data.contractSpecifications.map({TravelInsuranceContractSpecification($0)})
    }
}

public struct TravelInsuranceInfoSpecification: Codable, Equatable, Hashable {
    let title: String
    let body: String
    
    init(_ data: OctopusGraphQL.TravelCertificateQuery.Data.CurrentMember.TravelCertificateSpecification.InfoSpecification) {
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
    init(contractId: String, minStartDate: Date, maxStartDate: Date, numberOfCoInsured: Int, maxDuration: Int, street: String) {
        self.contractId = contractId
        self.minStartDate = minStartDate
        self.maxStartDate = maxStartDate
        self.numberOfCoInsured = numberOfCoInsured
        self.maxDuration = maxDuration
        self.street = street
    }
    
    init(_ data: OctopusGraphQL.TravelCertificateQuery.Data.CurrentMember.TravelCertificateSpecification.ContractSpecification) {
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

public extension TravelInsuranceSpecification {
    func asCommonClaim() -> CommonClaim {
        let bulletPoints = self.infoSpecifications.compactMap({CommonClaim.Layout.TitleAndBulletPoints.BulletPoint(title: $0.title, description: $0.body, icon: nil)})
        let titleAndBulletPoint = CommonClaim.Layout.TitleAndBulletPoints(color: "",
                                                                          buttonTitle: L10n.TravelCertificate.getTravelCertificateButton,
                                                                          title: "",
                                                                          bulletPoints: bulletPoints)
        let emergency = CommonClaim.Layout.Emergency(title: L10n.TravelCertificate.description, color: "")
        let layout = CommonClaim.Layout(titleAndBulletPoint: titleAndBulletPoint, emergency: emergency)
        let commonClaim = CommonClaim(id: "travelInsurance", icon: nil, imageName: "travelCertificate", displayTitle: L10n.TravelCertificate.cardTitle, layout: layout)
        return commonClaim
    }
}
