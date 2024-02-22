import Foundation
import hCore
import hCoreUI

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

public struct TravelInsuranceSpecification: Codable, Equatable, Hashable {
    let infoSpecifications: [TravelInsuranceInfoSpecification]
    let travelCertificateSpecifications: [TravelInsuranceContractSpecification]
    let email: String?
    let fullName: String
}

public struct TravelInsuranceInfoSpecification: Codable, Equatable, Hashable {
    let title: String
    let body: String
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
}

public struct PolicyCoinsuredPersonModel: Codable, Equatable, Hashable {
    var fullName: String
    var personalNumber: String? = nil
    var birthDate: String? = nil
}

public struct TravelCertificateModel: Codable, Equatable, Hashable, Identifiable {
    public let id: String
    let date: Date
    let valid: Bool
    let url: URL

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
