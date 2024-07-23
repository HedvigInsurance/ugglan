import Foundation
import Presentation
import Profile
import SwiftUI
import hCore

extension AppDelegate {
    func setupFeatureFlags(onComplete: @escaping (_ success: Bool) -> Void) {
        Dependencies.featureFlags().setup(with: getContext, onComplete: onComplete)
        observeUpdate()
    }

    private var getContext: [String: String] {
        let profileStore: ProfileStore = globalPresentableStoreContainer.get()
        let memberId = profileStore.state.memberDetails?.id

        let optionalDictionary: [String: String?] = [
            "memberId": memberId,
            "appVersion": Bundle.main.appVersion,
            "market": Localization.Locale.currentLocale.market.rawValue,
            "osVersion": UIDevice.current.systemVersion,
        ]

        let requiredDictionary = optionalDictionary.compactMapValues { $0 }
        return requiredDictionary
    }

    private func observeUpdate() {
        Localization.Locale.$currentLocale
            .atOnce()
            .distinct()
            .plain()
            .publisher
            .receive(on: RunLoop.main)
            .sink { locale in
                Dependencies.featureFlags().updateContext(context: self.getContext)
            }
            .store(in: &cancellables)

        let profileStore: ProfileStore = globalPresentableStoreContainer.get()

        profileStore.stateSignal
            .distinct()
            .map({ $0.memberDetails?.id })
            .plain()
            .publisher
            .receive(on: RunLoop.main)
            .sink { memberId in
                Dependencies.featureFlags().updateContext(context: self.getContext)
            }
            .store(in: &cancellables)
    }
}
