import Foundation
import hCore
import hGraphQL

public class ProfileServiceOctopus: ProfileService {
    @Inject var octopus: hOctopus

    public init() {}

    public func getProfileState() async throws -> (memberData: MemberDetails, partnerData: PartnerData?) {
        let data = try await self.octopus.client
            .fetch(
                query: OctopusGraphQL.ProfileQuery(),
                cachePolicy: .fetchIgnoringCacheCompletely
            )

        let currentMember = data.currentMember
        let memberData =
            MemberDetails(
                id: currentMember.id,
                firstName: currentMember.firstName,
                lastName: currentMember.lastName,
                phone: currentMember.phoneNumber ?? "",
                email: currentMember.email,
                hasTravelCertificate: !currentMember.travelCertificates.isEmpty
            )

        let partner = PartnerData(with: data.currentMember.fragments.partnerDataFragment)
        return (memberData, partner)
    }

    public func getMemberDetails() async throws -> MemberDetails {
        let query = OctopusGraphQL.MemberDetailsQuery()
        let data = try await self.octopus.client
            .fetch(
                query: query,
                cachePolicy: .fetchIgnoringCacheCompletely
            )

        if let memberData = MemberDetails(memberData: data.currentMember) {
            return memberData
        }
        throw ProfileError.error(message: L10n.General.errorBody)
    }

    public func updateLanguage() async throws {
        let locale = Localization.Locale.currentLocale
        let mutation = OctopusGraphQL.MemberUpdateLanguageMutation(input: .init(ietfLanguageTag: locale.lprojCode))
        do {
            _ = try await self.octopus.client.perform(
                mutation: mutation
            )
        } catch let error {
            log.warn("Failed updating language", error: error)
            throw error
        }
    }
}

enum ProfileError: Error {
    case error(message: String)
}

extension ProfileError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .error(message): return message
        }
    }
}
