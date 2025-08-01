import hCore
import hGraphQL
import Profile

class ProfileClientOctopus: ProfileClient {
    @Inject var octopus: hOctopus

    func getProfileState() async throws -> (
        memberData: MemberDetails, partnerData: PartnerData?, canCreateInsuranceEvidence: Bool,
        hasTravelInsurances: Bool
    ) {
        let data = try await octopus.client
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
                hasTravelCertificate: currentMember.memberActions?.isTravelCertificateEnabled ?? false,
                isContactInfoUpdateNeeded: currentMember.memberActions?.isContactInfoUpdateNeeded ?? false
            )

        let hasTravelInsurances = !currentMember.travelCertificates.isEmpty

        let partner = PartnerData(with: data.currentMember.fragments.partnerDataFragment)
        return (
            memberData, partner, currentMember.memberActions?.isCreatingOfInsuranceEvidenceEnabled ?? false,
            hasTravelInsurances
        )
    }

    func getMemberDetails() async throws -> MemberDetails {
        let query = OctopusGraphQL.MemberDetailsQuery()
        let data = try await octopus.client
            .fetch(
                query: query,
                cachePolicy: .fetchIgnoringCacheCompletely
            )

        if let memberData = MemberDetails(memberData: data.currentMember) {
            return memberData
        }
        throw ProfileError.error(message: L10n.General.errorBody)
    }

    func updateLanguage() async throws {
        let locale = Localization.Locale.currentLocale.value
        let mutation = OctopusGraphQL.MemberUpdateLanguageMutation(input: .init(ietfLanguageTag: locale.lprojCode))
        do {
            _ = try await octopus.client.perform(
                mutation: mutation
            )
        } catch {
            log.warn("Failed updating language", error: error)
            throw error
        }
    }

    func postDeleteRequest() async throws {
        _ = try await octopus.client.perform(mutation: OctopusGraphQL.MemberDeletionRequestMutation())
    }

    func update(email: String, phone: String) async throws -> (email: String, phone: String) {
        let input = OctopusGraphQL.MemberUpdateContactInfoInput(phoneNumber: phone, email: email)
        let mutation = OctopusGraphQL.MemberUpdateContactInfoMutation(input: input)
        let data = try await octopus.client.perform(mutation: mutation)

        if let userError = data.memberUpdateContactInfo.userError?.message {
            throw ProfileError.error(message: userError)
        }

        if let email = data.memberUpdateContactInfo.member?.email,
           let phone = data.memberUpdateContactInfo.member?.phoneNumber
        {
            return (email, phone)
        }

        throw ProfileError.error(message: L10n.General.errorBody)
    }

    func update(eurobonus: String) async throws -> PartnerData {
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

    func updateSubscriptionPreference(to subscribed: Bool) async throws {
        let mutation = OctopusGraphQL.MemberUpdateSubscriptionPreferenceMutation(
            subscribe: GraphQLNullable(booleanLiteral: subscribed)
        )
        let data = try await octopus.client.perform(mutation: mutation)
        if data.memberUpdateSubscriptionPreference?.message != nil {
            throw ProfileError.error(message: L10n.General.errorBody)
        }
    }
}

private extension PartnerData {
    init?(with data: OctopusGraphQL.PartnerDataFragment) {
        guard let sasData = data.partnerData?.sas else { return nil }
        self.init(sas: .init(eligible: sasData.eligible, eurobonusNumber: sasData.eurobonusNumber))
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
            hasTravelCertificate: false,
            isContactInfoUpdateNeeded: false
        )
    }
}
