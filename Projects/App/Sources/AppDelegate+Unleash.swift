import Flow
import Foundation
import Presentation
import Profile
import hCore

extension AppDelegate {
    func setupFeatureFlags(onComplete: @escaping (_ success: Bool) -> Void) {
        Dependencies.featureFlags().setup(with: getContext, onComplete: onComplete)
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
        featureFlagsBag.dispose()
        featureFlagsBag += Localization.Locale.$currentLocale
            .atOnce()
            .distinct()
            .onValue { locale in
                DispatchQueue.main.async {
                    Dependencies.featureFlags().updateContext(context: self.getContext)
                }
            }

        let profileStore: ProfileStore = globalPresentableStoreContainer.get()
        featureFlagsBag += profileStore.stateSignal
            .map({ $0.memberDetails?.id })
            .distinct()
            .onValue { memberId in
                Dependencies.featureFlags().updateContext(context: self.getContext)
            }
    }
}
