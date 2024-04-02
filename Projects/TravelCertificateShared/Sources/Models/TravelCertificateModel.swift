import Foundation
import hCore
import hCoreUI

public struct TravelCertificateModel: Codable, Equatable, Hashable, Identifiable {
    public var id: String
    public var date: Date
    public var valid: Bool
    public var url: URL

    public init?(id: String, date: Date, valid: Bool, url: URL?) {
        guard let url = url else { return nil }
        self.id = id
        self.date = date
        self.valid = valid
        self.url = url
    }

    var title: String {
        "\(L10n.TravelCertificate.cardTitle) \(date.displayDateDDMMMFormat)"
    }
}

extension TravelCertificateModel {
    @hColorBuilder
    var textColor: some hColor {
        if valid {
            hTextColor.primary
        } else {
            hSignalColor.redElement
        }
    }
}

public struct TravelInsuranceSpecification: Codable, Equatable, Hashable {
    public var infoSpecifications: [TravelInsuranceInfoSpecification]
    public var travelCertificateSpecifications: [TravelInsuranceContractSpecification]
    public var email: String?
    public var fullName: String

    public init(
        infoSpecifications: [TravelInsuranceInfoSpecification],
        travelCertificateSpecifications: [TravelInsuranceContractSpecification],
        email: String?,
        fullName: String
    ) {
        self.infoSpecifications = infoSpecifications
        self.travelCertificateSpecifications = travelCertificateSpecifications
        self.email = email
        self.fullName = fullName
    }
}

public struct TravelInsuranceContractSpecification: Codable, Equatable, Hashable {
    public var contractId: String
    public var minStartDate: Date
    public var maxStartDate: Date
    public var numberOfCoInsured: Int
    public var maxDuration: Int
    public var street: String
    public init(
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
}

public struct TravelInsuranceInfoSpecification: Codable, Equatable, Hashable {
    public var title: String
    public var body: String

    public init() {
        self.title = ""
        self.body = ""
    }
}

struct TravelInsuranceModel: Codable, Equatable, Hashable {
    var startDate: Date
    var minStartDate: Date
    var maxStartDate: Date
    var isPolicyHolderIncluded: Bool = false
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

public struct PolicyCoinsuredPersonModel: Codable, Equatable, Hashable {
    var fullName: String
    var personalNumber: String? = nil
    var birthDate: String? = nil
}
