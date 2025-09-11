import Foundation
import PresentableStore
import Profile
import SwiftUI
import hCore

@MainActor
extension AppDelegate {
    func setupFeatureFlags() async throws {
        try await Dependencies.featureFlags().setup(with: getContext)
        observeUpdate()
    }

    private var getContext: [String: String] {
        let profileStore: ProfileStore = globalPresentableStoreContainer.get()
        let memberId = profileStore.state.memberDetails?.id

        let optionalDictionary: [String: String?] = [
            "memberId": memberId,
            "appVersion": Bundle.main.appVersion,
            "market": "SE",
            "osVersion": UIDevice.current.systemVersion,
        ]

        let requiredDictionary = optionalDictionary.compactMapValues { $0 }
        return requiredDictionary
    }

    private func observeUpdate() {
        cancellables.removeAll()
        Localization.Locale.currentLocale
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                Dependencies.featureFlags().updateContext(context: self.getContext)
            }
            .store(in: &cancellables)

        let profileStore: ProfileStore = globalPresentableStoreContainer.get()

        profileStore.stateSignal
            .map { $0.memberDetails?.id }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                Dependencies.featureFlags().updateContext(context: self.getContext)
            }
            .store(in: &cancellables)
    }
}
