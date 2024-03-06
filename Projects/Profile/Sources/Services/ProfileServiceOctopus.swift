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

    //    private func getPhoneFuture() -> Flow.Future<Void> {
    //        return Flow.Future<Void> { [weak self] completion in
    //            guard let self else { return NilDisposer() }
    //            if originalEmail != phone {
    //                if phone.isEmpty {
    //                    completion(.failure(MyInfoSaveError.phoneNumberEmpty))
    //                    return NilDisposer()
    //                }
    //                let innerBag = bag.innerBag()
    //
    //                innerBag += self.octopus.client
    //                    .perform(
    //                        mutation: OctopusGraphQL.MemberUpdatePhoneNumberMutation(
    //                            input: OctopusGraphQL.MemberUpdatePhoneNumberInput(phoneNumber: phone)
    //                        )
    //                    )
    //                    .onValue { [weak self] data in
    //                        if let phoneNumber = data.memberUpdatePhoneNumber.member?.phoneNumber {
    //                            self?.originalPhone = phoneNumber
    //                            self?.store.send(.setMemberPhone(phone: phoneNumber))
    //                        }
    //                        completion(.success)
    //                    }
    //                    .onError { error in
    //                        completion(.failure(MyInfoSaveError.phoneNumberMalformed))
    //                    }
    //
    //                return innerBag
    //            }
    //            completion(.success)
    //            return NilDisposer()
    //        }
    //    }
    //
    //    private func getEmailFuture() -> Flow.Future<Void> {
    //        return Flow.Future<Void> { [weak self] completion in
    //            guard let self else { return NilDisposer() }
    //            if originalEmail != email {
    //                if email.isEmpty {
    //                    completion(.failure(MyInfoSaveError.emailEmpty))
    //                    return NilDisposer()
    //                }
    //                if !Masking(type: .email).isValid(text: email) {
    //                    completion(.failure(MyInfoSaveError.emailMalformed))
    //                    return NilDisposer()
    //                }
    //                let innerBag = bag.innerBag()
    //
    //                innerBag += self.octopus.client
    //                    .perform(
    //                        mutation: OctopusGraphQL.MemberUpdateEmailMutation(
    //                            input: OctopusGraphQL.MemberUpdateEmailInput(email: email)
    //                        )
    //                    )
    //                    .onValue { [weak self] data in
    //                        if let email = data.memberUpdateEmail.member?.email {
    //                            self?.originalEmail = email
    //                            self?.store.send(.setMemberEmail(email: email))
    //                        }
    //                        completion(.success)
    //
    //                    }
    //                    .onError { _ in
    //                        completion(.failure(MyInfoSaveError.emailMalformed))
    //
    //                    }
    //                return innerBag
    //            }
    //            completion(.success)
    //            return NilDisposer()
    //        }
    //    }
}
