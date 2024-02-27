import Foundation

public struct UpcomingRenewal: Codable, Equatable {
    let renewalDate: String?
    let draftCertificateUrl: String?

    public init(
        renewalDate: String?,
        draftCertificateUrl: String?
    ) {
        self.renewalDate = renewalDate
        self.draftCertificateUrl = draftCertificateUrl
    }
}

enum RenewalType {
    case regular
    case coInsured
}
