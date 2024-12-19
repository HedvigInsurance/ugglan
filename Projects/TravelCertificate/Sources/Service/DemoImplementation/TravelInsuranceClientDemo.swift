import Addons
import Foundation

public struct TravelInsuranceClientDemo: TravelInsuranceClient {

    public init() {}

    public func getSpecifications() async throws -> [TravelInsuranceContractSpecification] {
        throw TravelInsuranceError.missingURL
    }
    public func submitForm(dto: TravelInsuranceFormDTO) async throws -> URL {
        throw TravelInsuranceError.missingURL
    }

    public func getList(
        source: AddonSource
    ) async throws -> (
        list: [TravelCertificateModel], canAddTravelInsurance: Bool, banner: AddonBannerModel?
    ) {
        throw TravelInsuranceError.missingURL
    }
}
