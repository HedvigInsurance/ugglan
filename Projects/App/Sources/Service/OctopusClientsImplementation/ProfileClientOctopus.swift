import Profile
import hCore
import hGraphQL

public class ProfileClientOctopus: ProfileClient {
    @Inject var octopus: hOctopus

    public init() {}

    public func getProfileState() async throws -> (
        memberData: MemberDetails, partnerData: PartnerData?, canCreateInsuranceEvidence: Bool
    ) {
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
        return (memberData, partner, currentMember.memberActions?.isCreatingOfInsuranceEvidenceEnabled ?? false)
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
        let locale = Localization.Locale.currentLocale.value
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
        if data.memberUpdateSubscriptionPreference?.message != nil {
            throw ProfileError.error(message: L10n.General.errorBody)
        }
    }

}

extension PartnerData {
    fileprivate init?(with data: OctopusGraphQL.PartnerDataFragment) {
        guard let sasData = data.partnerData?.sas else { return nil }
        self.init(sas: .init(eligible: sasData.eligible, eurobonusNumber: sasData.eurobonusNumber))
    }
}

extension PartnerDataSas {
    fileprivate init(with data: OctopusGraphQL.PartnerDataFragment.PartnerData.Sas) {
        self.init(eligible: data.eligible, eurobonusNumber: data.eurobonusNumber)
    }
}

extension MemberDetails {
    init?(
        memberData: OctopusGraphQL.MemberDetailsQuery.Data.CurrentMember
    ) {
        self.init(
            id: memberData.id,
            firstName: memberData.firstName,
            lastName: memberData.lastName,
            phone: memberData.phoneNumber,
            email: memberData.email,
            hasTravelCertificate: false
        )
    }
}
