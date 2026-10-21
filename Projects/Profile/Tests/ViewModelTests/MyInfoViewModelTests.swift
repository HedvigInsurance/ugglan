import AppStateContainer
import Home
import TestDependencies
import Testing
import hCore

@testable import Profile

private let phone = "0123456789"
private let email = "test@email.com"

extension ProfileDependencySuite {
    @MainActor
    final class MyInfoViewModelTests {
        private weak var sut: MockProfileService?

        init() {
            globalAppStateContainer.clearPersistence()
            Dependencies.shared.add(module: Module { () -> HomeClient in HomeClientDemo() })
            Dependencies.shared.add(module: Module { () -> FeatureFlagsClient in FeatureFlagsDemo() })
            Dependencies.shared.add(module: Module { () -> FeatureFlags in FeatureFlags.shared })
        }

        // Test bodies are scoped so their locals are released before this check runs.
        private func expectServiceReleased() async {
            Dependencies.shared.remove(for: ProfileClient.self)
            Dependencies.shared.remove(for: HomeClient.self)
            Dependencies.shared.remove(for: FeatureFlagsClient.self)
            Dependencies.shared.remove(for: FeatureFlags.self)
            await delay(0.0000001)
            #expect(sut == nil, "the mock service must not outlive its dependency registration")
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
            globalAppStateContainer.register(store)
            store.setMemberDetails(
                .init(
                    id: "memberId",
                    firstName: "first name",
                    lastName: "last name",
                    phone: phone,
                    email: email,
                    hasTravelCertificate: true,
                    isContactInfoUpdateNeeded: false
                )
            )
            return store
        }

        // MARK: - Phone Update Success

        @Test
        func saveWithValidPhoneUpdatesStoreAndSucceeds() async {
            do {
                let mockService = setUpMockService()
                let store = await setUpStore(phone: "000000")
                // A fresh HomeStore, so the wait below sees the refresh save() kicks off, not a leftover one.
                let homeStore = HomeStore()
                globalAppStateContainer.register(homeStore)

                let model = MyInfoViewModel()
                let newPhone = "111111"
                model.currentPhoneInput = newPhone

                let success = await model.save()
                await waitUntil(description: "the member state refresh started by save() finished") {
                    homeStore.memberInfo != nil
                }

                #expect(success)
                #expect(store.memberDetails?.phone == newPhone)
                #expect(store.memberDetails?.email == email)
                #expect(model.phoneError == nil)
                #expect(model.emailError == nil)
                #expect(mockService.events.contains(.memberUpdate))
            }

            await expectServiceReleased()
        }

        // MARK: - Phone Update Failures

        @Test
        func saveWithEmptyPhoneFailsWithPhoneEmptyError() async {
            do {
                let mockService = setUpMockService()
                let store = await setUpStore()

                let model = MyInfoViewModel()
                model.currentPhoneInput = ""
                let success = await model.save()

                #expect(success == false)
                #expect(model.phoneError == MyInfoSaveError.phoneNumberEmpty.localizedDescription)
                #expect(model.emailError == nil)
                #expect(mockService.events.contains(.memberUpdate) == false)
                #expect(store.memberDetails?.phone == phone)
            }

            await expectServiceReleased()
        }

        // MARK: - Email Update Success

        @Test
        func saveWithValidEmailUpdatesStoreAndSucceeds() async {
            do {
                let mockService = setUpMockService()
                let store = await setUpStore(email: "old@email.com")
                // A fresh HomeStore, so the wait below sees the refresh save() kicks off, not a leftover one.
                let homeStore = HomeStore()
                globalAppStateContainer.register(homeStore)

                let model = MyInfoViewModel()
                let newEmail = "newemail@email.com"
                model.currentEmailInput = newEmail

                let success = await model.save()
                await waitUntil(description: "the member state refresh started by save() finished") {
                    homeStore.memberInfo != nil
                }

                #expect(success)
                #expect(store.memberDetails?.email == newEmail)
                #expect(store.memberDetails?.phone == phone)
                #expect(model.phoneError == nil)
                #expect(model.emailError == nil)
                #expect(mockService.events.contains(.memberUpdate))
            }

            await expectServiceReleased()
        }

        // MARK: - Email Update Failures

        @Test
        func saveWithEmptyEmailFailsWithEmailEmptyError() async {
            do {
                let mockService = setUpMockService()
                let store = await setUpStore()

                let model = MyInfoViewModel()
                model.currentEmailInput = ""
                let success = await model.save()

                #expect(success == false)
                #expect(model.emailError == MyInfoSaveError.emailEmpty.localizedDescription)
                #expect(model.phoneError == nil)
                #expect(mockService.events.contains(.memberUpdate) == false)
                #expect(store.memberDetails?.email == email)
            }

            await expectServiceReleased()
        }

        @Test
        func saveWithMalformedEmailFailsWithEmailMalformedError() async {
            do {
                let mockService = setUpMockService()
                let store = await setUpStore()

                let model = MyInfoViewModel()
                let malformedEmail = "email@email"
                model.currentEmailInput = malformedEmail
                let success = await model.save()

                #expect(success == false)
                #expect(model.emailError == MyInfoSaveError.emailMalformed.localizedDescription)
                #expect(model.phoneError == nil)
                #expect(mockService.events.contains(.memberUpdate) == false)
                #expect(store.memberDetails?.email == email)
            }

            await expectServiceReleased()
        }

        // MARK: - API Failure

        @Test
        func saveWhenAPIThrowsFailsWithErrorMessage() async {
            do {
                let mockService = setUpMockService(
                    memberUpdate: { _, _ in
                        throw MyInfoSaveError.error(message: "Network error")
                    }
                )
                let store = await setUpStore()

                let model = MyInfoViewModel()
                model.currentEmailInput = "valid@email.com"
                let success = await model.save()

                #expect(success == false)
                #expect(mockService.events.contains(.memberUpdate))
                #expect(store.memberDetails?.phone == phone)
                #expect(store.memberDetails?.email == email)
            }

            await expectServiceReleased()
        }
    }
}
