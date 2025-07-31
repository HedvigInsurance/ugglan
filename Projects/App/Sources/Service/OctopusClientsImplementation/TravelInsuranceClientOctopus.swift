import Addons
import Foundation
import TravelCertificate
import hCore
import hGraphQL

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
            let activeContracts = data.currentMember.activeContracts

            let specification = data.currentMember.travelCertificateSpecifications.contractSpecifications.compactMap {
                data in
                TravelInsuranceContractSpecification(
                    data,
                    email: email,
                    fullName: fullName,
                    displayName: activeContracts.first(where: { $0.id == data.contractId })?.currentAgreement
                        .productVariant.displayName ?? "",
                    exposureDisplayName: activeContracts.first(where: { $0.id == data.contractId })?.exposureDisplayName
                        ?? ""
                )
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

    public func getList(
        source: AddonSource
    ) async throws -> (
        list: [TravelCertificateModel], canAddTravelInsurance: Bool, banner: AddonBannerModel?
    ) {
        let query = OctopusGraphQL.TravelCertificatesQuery()
        do {
            let data = try await octopus.client.fetch(
                query: query,
                cachePolicy: .fetchIgnoringCacheCompletely
            )
            let listData = data.currentMember.travelCertificates.compactMap {
                TravelCertificateModel($0)
            }
            let canAddTravelInsuranceData = !data.currentMember.activeContracts
                .filter(\.supportsTravelCertificate).isEmpty

            let query = OctopusGraphQL.UpsellTravelAddonBannerTravelQuery(flow: .case(source.getSource))
            let bannerResponse = try await octopus.client.fetch(
                query: query,
                cachePolicy: .fetchIgnoringCacheCompletely
            )
            let bannerData = bannerResponse.currentMember.upsellTravelAddonBanner

            let addonBannerModelData: AddonBannerModel? = {
                if let bannerData, !bannerData.contractIds.isEmpty {
                    return AddonBannerModel(
                        contractIds: bannerData.contractIds,
                        titleDisplayName: bannerData.titleDisplayName,
                        descriptionDisplayName: bannerData.descriptionDisplayName,
                        badges: bannerData.badges
                    )
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
        .init(
            contractId: contractId,
            startDate: startDate,
            isMemberIncluded: isMemberIncluded,
            coInsured: coInsured.compactMap {
                .init(
                    fullName: $0.fullName,
                    ssn: GraphQLNullable(optionalValue: $0.personalNumber),
                    dateOfBirth: GraphQLNullable(optionalValue: $0.birthDate)
                )
            },
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
        fullName: String,
        displayName: String,
        exposureDisplayName: String
    ) {
        self.init(
            contractId: data.contractId,
            displayName: displayName,
            exposureDisplayName: exposureDisplayName,
            minStartDate: data.minStartDate.localDateToDate ?? Date(),
            maxStartDate: data.maxStartDate.localDateToDate ?? Date().addingTimeInterval(60 * 60 * 24 * 90),
            numberOfCoInsured: data.numberOfCoInsured,
            maxDuration: data.maxDurationDays,
            email: email,
            fullName: fullName
        )
    }
}

extension TravelCertificateModel {
    init?(_ data: OctopusGraphQL.TravelCertificatesQuery.Data.CurrentMember.TravelCertificate) {
        guard let url = URL(string: data.signedUrl) else { return nil }
        self.init(
            id: data.id,
            date: data.startDate.localDateToDate ?? Date(),
            valid: (data.expiryDate.localDateToDate ?? Date()) > Date(),
            url: url
        )
    }
}
