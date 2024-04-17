import Foundation
import hCore

public protocol TravelInsuranceClient {
    func getSpecifications() async throws -> [TravelInsuranceContractSpecification]
    func submitForm(dto: TravenInsuranceFormDTO) async throws -> URL
    func getList() async throws -> [TravelCertificateModel]
}

public struct TravenInsuranceFormDTO {
    let contractId: String
    let startDate: String
    let isMemberIncluded: Bool
    let coInsured: [CoInsuredDto]
    let email: String
}
public struct CoInsuredDto {
    let fullName: String
    let personalNumber: String?
    let birthDate: String?
}

enum TravelInsuranceError {
    case missingURL
    case graphQLError(error: String)
}

extension TravelInsuranceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingURL:
            return L10n.General.errorBody
        case let .graphQLError(error):
            return error
        }
    }
}
