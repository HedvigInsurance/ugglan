import Foundation
import hCore

@testable import TravelCertificate

struct MockData {
    static func createMockTravelInsuranceService(
        fetchSpecifications: @escaping FetchSpecifications = {
            return []
        },
        submit: @escaping Submit = { dto in
            if let url = URL(string: "dto") {
                return url
            }
            throw TravelInsuranceError.missingURL
        },
        fetchList: @escaping FetchList = {
            return ([], true)
        }
    ) -> MockTravelInsuranceService {
        let service = MockTravelInsuranceService(
            fetchSpecifications: fetchSpecifications,
            submit: submit,
            fetchList: fetchList
        )
        Dependencies.shared.add(module: Module { () -> TravelInsuranceClient in service })
        return service
    }
}

typealias FetchSpecifications = () async throws -> [TravelInsuranceContractSpecification]
typealias Submit = (TravelInsuranceFormDTO) async throws -> URL
typealias FetchList = () async throws -> ([TravelCertificateModel], Bool)

class MockTravelInsuranceService: TravelInsuranceClient {
    var events = [Event]()

    var fetchSpecifications: FetchSpecifications
    var submit: Submit
    var fetchList: FetchList

    enum Event {
        case getSpecifications
        case submitForm
        case getList
    }

    init(
        fetchSpecifications: @escaping FetchSpecifications,
        submit: @escaping Submit,
        fetchList: @escaping FetchList
    ) {
        self.fetchSpecifications = fetchSpecifications
        self.submit = submit
        self.fetchList = fetchList
    }

    func getSpecifications() async throws -> [TravelInsuranceContractSpecification] {
        events.append(.getSpecifications)
        let data = try await fetchSpecifications()
        return data
    }

    func submitForm(dto: TravelInsuranceFormDTO) async throws -> URL {
        events.append(.submitForm)
        let data = try await submit(dto)
        return data
    }

    func getList() async throws -> (list: [TravelCertificateModel], canAddTravelInsurance: Bool) {
        events.append(.getList)
        let data = try await fetchList()
        return data
    }
}
