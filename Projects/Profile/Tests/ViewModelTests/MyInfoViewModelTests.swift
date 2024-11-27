import PresentableStore
@preconcurrency import XCTest
import hCore

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
                return phoneNumber
            }
        )

        self.sut = mockService

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
        model.phone = mockPhoneNumber
        await model.save()
        assert(model.phone == mockPhoneNumber)
    }

    func testPhoneUpdateFailure() async throws {
        let mockPhoneNumber = "111111"

        let mockService = MockData.createMockProfileService(
            phoneUpdate: { phoneNumber in
                throw MyInfoSaveError.phoneNumberMalformed
            }
        )

        self.sut = mockService

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
        model.phone = mockPhoneNumber
        await model.save()
        assert(model.phoneError == MyInfoSaveError.phoneNumberMalformed.localizedDescription)
    }

    func testEmailUpdateSuccess() async throws {
        let mockEmail = "email@email.com"

        let mockService = MockData.createMockProfileService(
            emailUpdate: { email in
                return email
            }
        )

        self.sut = mockService

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
        model.email = mockEmail
        await model.save()
        assert(model.email == mockEmail)
    }

    func testEmailUpdateFailure() async throws {
        let mockEmail = "email@email.com"
        let mockService = MockData.createMockProfileService(
            emailUpdate: { email in
                throw MyInfoSaveError.emailEmpty
            }
        )

        self.sut = mockService

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
        model.email = mockEmail
        await model.save()
        assert(model.emailError == MyInfoSaveError.emailMalformed.localizedDescription)
    }
}
