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
                phone: "0123456789",
                email: "email",
                hasTravelCertificate: true,
                isContactInfoUpdateNeeded: false
            )
            let partnerData: PartnerData = .init(sas: nil)
            return (memberData, partnerData, true, true)
        },
        fetchMemberDetails: @escaping FetchMemberDetails = {
            let memberData: MemberDetails = .init(
                id: "id",
                firstName: "first name",
                lastName: "last name",
                phone: "phone",
                email: "email",
                hasTravelCertificate: true,
                isContactInfoUpdateNeeded: false
            )
            return memberData
        },
        languageUpdate: @escaping LanguageUpdate = {},
        deleteRequest: @escaping DeleteRequest = {},
        memberUpdate: @escaping MemberUpdate = { email, phone in
            (email, phone)
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
            memberUpdate: memberUpdate,
            eurobonusUpdate: eurobonusUpdate,
            subscriptionPreferenceUpdate: subscriptionPreferenceUpdate
        )
        Dependencies.shared.add(module: Module { () -> ProfileClient in service })
        return service
    }
}

typealias FetchProfileState = () async throws -> (
    memberData: MemberDetails, partnerData: PartnerData?, canCreateInsuranceEvidence: Bool, hasTravelInsurances: Bool
)
typealias FetchMemberDetails = () async throws -> MemberDetails
typealias LanguageUpdate = () async throws -> Void
typealias DeleteRequest = () async throws -> Void
typealias MemberUpdate = (String, String) async throws -> (email: String, phone: String)
typealias EurobonusUpdate = (String) async throws -> PartnerData
typealias SubscriptionPreferenceUpdate = (Bool) async throws -> Void

class MockProfileService: ProfileClient {
    var events = [Event]()

    var fetchProfileState: FetchProfileState
    var fetchMemberDetails: FetchMemberDetails
    var languageUpdate: LanguageUpdate
    var deleteRequest: DeleteRequest
    var memberUpdate: MemberUpdate
    var eurobonusUpdate: EurobonusUpdate
    var subscriptionPreferenceUpdate: SubscriptionPreferenceUpdate

    enum Event {
        case getProfileState
        case getMemberDetails
        case updateLanguage
        case postDeleteRequest
        case memberUpdate
        case updateEurobonus
        case updateSubscriptionPreference
    }

    init(
        fetchProfileState: @escaping FetchProfileState,
        fetchMemberDetails: @escaping FetchMemberDetails,
        languageUpdate: @escaping LanguageUpdate,
        deleteRequest: @escaping DeleteRequest,
        memberUpdate: @escaping MemberUpdate,
        eurobonusUpdate: @escaping EurobonusUpdate,
        subscriptionPreferenceUpdate: @escaping SubscriptionPreferenceUpdate
    ) {
        self.fetchProfileState = fetchProfileState
        self.fetchMemberDetails = fetchMemberDetails
        self.languageUpdate = languageUpdate
        self.deleteRequest = deleteRequest
        self.memberUpdate = memberUpdate
        self.eurobonusUpdate = eurobonusUpdate
        self.subscriptionPreferenceUpdate = subscriptionPreferenceUpdate
    }

    func getProfileState() async throws -> (
        memberData: Profile.MemberDetails, partnerData: Profile.PartnerData?, canCreateInsuranceEvidence: Bool,
        hasTravelInsurances: Bool
    ) {
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

    func update(email: String, phone: String) async throws -> (email: String, phone: String) {
        events.append(.memberUpdate)
        let data = try await memberUpdate(email, phone)
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
