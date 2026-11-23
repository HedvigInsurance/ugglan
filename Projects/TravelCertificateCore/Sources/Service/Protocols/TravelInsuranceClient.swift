import AddonsCore
import AutomaticLog
import Foundation
import hCore

@MainActor
public protocol TravelInsuranceClient {
    func getSpecifications() async throws -> [TravelInsuranceContractSpecification]
    func submitForm(dto: TravelInsuranceFormDTO) async throws -> URL
    func getList(
        source: AddonSource
    ) async throws -> (
        list: [TravelCertificateModel], canAddTravelInsurance: Bool, banner: AddonBanner?
    )
}

@Loggable
public struct TravelInsuranceFormDTO: Encodable {
    public let contractId: String
    public let startDate: String
    public let isMemberIncluded: Bool
    public let coInsured: [CoInsuredDto]
    @Masked public let email: String

    public init(
        contractId: String,
        startDate: String,
        isMemberIncluded: Bool,
        coInsured: [CoInsuredDto],
        email: String
    ) {
        self.contractId = contractId
        self.startDate = startDate
        self.isMemberIncluded = isMemberIncluded
        self.coInsured = coInsured
        self.email = email
    }
}

@Loggable
public struct CoInsuredDto: Encodable {
    public let fullName: String
    @Masked public let personalNumber: String?
    @Masked public let birthDate: String?

    public init(fullName: String, personalNumber: String?, birthDate: String?) {
        self.fullName = fullName
        self.personalNumber = personalNumber
        self.birthDate = birthDate
    }
}

public enum TravelInsuranceError {
    case missingURL
    case graphQLError(error: String)
}

extension TravelInsuranceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .missingURL:
            return L10n.General.errorBody
        case let .graphQLError(error):
            return error
        }
    }
}
