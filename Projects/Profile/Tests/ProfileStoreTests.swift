import AppStateContainer
import TestDependencies
import Testing

@testable import Profile
@testable import hCore

extension ProfileDependencySuite {
    @MainActor
    final class ProfileStoreTests {
        private weak var store: ProfileStore?

        init() {
            globalAppStateContainer.clearPersistence()
        }

        // Test bodies are scoped so their locals are released; a live local would make this wait never finish.
        private func expectStoreReleased() async {
            await waitUntil(description: "deinitStore") {
                self.store == nil
            }
            Dependencies.shared.remove(for: ProfileClient.self)
        }

        @Test
        func fetchProfileSuccess() async {
            do {
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
                #expect(store.fetchProfileStateError == nil)
                await waitUntil(description: "check state") {
                    store.memberDetails == memberData && store.partnerData == partnerData
                        && store.hasTravelCertificates == memberData.isTravelCertificateEnabled
                        && mockService.events.count == 1 && mockService.events.first == .getProfileState
                }
            }

            await expectStoreReleased()
        }

        @Test
        func fetchProfileFailure() async {
            do {
                let mockService = MockData.createMockProfileService(
                    fetchProfileState: { throw ProfileError.error(message: "error") }
                )

                let store = ProfileStore()
                self.store = store
                await store.fetchProfileState()
                #expect(store.fetchProfileStateError != nil)
                #expect(store.memberDetails == nil)
                #expect(store.partnerData == nil)
                #expect(store.hasTravelCertificates == false)

                #expect(mockService.events.count == 1)
                #expect(mockService.events.first == .getProfileState)
            }

            await expectStoreReleased()
        }

        @Test
        func fetchMemberDetailsSuccess() async {
            do {
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

                await waitUntil(description: "check state") {
                    store.fetchMemberDetailsError == nil && store.memberDetails == memberData
                        && store.hasTravelCertificates == false && mockService.events.count == 1
                        && mockService.events.first == .getMemberDetails
                }
            }

            await expectStoreReleased()
        }

        @Test
        func fetchMemberDetailsFailure() async {
            do {
                let mockService = MockData.createMockProfileService(
                    fetchMemberDetails: { throw ProfileError.error(message: "error") }
                )

                let store = ProfileStore()
                self.store = store
                await store.fetchMemberDetails()
                await waitUntil(description: "check state") {
                    store.fetchMemberDetailsError != nil && store.memberDetails == nil
                        && store.hasTravelCertificates == false && mockService.events.count == 1
                        && mockService.events.first == .getMemberDetails
                }
            }

            await expectStoreReleased()
        }

        @Test
        func updateLanguageSuccess() async {
            let previousLocale = Localization.Locale.currentLocale
            do {
                let locale: Localization.Locale = .sv_SE
                Localization.Locale.currentLocale = .init(locale)

                let mockService = MockData.createMockProfileService(
                    languageUpdate: {}
                )

                let store = ProfileStore()
                self.store = store
                await store.updateLanguage()
                await waitUntil(description: "check state") {
                    store.updateLanguageError == nil && Localization.Locale.currentLocale.value == .init(locale)
                        && mockService.events.count == 1 && mockService.events.first == .updateLanguage
                }
            }
            Localization.Locale.currentLocale = previousLocale

            await expectStoreReleased()
        }

        @Test
        func updateLanguageFailure() async {
            let previousLocale = Localization.Locale.currentLocale
            do {
                let locale: Localization.Locale = .sv_SE
                Localization.Locale.currentLocale = .init(locale)

                let mockService = MockData.createMockProfileService(
                    languageUpdate: { throw ProfileError.error(message: "error") }
                )

                let store = ProfileStore()
                self.store = store
                await store.updateLanguage()
                #expect(store.updateLanguageError != nil)
                #expect(Localization.Locale.currentLocale.value == .init(locale))

                #expect(mockService.events.count == 1)
                #expect(mockService.events.first == .updateLanguage)
            }
            Localization.Locale.currentLocale = previousLocale

            await expectStoreReleased()
        }
    }
}
