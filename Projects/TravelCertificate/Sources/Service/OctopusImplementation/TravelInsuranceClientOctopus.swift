import Addons
import Foundation
import hCore
import hGraphQL

@MainActor
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

    public func getList() async throws -> (
        list: [TravelCertificateModel], canAddTravelInsurance: Bool, banner: AddonBannerModel?
    ) {
        log.info("TravelInsuranceService: getList", error: nil, attributes: nil)
        return try await service.getList()
    }
}

@MainActor
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

    @MainActor
    public func submitForm(dto: TravelInsuranceFormDTO) async throws -> URL {
        let input = dto.asOctopusInput
        let mutation = OctopusGraphQL.CreateTravelCertificateMutation(input: input)
        do {

            let delayTask = Task {
                try await Task.sleep(nanoseconds: 3_000_000_000)
            }
            let data = try await octopus.client.perform(mutation: mutation)
            try await delayTask.value

            if let url = URL(string: data.travelCertificateCreate.signedUrl) {
                return url
            }
            throw TravelInsuranceError.missingURL

        } catch let ex {
            throw ex
        }
    }

    public func getList() async throws -> (
        list: [TravelCertificateModel], canAddTravelInsurance: Bool, banner: AddonBannerModel?
    ) {
        let query = OctopusGraphQL.TravelCertificatesQuery()
        do {
            let data = try await self.octopus.client.fetch(
                query: query,
                cachePolicy: .fetchIgnoringCacheCompletely
            )
            let listData = data.currentMember.travelCertificates.compactMap({
                TravelCertificateModel.init($0)
            })
            let canAddTravelInsuranceData = !data.currentMember.activeContracts
                .filter({ $0.supportsTravelCertificate }).isEmpty

            /* TODO: REPLACE WITH REAL DATA */
            let addonBannerModelData: AddonBannerModel? = {
                let data = AddonBannerModel(
                    contractIds: [],
                    titleDisplayName: "Travel Plus",
                    descriptionDisplayName:
                        "Extended travel insurance with extra coverage for your travels",
                    badges: ["Popular"]
                )
                if !data.contractIds.isEmpty {
                    return data
                }
                return nil
            }()

            return (listData, canAddTravelInsuranceData, addonBannerModelData)
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
