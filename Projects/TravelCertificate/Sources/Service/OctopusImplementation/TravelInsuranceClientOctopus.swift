import Foundation
import hCore
import hGraphQL

public class TravelInsuranceService {
    @Inject var service: TravelInsuranceClient

    public func getSpecifications() async throws -> [TravelInsuranceContractSpecification] {
        log.info("TravelInsuranceService: getSpecifications", error: nil, attributes: nil)
        return try await service.getSpecifications()
    }

    public func submitForm(dto: TravelInsuranceFormDTO) async throws -> URL {
        log.info("TravelInsuranceClient: submitForm", error: nil, attributes: ["data": dto])
        return try await service.submitForm(dto: dto)
    }

    public func getList() async throws -> (list: [TravelCertificateModel], canAddTravelInsurance: Bool) {
        log.info("TravelInsuranceService: getList", error: nil, attributes: nil)
        return try await service.getList()
    }
}

public class TravelInsuranceClientOctopus: TravelInsuranceClient {
    @Inject var octopus: hOctopus

    public init() {}
    public func getSpecifications() async throws -> [TravelInsuranceContractSpecification] {
        let query = OctopusGraphQL.TravelCertificateQuery()
        do {
            let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
            let email = data.currentMember.email
            let fullName = data.currentMember.firstName + " " + data.currentMember.lastName
            let specification = data.currentMember.travelCertificateSpecifications.contractSpecifications.compactMap {
                data in
                TravelInsuranceContractSpecification(data, email: email, fullName: fullName)
            }
            return specification
        } catch let ex {
            throw ex
        }
    }

    public func submitForm(dto: TravelInsuranceFormDTO) async throws -> URL {
        let input = dto.asOctopusInput
        let mutation = OctopusGraphQL.CreateTravelCertificateMutation(input: input)
        do {
            async let data = try await self.octopus.client.perform(mutation: mutation)
            async let sleepTask: () = Task.sleep(nanoseconds: 1_500_000_000)

            let response = try await [data, sleepTask] as [Any]

            if let mutationResponse = response[0] as? OctopusGraphQL.CreateTravelCertificateMutation.Data,
                let url = URL(string: mutationResponse.travelCertificateCreate.signedUrl)
            {
                return url
            }
            throw TravelInsuranceError.missingURL

        } catch let ex {
            throw ex
        }
    }

    public func getList() async throws -> (list: [TravelCertificateModel], canAddTravelInsurance: Bool) {
        let query = OctopusGraphQL.TravelCertificatesQuery()
        let canAddTravelInsuranceQuery = OctopusGraphQL.CanCreateTravelCertificateQuery()
        do {
            async let listData = try await self.octopus.client.fetch(
                query: query,
                cachePolicy: .fetchIgnoringCacheCompletely
            )
            async let canAddTravelInsuranceData = try await self.octopus.client.fetch(
                query: canAddTravelInsuranceQuery,
                cachePolicy: .fetchIgnoringCacheCompletely
            )

            let response = try await [listData, canAddTravelInsuranceData] as [Any]

            if let listResponse = response[0] as? OctopusGraphQL.TravelCertificatesQuery.Data,
                let canAddTravelInsuranceResponse = response[1] as? OctopusGraphQL.CanCreateTravelCertificateQuery.Data
            {
                let listData = listResponse.currentMember.travelCertificates.compactMap({
                    TravelCertificateModel.init($0)
                })
                let canAddTravelInsuranceData = !canAddTravelInsuranceResponse.currentMember.activeContracts
                    .filter({ $0.supportsTravelCertificate }).isEmpty

                return (listData, canAddTravelInsuranceData)
            }
            throw TravelInsuranceError.missingURL

        } catch let ex {
            throw ex
        }
    }

}

extension TravelInsuranceFormDTO {
    fileprivate var asOctopusInput: OctopusGraphQL.TravelCertificateCreateInput {
        return .init(
            contractId: contractId,
            startDate: startDate,
            isMemberIncluded: isMemberIncluded,
            coInsured: coInsured.compactMap({
                .init(
                    fullName: $0.fullName,
                    ssn: GraphQLNullable(optionalValue: $0.personalNumber),
                    dateOfBirth: GraphQLNullable(optionalValue: $0.birthDate)
                )
            }),
            email: email
        )
    }
}

@MainActor
extension TravelInsuranceContractSpecification {
    init(
        _ data: OctopusGraphQL.TravelCertificateQuery.Data.CurrentMember.TravelCertificateSpecifications
            .ContractSpecification,
        email: String,
        fullName: String
    ) {
        self.contractId = data.contractId
        self.minStartDate = data.minStartDate.localDateToDate ?? Date()
        self.maxStartDate = data.maxStartDate.localDateToDate ?? Date().addingTimeInterval(60 * 60 * 24 * 90)
        self.numberOfCoInsured = data.numberOfCoInsured
        self.maxDuration = data.maxDurationDays
        self.street = data.location?.street ?? ""
        self.email = email
        self.fullName = fullName
    }
}

extension TravelCertificateModel {
    init?(_ data: OctopusGraphQL.TravelCertificatesQuery.Data.CurrentMember.TravelCertificate) {
        guard let url = URL(string: data.signedUrl) else { return nil }
        self.id = data.id
        self.date = data.startDate.localDateToDate ?? Date()
        self.valid = (data.expiryDate.localDateToDate ?? Date()) > Date()
        self.url = url
    }
}
