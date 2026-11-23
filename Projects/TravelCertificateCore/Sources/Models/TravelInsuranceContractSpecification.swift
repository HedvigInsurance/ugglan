import AutomaticLog
import Foundation
import hCore

@Loggable
public struct TravelInsuranceContractSpecification: Codable, Equatable, Hashable, Sendable {
    public let contractId: String
    public let exposureDisplayName: String
    public let minStartDate: Date
    public let maxStartDate: Date
    public let maxDuration: Int
    @Masked public let email: String?
    public let fullName: String

    public init(
        contractId: String,
        exposureDisplayName: String,
        minStartDate: Date,
        maxStartDate: Date,
        maxDuration: Int,
        email: String?,
        fullName: String
    ) {
        self.contractId = contractId
        self.exposureDisplayName = exposureDisplayName
        self.minStartDate = minStartDate
        self.maxStartDate = maxStartDate
        self.maxDuration = maxDuration
        self.email = email
        self.fullName = fullName
    }
}

@Loggable
public struct PolicyCoinsuredPersonModel: Codable, Equatable, Hashable {
    public var fullName: String
    @Masked public var personalNumber: String? = nil
    @Masked public var birthDate: String? = nil

    public init(fullName: String, personalNumber: String? = nil, birthDate: String? = nil) {
        self.fullName = fullName
        self.personalNumber = personalNumber
        self.birthDate = birthDate
    }
}

@Loggable
@MainActor
public struct TravelCertificateModel: Codable, Equatable, Hashable, Identifiable {
    public let id: String
    public let date: Date
    public let valid: Bool
    @Masked public let url: URL

    public init?(id: String, date: Date, valid: Bool, url: URL?) {
        guard let url = url else { return nil }
        self.id = id
        self.date = date
        self.valid = valid
        self.url = url
    }

    public var title: String {
        "\(L10n.TravelCertificate.cardTitle) \(date.displayDateDDMMMFormat)"
    }
}
