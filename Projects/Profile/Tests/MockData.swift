import Foundation
import hCore

@testable import Profile

@MainActor
struct MockData {
    static func createMockProfileService(
        fetchProfileState: @escaping FetchProfileState = {
            let memberData: MemberDetails = .init(
                id: "id",
                firstName: "first name",
                lastName: "last name",
                phone: "phone",
                email: "email",
                hasTravelCertificate: true
            )
            let partnerData: PartnerData = .init(sas: nil)
            return (memberData, partnerData)
        },
        fetchMemberDetails: @escaping FetchMemberDetails = {
            let memberData: MemberDetails = .init(
                id: "id",
                firstName: "first name",
                lastName: "last name",
                phone: "phone",
                email: "email",
                hasTravelCertificate: true
            )
            return memberData
        },
        languageUpdate: @escaping LanguageUpdate = {},
        deleteRequest: @escaping DeleteRequest = {},
        emailUpdate: @escaping EmailUpdate = { email in
            email
        },
        phoneUpdate: @escaping PhoneUpdate = { phoneNumber in
            phoneNumber
        },
        eurobonusUpdate: @escaping EurobonusUpdate = { eurobonus in
            let partnerData: PartnerData = .init(sas: .init(eligible: true, eurobonusNumber: eurobonus))
            return partnerData
        },
        subscriptionPreferenceUpdate: @escaping SubscriptionPreferenceUpdate = { _ in }
    ) -> MockProfileService {
        let service = MockProfileService(
            fetchProfileState: fetchProfileState,
            fetchMemberDetails: fetchMemberDetails,
            languageUpdate: languageUpdate,
            deleteRequest: deleteRequest,
            emailUpdate: emailUpdate,
            phoneUpdate: phoneUpdate,
            eurobonusUpdate: eurobonusUpdate,
            subscriptionPreferenceUpdate: subscriptionPreferenceUpdate
        )
        Dependencies.shared.add(module: Module { () -> ProfileClient in service })
        return service
    }
}

typealias FetchProfileState = () async throws -> (memberData: MemberDetails, partnerData: PartnerData?)
typealias FetchMemberDetails = () async throws -> MemberDetails
typealias LanguageUpdate = () async throws -> Void
typealias DeleteRequest = () async throws -> Void
typealias EmailUpdate = (String) async throws -> String
typealias PhoneUpdate = (String) async throws -> String
typealias EurobonusUpdate = (String) async throws -> PartnerData
typealias SubscriptionPreferenceUpdate = (Bool) async throws -> Void

class MockProfileService: ProfileClient {
    var events = [Event]()

    var fetchProfileState: FetchProfileState
    var fetchMemberDetails: FetchMemberDetails
    var languageUpdate: LanguageUpdate
    var deleteRequest: DeleteRequest
    var emailUpdate: EmailUpdate
    var phoneUpdate: PhoneUpdate
    var eurobonusUpdate: EurobonusUpdate
    var subscriptionPreferenceUpdate: SubscriptionPreferenceUpdate

    enum Event {
        case getProfileState
        case getMemberDetails
        case updateLanguage
        case postDeleteRequest
        case updateEmail
        case updatePhone
        case updateEurobonus
        case updateSubscriptionPreference
    }

    init(
        fetchProfileState: @escaping FetchProfileState,
        fetchMemberDetails: @escaping FetchMemberDetails,
        languageUpdate: @escaping LanguageUpdate,
        deleteRequest: @escaping DeleteRequest,
        emailUpdate: @escaping EmailUpdate,
        phoneUpdate: @escaping PhoneUpdate,
        eurobonusUpdate: @escaping EurobonusUpdate,
        subscriptionPreferenceUpdate: @escaping SubscriptionPreferenceUpdate
    ) {
        self.fetchProfileState = fetchProfileState
        self.fetchMemberDetails = fetchMemberDetails
        self.languageUpdate = languageUpdate
        self.deleteRequest = deleteRequest
        self.emailUpdate = emailUpdate
        self.phoneUpdate = phoneUpdate
        self.eurobonusUpdate = eurobonusUpdate
        self.subscriptionPreferenceUpdate = subscriptionPreferenceUpdate
    }

    func getProfileState() async throws -> (memberData: Profile.MemberDetails, partnerData: Profile.PartnerData?) {
        events.append(.getProfileState)
        let data = try await fetchProfileState()
        return data
    }

    func getMemberDetails() async throws -> Profile.MemberDetails {
        events.append(.getMemberDetails)
        let data = try await fetchMemberDetails()
        return data
    }

    func updateLanguage() async throws {
        events.append(.updateLanguage)
        try await languageUpdate()
    }

    func postDeleteRequest() async throws {
        events.append(.postDeleteRequest)
        try await languageUpdate()
    }

    func update(email: String) async throws -> String {
        events.append(.updateEmail)
        let data = try await emailUpdate(email)
        return data
    }

    func update(phone: String) async throws -> String {
        events.append(.updatePhone)
        let data = try await phoneUpdate(phone)
        return data
    }

    func update(eurobonus: String) async throws -> Profile.PartnerData {
        events.append(.updateEurobonus)
        let data = try await eurobonusUpdate(eurobonus)
        return data
    }

    func updateSubscriptionPreference(to subscribed: Bool) async throws {
        events.append(.updateSubscriptionPreference)
        try await subscriptionPreferenceUpdate(subscribed)
    }
}
