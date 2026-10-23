import AppStateContainer
import Foundation
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
        let profileStore: ProfileStore = globalAppStateContainer.get()
        let memberId = profileStore.memberDetails?.id

        let optionalDictionary: [String: String?] = [
            "memberId": memberId,
            // Unleash's own user field, next to the memberId property the flags' stickiness keys on.
            "userId": memberId,
            "appVersion": Bundle.main.appVersion,
            "market": "SE",
            // Normalize to 3-component semver (e.g. "26" → "26.0.0") since systemVersion can return 1, 2, or 3 components
            "osVersion": {
                let components = UIDevice.current.systemVersion.split(separator: ".").map(String.init)
                let padded = components + Array(repeating: "0", count: max(0, 3 - components.count))
                return padded.prefix(3).joined(separator: ".")
            }(),
        ]

        let requiredDictionary = optionalDictionary.compactMapValues { $0 }
        return requiredDictionary
    }

    /// Hands Unleash the member the profile store holds, or nobody after a logout.
    func updateFeatureFlagsContext() {
        Dependencies.featureFlags().updateContext(context: getContext)
    }

    private func observeUpdate() {
        cancellables.removeAll()
        Localization.Locale.currentLocale
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateFeatureFlagsContext()
            }
            .store(in: &cancellables)

        let profileStore: ProfileStore = globalAppStateContainer.get()

        profileStore.$memberDetails
            .map { $0?.id }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateFeatureFlagsContext()
            }
            .store(in: &cancellables)
    }
}
