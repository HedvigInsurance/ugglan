import Addons
import Foundation

class TravelInsuranceClientDemo: TravelInsuranceClient {
    func getSpecifications() async throws -> [TravelInsuranceContractSpecification] {
        []
    }

    func submitForm(dto: TravelInsuranceFormDTO) async throws -> URL {
        URL(string: "")!
    }

    func getList(
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
