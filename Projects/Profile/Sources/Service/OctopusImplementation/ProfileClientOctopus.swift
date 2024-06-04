import Foundation
import hCore
import hGraphQL

public class ProfileService {
    @Inject var service: ProfileClient

    public func getProfileState() async throws -> (memberData: MemberDetails, partnerData: PartnerData?) {
        log.info("ProfileService: getProfileState", error: nil, attributes: nil)
        return try await service.getProfileState()
    }

    public func getMemberDetails() async throws -> MemberDetails {
        log.info("ProfileService: getMemberDetails", error: nil, attributes: nil)
        return try await service.getMemberDetails()
    }

    public func postDeleteRequest() async throws {
        log.info("ProfileService: postDeleteRequest", error: nil, attributes: nil)
        return try await service.postDeleteRequest()
    }

    public func updateLanguage() async throws {
        log.info("ProfileService: updateLanguage", error: nil, attributes: nil)
        return try await service.updateLanguage()
    }

    func update(email: String) async throws -> String {
        log.info("ProfileService: update(email)", error: nil, attributes: nil)
        return try await service.update(email: email)
    }

    func update(phone: String) async throws -> String {
        log.info("ProfileService: update(phone)", error: nil, attributes: nil)
        return try await service.update(phone: phone)
    }

    func update(eurobonus: String) async throws -> PartnerData {
        log.info("ProfileService: update(eurobonus)", error: nil, attributes: nil)
        return try await service.update(eurobonus: eurobonus)
    }

    func updateSubscriptionPreference(to subscribed: Bool) async throws {
        log.info("ProfileService: updateSubscriptionPreference", error: nil, attributes: nil)
        return try await service.updateSubscriptionPreference(to: subscribed)
    }
}

public class ProfileClientOctopus: ProfileClient {
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
                hasTravelCertificate: currentMember.memberActions?.isTravelCertificateEnabled ?? false
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

    public func postDeleteRequest() async throws {
        _ = try await octopus.client.perform(mutation: OctopusGraphQL.MemberDeletionRequestMutation())
    }

    public func update(email: String) async throws -> String {
        let input = OctopusGraphQL.MemberUpdateEmailInput(email: email)
        let mutation = OctopusGraphQL.MemberUpdateEmailMutation(input: input)
        let data = try await octopus.client.perform(mutation: mutation)
        if let email = data.memberUpdateEmail.member?.email {
            return email
        }
        throw ProfileError.error(message: L10n.General.errorBody)
    }
    public func update(phone: String) async throws -> String {
        let input = OctopusGraphQL.MemberUpdatePhoneNumberInput(phoneNumber: phone)
        let mutation = OctopusGraphQL.MemberUpdatePhoneNumberMutation(input: input)
        let data = try await octopus.client.perform(mutation: mutation)
        if let phoneNumber = data.memberUpdatePhoneNumber.member?.phoneNumber {
            return phoneNumber
        }
        throw ProfileError.error(message: L10n.General.errorBody)
    }

    public func update(eurobonus: String) async throws -> PartnerData {
        let input = OctopusGraphQL.MemberUpdateEurobonusNumberInput(eurobonusNumber: eurobonus)
        let mutation = OctopusGraphQL.UpdateEurobonusNumberMutation(input: input)
        let data = try await octopus.client.perform(mutation: mutation)
        if let graphQLError = data.memberUpdateEurobonusNumber.userError?.message, !graphQLError.isEmpty {
            throw ChangeEuroBonusError.error(message: graphQLError)
        }
        guard let dataFragment = data.memberUpdateEurobonusNumber.member?.fragments.partnerDataFragment,
            let partnerData = PartnerData(with: dataFragment)
        else {
            throw ChangeEuroBonusError.error(message: L10n.General.errorBody)
        }
        return partnerData
    }

    public func updateSubscriptionPreference(to subscribed: Bool) async throws {
        let mutation = OctopusGraphQL.MemberUpdateSubscriptionPreferenceMutation(
            subscribe: GraphQLNullable(booleanLiteral: subscribed)
        )
        let data = try await octopus.client.perform(mutation: mutation)
    }

}

extension PartnerData {
    fileprivate init?(with data: OctopusGraphQL.PartnerDataFragment) {
        guard let sasData = data.partnerData?.sas else { return nil }
        self.sas = PartnerDataSas(with: sasData)
    }
}

extension PartnerDataSas {
    fileprivate init(with data: OctopusGraphQL.PartnerDataFragment.PartnerData.Sas) {
        self.eligible = data.eligible
        self.eurobonusNumber = data.eurobonusNumber
    }
}

extension MemberDetails {
    init?(
        memberData: OctopusGraphQL.MemberDetailsQuery.Data.CurrentMember
    ) {
        self.id = memberData.id
        self.email = memberData.email
        self.phone = memberData.phoneNumber
        self.firstName = memberData.firstName
        self.lastName = memberData.lastName
        self.isTravelCertificateEnabled = false
    }
}
