import Flow
import Foundation
import Presentation
import Profile
import hCore

extension AppDelegate {
    func setupFeatureFlags() {
        FeatureFlags.shared.setup(with: getContext)
        observeUpdate()
    }

    private var getContext: [String: String] {
        let profileStore: ProfileStore = globalPresentableStoreContainer.get()
        profileStore.send(.fetchMemberDetails)
        let memberId = profileStore.state.memberDetails?.id

        let optionalDictionary: [String: String?] = [
            "memberId": memberId,
            "appVersion": Bundle.main.appVersion,
            "market": Localization.Locale.currentLocale.market.rawValue,
        ]

        let requiredDictionary = optionalDictionary.compactMapValues { $0 }
        return requiredDictionary
    }

    private func observeUpdate() {
        bag += Localization.Locale.$currentLocale
            .atOnce()
            .distinct()
            .onValue { locale in
                DispatchQueue.main.async {
                    FeatureFlags.shared.updateContext(context: self.getContext)
                }
            }

        let profileStore: ProfileStore = globalPresentableStoreContainer.get()
        bag += profileStore.stateSignal
            .map({ $0.memberDetails?.id })
            .distinct()
            .onValue { memberId in
                FeatureFlags.shared.updateContext(context: self.getContext)
            }
    }
}
