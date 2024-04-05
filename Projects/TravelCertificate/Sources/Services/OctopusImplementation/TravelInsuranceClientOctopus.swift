import Foundation
import hCore
import hGraphQL

public class TravelInsuranceClientOctopus: TravelInsuranceClient {
    @Inject var octopus: hOctopus

    public init() {}
    public func getSpecifications() async throws -> TravelInsuranceSpecification {
        let query = OctopusGraphQL.TravelCertificateQuery()
        do {
            let data = try await octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
            let email = data.currentMember.email
            let specification = TravelInsuranceSpecification(
                data.currentMember,
                email: email
            )
            return specification
        } catch let ex {
            throw ex
        }
    }

    public func submitForm(dto: TravenInsuranceFormDTO) async throws -> URL {
        let input = dto.asOctopusInput
        let mutation = OctopusGraphQL.CreateTravelCertificateMutation(input: input)
        do {
            async let data = try await self.octopus.client.perform(mutation: mutation)
            async let sleepTask: () = Task.sleep(nanoseconds: 1_500_000_000)

            let response = try await [data, sleepTask] as [Any]

            if let mutationResposne = response[0] as? OctopusGraphQL.CreateTravelCertificateMutation.Data,
                let url = URL(string: mutationResposne.travelCertificateCreate.signedUrl)
            {
                return url
            }
            throw TravelInsuranceError.missingURL

        } catch let ex {
            throw ex
        }
    }

    public func getList() async throws -> [TravelCertificateModel] {
        do {
            let query = OctopusGraphQL.TravelCertificatesQuery()
            let data = try await self.octopus.client.fetch(query: query, cachePolicy: .fetchIgnoringCacheCompletely)
            return data.currentMember.travelCertificates.compactMap({
                TravelCertificateModel.init($0)
            })
        } catch let ex {
            throw ex
        }
    }

}

extension TravenInsuranceFormDTO {
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

extension TravelInsuranceSpecification {
    public init(
        _ data: OctopusGraphQL.TravelCertificateQuery.Data.CurrentMember,
        email: String
    ) {
        self.email = email
        self.fullName = data.firstName + " " + data.lastName
        travelCertificateSpecifications = data.travelCertificateSpecifications.contractSpecifications.map({
            TravelInsuranceContractSpecification($0)
        })
    }
}

extension TravelInsuranceContractSpecification {
    init(
        _ data: OctopusGraphQL.TravelCertificateQuery.Data.CurrentMember.TravelCertificateSpecifications
            .ContractSpecification
    ) {
        self.contractId = data.contractId
        self.minStartDate = data.minStartDate.localDateToDate ?? Date()
        self.maxStartDate = data.maxStartDate.localDateToDate ?? Date().addingTimeInterval(60 * 60 * 24 * 90)
        self.numberOfCoInsured = data.numberOfCoInsured
        self.maxDuration = data.maxDurationDays
        self.street = data.location?.street ?? ""

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
