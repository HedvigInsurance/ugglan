import Addons
import AutomaticLog
import Foundation
import hCore

@MainActor
public class TravelInsuranceService {
    @Inject var service: TravelInsuranceClient

    @Log
    public func getSpecifications() async throws -> [TravelInsuranceContractSpecification] {
        try await service.getSpecifications()
    }

    // The result is the signed certificate URL and cannot be annotated, so the output is not logged.
    @Log(.error)
    public func submitForm(dto: TravelInsuranceFormDTO) async throws -> URL {
        try await service.submitForm(dto: dto)
    }

    @Log
    public func getList(
        source: AddonSource
    ) async throws -> (
        list: [TravelCertificateModel], canAddTravelInsurance: Bool, banner: AddonBanner?
    ) {
        try await service.getList(source: source)
    }
}
