import Presentation
import XCTest

@testable import Profile
@testable import hCore

final class ProfileStoreTests: XCTestCase {
    weak var store: ProfileStore?

    override func setUp() {
        super.setUp()
        globalPresentableStoreContainer.deletePersistanceContainer()
    }

    override func tearDown() async throws {
        await waitUntil(description: "Store deinited successfully") {
            self.store == nil
        }
    }

    func testFetchProfileSuccess() async {
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
        await waitUntil(description: "loading state") {
            store.loadingSignal.value[.fetchProfileState] == nil
        }
        assert(store.state.memberDetails == memberData)
        assert(store.state.partnerData == partnerData)
        assert(store.state.hasTravelCertificates == memberData.isTravelCertificateEnabled)

        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getProfileState)
    }

    func testFetchProfileFailure() async {
        let mockService = MockData.createMockProfileService(
            fetchProfileState: { throw ProfileError.error(message: "error") }
        )

        let store = ProfileStore()
        self.store = store
        await store.sendAsync(.fetchProfileState)
        await waitUntil(description: "loading state") {
            store.loadingSignal.value[.fetchProfileState] != nil
        }
        assert(store.state.memberDetails == nil)
        assert(store.state.partnerData == nil)
        assert(store.state.hasTravelCertificates == false)

        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getProfileState)
    }

    func testFetchMemberDetailsSuccess() async {
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
        await waitUntil(description: "loading state") {
            store.loadingSignal.value[.fetchMemberDetails] == nil
        }
        assert(store.state.memberDetails == memberData)
        assert(store.state.hasTravelCertificates == false)

        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getMemberDetails)
    }

    func testFetchMemberDetailsFailure() async {
        let mockService = MockData.createMockProfileService(
            fetchMemberDetails: { throw ProfileError.error(message: "error") }
        )

        let store = ProfileStore()
        self.store = store
        await store.sendAsync(.fetchMemberDetails)
        await waitUntil(description: "loading state") {
            store.loadingSignal.value[.fetchMemberDetails] != nil
        }
        assert(store.state.memberDetails == nil)
        assert(store.state.hasTravelCertificates == false)

        assert(mockService.events.count == 1)
        assert(mockService.events.first == .getMemberDetails)
    }

    func testUpdateLanguageSuccess() async {
        let locale: Localization.Locale = .sv_SE
        Localization.Locale.currentLocale = locale

        let mockService = MockData.createMockProfileService(
            languageUpdate: {}
        )

        let store = ProfileStore()
        self.store = store
        await store.sendAsync(.updateLanguage)
        await waitUntil(description: "loading state") {
            store.loadingSignal.value[.updateLanguage] == nil
        }
        assert(Localization.Locale.currentLocale == locale)

        assert(mockService.events.count == 1)
        assert(mockService.events.first == .updateLanguage)
    }

    func testUpdateLanguageFailure() async {
        let locale: Localization.Locale = .sv_SE
        Localization.Locale.currentLocale = locale

        let mockService = MockData.createMockProfileService(
            languageUpdate: { throw ProfileError.error(message: "error") }
        )

        let store = ProfileStore()
        self.store = store
        await store.sendAsync(.updateLanguage)
        await waitUntil(description: "loading state") {
            store.loadingSignal.value[.updateLanguage] != nil
        }
        assert(Localization.Locale.currentLocale == locale)

        assert(mockService.events.count == 1)
        assert(mockService.events.first == .updateLanguage)
    }
}

extension XCTestCase {
    public func waitUntil(description: String, closure: @escaping () -> Bool) async {
        let exc = expectation(description: description)
        if closure() {
            exc.fulfill()
        } else {
            try! await Task.sleep(nanoseconds: 100_000_000)
            Task {
                await self.waitUntil(description: description, closure: closure)
                if closure() {
                    exc.fulfill()
                }
            }
        }
        await fulfillment(of: [exc], timeout: 2)
    }
}
