import Addons
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

public struct TravelInsuranceFormDTO: Encodable {
    public let contractId: String
    public let startDate: String
    public let isMemberIncluded: Bool
    public let coInsured: [CoInsuredDto]
    public let email: String
}

public struct CoInsuredDto: Encodable {
    public let fullName: String
    public let personalNumber: String?
    public let birthDate: String?
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
