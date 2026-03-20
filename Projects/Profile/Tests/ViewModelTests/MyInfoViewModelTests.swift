import Home
import PresentableStore
@preconcurrency import XCTest
import hCore

@testable import Profile

private let phone = "0123456789"
private let email = "test@email.com"

@MainActor
final class MyInfoViewModelTests: XCTestCase {
    weak var sut: MockProfileService?
    weak var store: ProfileStore?

    override func setUp() async throws {
        try await super.setUp()
        globalPresentableStoreContainer.deletePersistanceContainer()
        Dependencies.shared.add(module: Module { () -> HomeClient in HomeClientDemo() })
        sut = nil
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: ProfileClient.self)
        Dependencies.shared.remove(for: HomeClient.self)
        try await Task.sleep(seconds: 0.0000001)
        XCTAssertNil(sut)
    }

    // MARK: - Helpers
    private func setUpMockService(
        memberUpdate: @escaping MemberUpdate = { email, phone in (email, phone) }
    ) -> MockProfileService {
        let service = MockData.createMockProfileService(memberUpdate: memberUpdate)
        sut = service
        return service
    }

    private func setUpStore(
        phone: String = phone,
        email: String = email
    ) async -> ProfileStore {
        let store = ProfileStore()
        globalPresentableStoreContainer.initialize(store)
        self.store = store
        await store.sendAsync(
            .setMemberDetails(
                details: .init(
                    id: "memberId",
                    firstName: "first name",
                    lastName: "last name",
                    phone: phone,
                    email: email,
                    hasTravelCertificate: true,
                    isContactInfoUpdateNeeded: false
                )
            )
        )
        return store
    }

    // MARK: - Phone Update Success

    func testSave_withValidPhone_updatesStoreAndSucceeds() async throws {
        let mockService = setUpMockService()
        let store = await setUpStore(phone: "000000")

        let model = MyInfoViewModel()
        let newPhone = "111111"
        model.currentPhoneInput = newPhone

        let success = await model.save()
        await delay(0.1)

        XCTAssertTrue(success)
        XCTAssertEqual(store.state.memberDetails?.phone, newPhone)
        XCTAssertEqual(store.state.memberDetails?.email, email)
        XCTAssertNil(model.phoneError)
        XCTAssertNil(model.emailError)
        XCTAssertTrue(mockService.events.contains(.memberUpdate))
    }

    // MARK: - Phone Update Failures

    func testSave_withEmptyPhone_failsWithPhoneEmptyError() async throws {
        let mockService = setUpMockService()
        let store = await setUpStore()

        let model = MyInfoViewModel()
        model.currentPhoneInput = ""
        let success = await model.save()

        XCTAssertFalse(success)
        XCTAssertEqual(model.phoneError, MyInfoSaveError.phoneNumberEmpty.localizedDescription)
        XCTAssertNil(model.emailError)
        XCTAssertFalse(mockService.events.contains(.memberUpdate))
        XCTAssertEqual(store.state.memberDetails?.phone, phone)
    }

    // MARK: - Email Update Success

    func testSave_withValidEmail_updatesStoreAndSucceeds() async throws {
        let mockService = setUpMockService()
        let store = await setUpStore(email: "old@email.com")

        let model = MyInfoViewModel()
        let newEmail = "newemail@email.com"
        model.currentEmailInput = newEmail

        let success = await model.save()
        await delay(0.1)

        XCTAssertTrue(success)
        XCTAssertEqual(store.state.memberDetails?.email, newEmail)
        XCTAssertEqual(store.state.memberDetails?.phone, phone)
        XCTAssertNil(model.phoneError)
        XCTAssertNil(model.emailError)
        XCTAssertTrue(mockService.events.contains(.memberUpdate))
    }

    // MARK: - Email Update Failures

    func testSave_withEmptyEmail_failsWithEmailEmptyError() async throws {
        let mockService = setUpMockService()
        let store = await setUpStore()

        let model = MyInfoViewModel()
        model.currentEmailInput = ""
        let success = await model.save()

        XCTAssertFalse(success)
        XCTAssertEqual(model.emailError, MyInfoSaveError.emailEmpty.localizedDescription)
        XCTAssertNil(model.phoneError)
        XCTAssertFalse(mockService.events.contains(.memberUpdate))
        XCTAssertEqual(store.state.memberDetails?.email, email)
    }

    func testSave_withMalformedEmail_failsWithEmailMalformedError() async throws {
        let mockService = setUpMockService()
        let store = await setUpStore()

        let model = MyInfoViewModel()
        let malformedEmail = "email@email"
        model.currentEmailInput = malformedEmail
        let success = await model.save()

        XCTAssertFalse(success)
        XCTAssertEqual(model.emailError, MyInfoSaveError.emailMalformed.localizedDescription)
        XCTAssertNil(model.phoneError)
        XCTAssertFalse(mockService.events.contains(.memberUpdate))
        XCTAssertEqual(store.state.memberDetails?.email, email)
    }

    // MARK: - API Failure

    func testSave_whenAPIThrows_failsWithErrorMessage() async throws {
        let mockService = setUpMockService(
            memberUpdate: { _, _ in
                throw MyInfoSaveError.error(message: "Network error")
            }
        )
        let store = await setUpStore()

        let model = MyInfoViewModel()
        model.currentEmailInput = "valid@email.com"
        let success = await model.save()

        XCTAssertFalse(success)
        XCTAssertTrue(mockService.events.contains(.memberUpdate))
        XCTAssertEqual(store.state.memberDetails?.phone, phone)
        XCTAssertEqual(store.state.memberDetails?.email, email)
    }
}
