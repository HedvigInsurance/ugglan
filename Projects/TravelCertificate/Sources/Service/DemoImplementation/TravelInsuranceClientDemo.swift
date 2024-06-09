import Foundation

public struct TravelInsuranceClientDemo: TravelInsuranceClient {

    public init() {}

    public func getSpecifications() async throws -> [TravelInsuranceContractSpecification] {
        throw TravelInsuranceError.missingURL
    }
    public func submitForm(dto: TravenInsuranceFormDTO) async throws -> URL {
        throw TravelInsuranceError.missingURL
    }
    public func getList() async throws -> (list: [TravelCertificateModel], canAddTravelInsurance: Bool) {
        throw TravelInsuranceError.missingURL
    }
}
