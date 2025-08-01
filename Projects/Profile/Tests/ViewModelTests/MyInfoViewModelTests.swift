import hCore
import PresentableStore
@preconcurrency import XCTest

@testable import Profile

@MainActor
final class MyInfoViewModelTests: XCTestCase {
    weak var sut: MockProfileService?
    weak var store: ProfileStore?

    override func setUp() async throws {
        try await super.setUp()
        globalPresentableStoreContainer.deletePersistanceContainer()
        sut = nil
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: ProfileClient.self)
        try await Task.sleep(nanoseconds: 100)
        XCTAssertNil(sut)
    }

    func testPhoneUpdateSuccess() async throws {
        let mockPhoneNumber = "111111"

        let mockService = MockData.createMockProfileService(
            phoneUpdate: { phoneNumber in
                phoneNumber
            }
        )

        sut = mockService

        let store = ProfileStore()
        self.store = store

        await store.sendAsync(
            .setMemberDetails(
                details: .init(
                    id: "memberId",
                    firstName: "first name",
                    lastName: "last name",
                    phone: mockPhoneNumber,
                    email: "",
                    hasTravelCertificate: true
                )
            )
        )

        await store.sendAsync(.setMemberPhone(phone: mockPhoneNumber))

        let model = MyInfoViewModel()
        model.currentPhoneInput = mockPhoneNumber
        await model.save()
        assert(model.currentPhoneInput == mockPhoneNumber)
    }

    func testPhoneUpdateFailure() async throws {
        let mockPhoneNumber = "111111"

        let mockService = MockData.createMockProfileService(
            phoneUpdate: { _ in
                throw MyInfoSaveError.phoneNumberMalformed
            }
        )

        sut = mockService

        let store = ProfileStore()
        self.store = store
        await store.sendAsync(
            .setMemberDetails(
                details: .init(
                    id: "memberId",
                    firstName: "first name",
                    lastName: "last name",
                    phone: mockPhoneNumber,
                    email: "",
                    hasTravelCertificate: true
                )
            )
        )

        await store.sendAsync(.setMemberPhone(phone: mockPhoneNumber))

        let model = MyInfoViewModel()
        model.currentPhoneInput = mockPhoneNumber
        await model.save()
        assert(model.phoneError == MyInfoSaveError.phoneNumberMalformed.localizedDescription)
    }

    func testEmailUpdateSuccess() async throws {
        let mockEmail = "email@email.com"

        let mockService = MockData.createMockProfileService(
            emailUpdate: { email in
                email
            }
        )

        sut = mockService

        let store = ProfileStore()
        self.store = store

        await store.sendAsync(
            .setMemberDetails(
                details: .init(
                    id: "memberId",
                    firstName: "first name",
                    lastName: "last name",
                    phone: "",
                    email: mockEmail,
                    hasTravelCertificate: true
                )
            )
        )
        await store.sendAsync(.setMemberEmail(email: mockEmail))

        let model = MyInfoViewModel()
        model.currentEmailInput = mockEmail
        await model.save()
        assert(model.currentEmailInput == mockEmail)
    }

    func testEmailUpdateFailure() async throws {
        let mockEmail = "email@email.com"
        let mockService = MockData.createMockProfileService(
            emailUpdate: { _ in
                throw MyInfoSaveError.emailEmpty
            }
        )

        sut = mockService

        let store = ProfileStore()
        self.store = store
        await store.sendAsync(
            .setMemberDetails(
                details: .init(
                    id: "memberId",
                    firstName: "first name",
                    lastName: "last name",
                    phone: "",
                    email: mockEmail,
                    hasTravelCertificate: true
                )
            )
        )
        assert(store.state.memberDetails?.email == mockEmail)
        let model = MyInfoViewModel()
        model.currentEmailInput = mockEmail
        await model.save()
        assert(model.emailError == MyInfoSaveError.emailMalformed.localizedDescription)
    }
}
