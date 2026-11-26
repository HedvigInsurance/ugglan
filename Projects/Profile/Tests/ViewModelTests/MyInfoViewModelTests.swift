import AppStateContainer
import Combine
import Foundation
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
        }

        // Test bodies are scoped so their locals are released before this check runs.
        private func expectServiceReleased() async {
            Dependencies.shared.remove(for: ProfileClient.self)
            Dependencies.shared.remove(for: HomeClient.self)
            Dependencies.shared.remove(for: FeatureFlagsClient.self)
            await delay(0.0000001)
            #expect(sut == nil, "the mock service must not outlive its dependency registration")
        }

        // MARK: - Helpers
        @discardableResult
        private func setUpMockService(
            fetchMemberDetails: FetchMemberDetails? = nil,
            memberUpdate: @escaping MemberUpdate = { email, phone in (email, phone) }
        ) -> MockProfileService {
            let service =
                if let fetchMemberDetails {
                    MockData.createMockProfileService(
                        fetchMemberDetails: fetchMemberDetails,
                        memberUpdate: memberUpdate
                    )
                } else {
                    MockData.createMockProfileService(memberUpdate: memberUpdate)
                }
            sut = service
            return service
        }

        /// Records the `object` of every `.memberEmailUpdated` notification until cancelled.
        private func observeEmailUpdates() -> (recorder: NotificationRecorder, cancellable: AnyCancellable) {
            let recorder = NotificationRecorder()
            let cancellable = NotificationCenter.default.publisher(for: .memberEmailUpdated)
                .sink { [weak recorder] notification in
                    recorder?.objects.append(notification.object as? String)
                }
            return (recorder, cancellable)
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

        @Test
        func saveWhenAPIThrowsDoesNotPostEmailUpdated() async {
            do {
                setUpMockService(
                    memberUpdate: { _, _ in
                        throw MyInfoSaveError.error(message: "Network error")
                    }
                )
                _ = await setUpStore()
                let (recorder, cancellable) = observeEmailUpdates()

                let model = MyInfoViewModel()
                model.currentEmailInput = "valid@email.com"
                let success = await model.save()
                cancellable.cancel()

                #expect(success == false)
                #expect(recorder.objects.isEmpty)
            }

            await expectServiceReleased()
        }

        // MARK: - Email Updated Notification

        @Test
        func saveInAllModePostsEmailUpdatedSuccess() async {
            do {
                setUpMockService()
                _ = await setUpStore(email: "old@email.com")
                let homeStore = HomeStore()
                globalAppStateContainer.register(homeStore)
                let (recorder, cancellable) = observeEmailUpdates()

                let model = MyInfoViewModel(fields: .all)
                let newEmail = "newemail@email.com"
                model.currentEmailInput = newEmail
                let success = await model.save()
                cancellable.cancel()
                await waitUntil(description: "the member state refresh started by save() finished") {
                    homeStore.memberInfo != nil
                }

                #expect(success)
                #expect(recorder.objects == [newEmail])
            }

            await expectServiceReleased()
        }

        // MARK: - Email Only Mode

        @Test
        func initInEmailOnlyModeWithEmptyPhoneEnablesSaveButton() async {
            do {
                setUpMockService()
                _ = await setUpStore(phone: "")

                let emailOnlyModel = MyInfoViewModel(fields: .emailOnly)
                let allModel = MyInfoViewModel(fields: .all)

                #expect(emailOnlyModel.fields == .emailOnly)
                #expect(emailOnlyModel.disabledSaveButton == false)
                #expect(allModel.disabledSaveButton, "precondition: an empty phone disables saving in .all mode")
            }

            await expectServiceReleased()
        }

        @Test
        func isValidInEmailOnlyModeIgnoresInvalidPhone() async {
            do {
                setUpMockService()
                _ = await setUpStore()

                let model = MyInfoViewModel(fields: .emailOnly)
                model.currentPhoneInput = "not a phone"
                model.phoneError = "phone error"
                model.isValid()

                #expect(model.disabledSaveButton == false)

                model.currentEmailInput = ""
                model.isValid()

                #expect(model.disabledSaveButton, "an empty email must still disable saving")
            }

            await expectServiceReleased()
        }

        @Test
        func saveInEmailOnlyModeSendsStoredPhoneWithNewEmailSuccess() async {
            do {
                let sentValues = SentValues()
                let mockService = setUpMockService(
                    memberUpdate: { email, phone in
                        sentValues.values.append((email, phone))
                        return (email, phone)
                    }
                )
                let store = await setUpStore(email: "old@email.com")
                let homeStore = HomeStore()
                globalAppStateContainer.register(homeStore)
                let (recorder, cancellable) = observeEmailUpdates()

                let model = MyInfoViewModel(fields: .emailOnly)
                let newEmail = "newemail@email.com"
                model.currentEmailInput = newEmail
                let success = await model.save()
                cancellable.cancel()
                await waitUntil(description: "the member state refresh started by save() finished") {
                    homeStore.memberInfo != nil
                }

                #expect(success)
                #expect(sentValues.values.count == 1)
                #expect(sentValues.values.first?.email == newEmail)
                #expect(sentValues.values.first?.phone == phone)
                #expect(mockService.events == [.memberUpdate], "the stored phone is used, so nothing is fetched")
                #expect(store.memberDetails?.email == newEmail)
                #expect(store.memberDetails?.phone == phone)
                #expect(recorder.objects == [newEmail])
            }

            await expectServiceReleased()
        }

        @Test
        func saveInEmailOnlyModeWithEmptyStoredPhoneFetchesMemberDetailsSuccess() async {
            do {
                let fetchedPhone = "0701234567"
                let sentValues = SentValues()
                let mockService = setUpMockService(
                    fetchMemberDetails: {
                        .init(
                            id: "memberId",
                            firstName: "first name",
                            lastName: "last name",
                            phone: fetchedPhone,
                            email: "old@email.com",
                            hasTravelCertificate: true,
                            isContactInfoUpdateNeeded: false
                        )
                    },
                    memberUpdate: { email, phone in
                        sentValues.values.append((email, phone))
                        return (email, phone)
                    }
                )
                let store = await setUpStore(phone: "", email: "old@email.com")
                let homeStore = HomeStore()
                globalAppStateContainer.register(homeStore)
                let (recorder, cancellable) = observeEmailUpdates()

                let model = MyInfoViewModel(fields: .emailOnly)
                let newEmail = "newemail@email.com"
                model.currentEmailInput = newEmail
                let success = await model.save()
                cancellable.cancel()
                await waitUntil(description: "the member state refresh started by save() finished") {
                    homeStore.memberInfo != nil
                }

                #expect(success)
                #expect(mockService.events == [.getMemberDetails, .memberUpdate])
                #expect(sentValues.values.count == 1)
                #expect(sentValues.values.first?.email == newEmail)
                #expect(sentValues.values.first?.phone == fetchedPhone)
                #expect(store.memberDetails?.email == newEmail)
                #expect(store.memberDetails?.phone == fetchedPhone)
                #expect(recorder.objects == [newEmail])
            }

            await expectServiceReleased()
        }

        @Test
        func saveInEmailOnlyModeWhenFetchedPhoneIsEmptyFailsWithPhoneEmptyError() async {
            do {
                let mockService = setUpMockService(
                    fetchMemberDetails: {
                        .init(
                            id: "memberId",
                            firstName: "first name",
                            lastName: "last name",
                            phone: "",
                            email: "old@email.com",
                            hasTravelCertificate: true,
                            isContactInfoUpdateNeeded: false
                        )
                    }
                )
                _ = await setUpStore(phone: "", email: "old@email.com")
                let (recorder, cancellable) = observeEmailUpdates()

                let model = MyInfoViewModel(fields: .emailOnly)
                model.currentEmailInput = "newemail@email.com"
                let success = await model.save()
                cancellable.cancel()

                #expect(success == false)
                #expect(model.phoneError == MyInfoSaveError.phoneNumberEmpty.localizedDescription)
                #expect(mockService.events == [.getMemberDetails])
                #expect(recorder.objects.isEmpty)
            }

            await expectServiceReleased()
        }
    }
}

private final class NotificationRecorder {
    var objects: [String?] = []
}

private final class SentValues {
    var values: [(email: String, phone: String)] = []
}
