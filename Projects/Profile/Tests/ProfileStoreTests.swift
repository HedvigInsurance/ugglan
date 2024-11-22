import PresentableStore
@preconcurrency import XCTest

@testable import Profile
@testable import hCore

@MainActor
final class ProfileStoreTests: XCTestCase {
    weak var store: ProfileStore?

    override func setUp() async throws {
        try await super.setUp()
        globalPresentableStoreContainer.deletePersistanceContainer()
    }

    override func tearDown() async throws {
        try await super.tearDown()
        assert(store == nil)
    }

    func testFetchProfileSuccess() async throws {
        let memberData: MemberDetails = .init(
            id: "id",
            firstName: "first name",
            lastName: "last name",
            phone: "phone",
            email: "email",
            hasTravelCertificate: true
        )
        let partnerData: PartnerData = .init(sas: nil)

        let mockService = MockData.createMockProfileService(
            fetchProfileState: { (memberData, partnerData) }
        )

        let store = ProfileStore()
        self.store = store
        await store.sendAsync(.fetchProfileState)
        assert(store.loadingState[.fetchProfileState] == nil)
        try await Task.sleep(nanoseconds: 30_000_000)

        assert(store.state.memberDetails == memberData)
        assert(store.state.partnerData == partnerData)
        assert(store.state.hasTravelCertificates == memberData.isTravelCertificateEnabled)

        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getProfileState)
    }

    func testFetchProfileFailure() async throws {
        let mockService = MockData.createMockProfileService(
            fetchProfileState: { throw ProfileError.error(message: "error") }
        )

        let store = ProfileStore()
        self.store = store
        await store.sendAsync(.fetchProfileState)
        assert(store.loadingState[.fetchProfileState] != nil)
        assert(store.state.memberDetails == nil)
        assert(store.state.partnerData == nil)
        assert(store.state.hasTravelCertificates == false)

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
            hasTravelCertificate: true
        )

        let mockService = MockData.createMockProfileService(
            fetchMemberDetails: { memberData }
        )

        let store = ProfileStore()
        self.store = store
        await store.sendAsync(.fetchMemberDetails)
        try await Task.sleep(nanoseconds: 100_000_000)
        assert(store.loadingState[.fetchMemberDetails] == nil)
        assert(store.state.memberDetails == memberData)
        assert(store.state.hasTravelCertificates == false)

        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getMemberDetails)
    }

    func testFetchMemberDetailsFailure() async throws {
        let mockService = MockData.createMockProfileService(
            fetchMemberDetails: { throw ProfileError.error(message: "error") }
        )

        let store = ProfileStore()
        self.store = store
        await store.sendAsync(.fetchMemberDetails)
        try await Task.sleep(nanoseconds: 30_000_000)
        assert(store.loadingState[.fetchMemberDetails] != nil)
        assert(store.state.memberDetails == nil)
        assert(store.state.hasTravelCertificates == false)

        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getMemberDetails)
    }

    func testUpdateLanguageSuccess() async throws {
        let locale: Localization.Locale = .sv_SE
        Localization.Locale.currentLocale = .init(locale)

        let mockService = MockData.createMockProfileService(
            languageUpdate: {}
        )

        let store = ProfileStore()
        self.store = store
        await store.sendAsync(.updateLanguage)
        try await Task.sleep(nanoseconds: 30_000_000)
        assert(store.loadingState[.updateLanguage] == nil)
        assert(Localization.Locale.currentLocale.value == .init(locale))

        assert(mockService.events.count == 1)
        assert(mockService.events.first == .updateLanguage)
    }

    func testUpdateLanguageFailure() async throws {
        let locale: Localization.Locale = .sv_SE
        Localization.Locale.currentLocale = .init(locale)

        let mockService = MockData.createMockProfileService(
            languageUpdate: { throw ProfileError.error(message: "error") }
        )

        let store = ProfileStore()
        self.store = store
        await store.sendAsync(.updateLanguage)
        assert(store.loadingState[.updateLanguage] != nil)
        assert(Localization.Locale.currentLocale.value == .init(locale))

        assert(mockService.events.count == 1)
        assert(mockService.events.first == .updateLanguage)
    }
}

extension XCTestCase {
    public func waitUntil(description: String, closure: @escaping () -> Bool) async throws {
        let exc = expectation(description: description)
        if closure() {
            exc.fulfill()
        } else {
            try! await Task.sleep(nanoseconds: 100_000_000)
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
