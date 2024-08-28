import Presentation
import XCTest
import hCore

@testable import Profile

final class MyInfoViewModelTests: XCTestCase {
    weak var sut: MockProfileService?
    weak var store: ProfileStore?

    override func setUp() {
        super.setUp()
        sut = nil
        globalPresentableStoreContainer.deletePersistanceContainer()
    }

    override func tearDown() async throws {
        Dependencies.shared.remove(for: ProfileClient.self)
        try await Task.sleep(nanoseconds: 100)
        XCTAssertNil(sut)
        await waitUntil(description: "Store deinited successfully") {
            self.store == nil
        }
    }

    func testPhoneUpdateSuccess() async {
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
        await model.save()

        assert(model.phone == mockPhoneNumber)
    }

    func testPhoneUpdateFailure() async {
        let mockService = MockData.createMockProfileService(
            phoneUpdate: { phoneNumber in
                throw MyInfoSaveError.phoneNumberEmpty
            }
        )

        self.sut = mockService

        let store = ProfileStore()
        self.store = store
        await store.sendAsync(.setMemberPhone(phone: "111111"))

        let model = MyInfoViewModel()
        await model.save()

        assert(model.phoneError == MyInfoSaveError.phoneNumberEmpty.localizedDescription)
    }

    func testEmailUpdateSuccess() async {
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
        await model.save()

        assert(model.email == mockEmail)
    }

    func testEmailUpdateFailure() async {
        let mockEmail = "email@email.com"

        let mockService = MockData.createMockProfileService(
            emailUpdate: { email in
                throw MyInfoSaveError.phoneNumberEmpty
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
        await model.save()

        assert(model.emailError == MyInfoSaveError.phoneNumberEmpty.localizedDescription)
    }
}
