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
            emailPhoneUpdate: { (email, phoneNumber) in
                return (email, phoneNumber)
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
                    hasTravelCertificate: true,
                    isContactInfoUpdateNeeded: false
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
        let mockPhoneNumber = ""
        let mockEmail = "email@email.com"

        let mockService = MockData.createMockProfileService(
            emailPhoneUpdate: { (email, phoneNumber) in
                return (email, phoneNumber)
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
                    email: mockEmail,
                    hasTravelCertificate: true,
                    isContactInfoUpdateNeeded: false
                )
            )
        )

        await store.sendAsync(.setMemberPhone(phone: mockPhoneNumber))

        let model = MyInfoViewModel()
        model.currentPhoneInput = mockPhoneNumber
        model.currentEmailInput = mockEmail
        await model.save()
        assert(model.phoneError == MyInfoSaveError.phoneNumberEmpty.localizedDescription)
    }

    func testEmailUpdateSuccess() async throws {
        let mockEmail = "email@email.com"

        let mockService = MockData.createMockProfileService(
            emailPhoneUpdate: { (email, phoneNumber) in
                return (email, phoneNumber)
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
                    hasTravelCertificate: true,
                    isContactInfoUpdateNeeded: false
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
        let mockEmail = "email@email"
        let mockPhone = "email@email"

        let mockService = MockData.createMockProfileService(
            emailPhoneUpdate: { (email, phone) in
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
                    phone: mockPhone,
                    email: mockEmail,
                    hasTravelCertificate: true,
                    isContactInfoUpdateNeeded: false
                )
            )
        )
        assert(store.state.memberDetails?.email == mockEmail)
        let model = MyInfoViewModel()
        model.currentEmailInput = mockEmail
        model.currentPhoneInput = mockPhone
        await model.save()
        assert(model.emailError == MyInfoSaveError.emailMalformed.localizedDescription)
    }
}
