import AppStateContainer
import XCTest

@testable import Profile
@testable import hCore

@MainActor
final class ProfileStoreTests: XCTestCase {
    weak var store: ProfileStore?

    override func setUp() async throws {
        try await super.setUp()
        globalAppStateContainer.clearPersistence()
    }

    override func tearDown() async throws {
        try await super.tearDown()
        try await waitUntil(description: "deinitStore") {
            self.store == nil
        }
    }

    func testFetchProfileSuccess() async throws {
        let memberData: MemberDetails = .init(
            id: "id",
            firstName: "first name",
            lastName: "last name",
            phone: "phone",
            email: "email",
            hasTravelCertificate: true,
            isContactInfoUpdateNeeded: false
        )
        let partnerData: PartnerData = .init(sas: nil)

        let mockService = MockData.createMockProfileService(
            fetchProfileState: {
                (memberData, partnerData, canCreateInsuranceEvidence: true, hasTravelInsurances: true)
            }
        )

        let store = ProfileStore()
        self.store = store
        await store.fetchProfileState()
        assert(store.fetchProfileStateError == nil)
        try await waitUntil(description: "check state") {
            store.memberDetails == memberData && store.partnerData == partnerData
                && store.hasTravelCertificates == memberData.isTravelCertificateEnabled
                && mockService.events.count == 1 && mockService.events.first == .getProfileState
        }
    }

    func testFetchProfileFailure() async throws {
        let mockService = MockData.createMockProfileService(
            fetchProfileState: { throw ProfileError.error(message: "error") }
        )

        let store = ProfileStore()
        self.store = store
        await store.fetchProfileState()
        assert(store.fetchProfileStateError != nil)
        assert(store.memberDetails == nil)
        assert(store.partnerData == nil)
        assert(store.hasTravelCertificates == false)

        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getProfileState)
    }

    func testFetchMemberDetailsSuccess() async throws {
        let memberData: MemberDetails = .init(
            id: "id",
            firstName: "first name",
            lastName: "last name",
            phone: "phone",
            email: "email",
            hasTravelCertificate: true,
            isContactInfoUpdateNeeded: false
        )

        let mockService = MockData.createMockProfileService(
            fetchMemberDetails: { memberData }
        )

        let store = ProfileStore()
        self.store = store
        await store.fetchMemberDetails()

        try await waitUntil(description: "check state") {
            store.fetchMemberDetailsError == nil && store.memberDetails == memberData
                && store.hasTravelCertificates == false && mockService.events.count == 1
                && mockService.events.first == .getMemberDetails
        }
    }

    func testFetchMemberDetailsFailure() async throws {
        let mockService = MockData.createMockProfileService(
            fetchMemberDetails: { throw ProfileError.error(message: "error") }
        )

        let store = ProfileStore()
        self.store = store
        await store.fetchMemberDetails()
        try await waitUntil(description: "check state") {
            store.fetchMemberDetailsError != nil && store.memberDetails == nil
                && store.hasTravelCertificates == false && mockService.events.count == 1
                && mockService.events.first == .getMemberDetails
        }
    }

    func testUpdateLanguageSuccess() async throws {
        let locale: Localization.Locale = .sv_SE
        Localization.Locale.currentLocale = .init(locale)

        let mockService = MockData.createMockProfileService(
            languageUpdate: {}
        )

        let store = ProfileStore()
        self.store = store
        await store.updateLanguage()
        try await waitUntil(description: "check state") {
            store.updateLanguageError == nil && Localization.Locale.currentLocale.value == .init(locale)
                && mockService.events.count == 1 && mockService.events.first == .updateLanguage
        }
    }

    func testUpdateLanguageFailure() async throws {
        let locale: Localization.Locale = .sv_SE
        Localization.Locale.currentLocale = .init(locale)

        let mockService = MockData.createMockProfileService(
            languageUpdate: { throw ProfileError.error(message: "error") }
        )

        let store = ProfileStore()
        self.store = store
        await store.updateLanguage()
        assert(store.updateLanguageError != nil)
        assert(Localization.Locale.currentLocale.value == .init(locale))

        assert(mockService.events.count == 1)
        assert(mockService.events.first == .updateLanguage)
    }
}

@MainActor
extension XCTestCase {
    public func waitUntil(description: String, closure: @escaping () -> Bool) async throws {
        let exc = expectation(description: description)
        if closure() {
            exc.fulfill()
        } else {
            try! await Task.sleep(seconds: 0.1)
            Task {
                try await self.waitUntil(description: description, closure: closure)
                if closure() {
                    exc.fulfill()
                }
            }
        }
        await fulfillment(of: [exc], timeout: 2)
    }
}
