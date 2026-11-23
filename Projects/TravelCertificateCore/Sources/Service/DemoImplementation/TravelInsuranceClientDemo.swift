import AddonsCore
import Foundation

public class TravelInsuranceClientDemo: TravelInsuranceClient {
    public init() {}

    public func getSpecifications() async throws -> [TravelInsuranceContractSpecification] {
        []
    }

    public func submitForm(dto: TravelInsuranceFormDTO) async throws -> URL {
        URL(string: "")!
    }

    public func getList(
        source: AddonSource
    ) async throws -> (
        list: [TravelCertificateModel], canAddTravelInsurance: Bool, banner: AddonBanner?
    ) {
        let listItem: TravelCertificateModel? = .init(id: "id", date: Date(), valid: true, url: nil)
        if let listItem {
            return (
                list: [listItem],
                canAddTravelInsurance: true,
                banner: nil
            )
        }
        return (
            list: [],
            canAddTravelInsurance: true,
            banner: nil
        )
    }
}
