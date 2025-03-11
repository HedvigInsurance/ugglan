import Foundation
import hCore
import hCoreUI

public struct TravelInsuranceContractSpecification: Codable, Equatable, Hashable, Sendable {
    let contractId: String
    let minStartDate: Date
    let maxStartDate: Date
    let numberOfCoInsured: Int
    let maxDuration: Int
    let street: String
    let email: String?
    let fullName: String

    public init(
        contractId: String,
        minStartDate: Date,
        maxStartDate: Date,
        numberOfCoInsured: Int,
        maxDuration: Int,
        street: String,
        email: String?,
        fullName: String
    ) {
        self.contractId = contractId
        self.minStartDate = minStartDate
        self.maxStartDate = maxStartDate
        self.numberOfCoInsured = numberOfCoInsured
        self.maxDuration = maxDuration
        self.street = street
        self.email = email
        self.fullName = fullName
    }
}

public struct PolicyCoinsuredPersonModel: Codable, Equatable, Hashable {
    var fullName: String
    var personalNumber: String? = nil
    var birthDate: String? = nil
}

@MainActor
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
            hTextColor.Opaque.primary
        } else {
            hSignalColor.Red.element
        }
    }
}
