import CoreDependencies
import Flow
import Foundation
import Payment
import Presentation
import Profile
import hAnalytics
import hCore

extension AppDelegate {
    func handleDeepLink(_ dynamicLinkUrl: URL) {
        guard let path = dynamicLinkUrl.pathComponents.compactMap({ DeepLink(rawValue: $0) }).first else {
            return
        }
        guard ApplicationState.currentState?.isOneOf([.loggedIn]) == true else { return }
        guard let rootViewController = window.rootViewController else { return }

        if path == .directDebit {
            rootViewController.present(
                PaymentSetup(setupType: .initial)
                    .journeyThenDismiss
            )
            .onValue { _ in

            }
        } else if path == .sasEuroBonus {
            deepLinkDisposeBag += ApplicationContext.shared.$hasFinishedBootstrapping.atOnce().filter { $0 }
                .onValue { [weak self] _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        let profileStore: ProfileStore = globalPresentableStoreContainer.get()
                        self?.deepLinkDisposeBag += profileStore.stateSignal.onValue { [weak self] state in
                            if let shouldShowEuroBonus = state.partnerData?.shouldShowEuroBonus {
                                self?.deepLinkDisposeBag.dispose()
                                if shouldShowEuroBonus {
                                    profileStore.send(.openEuroBonus)
                                }
                            }
                        }
                        let store: UgglanStore = globalPresentableStoreContainer.get()
                        store.send(.makeTabActive(deeplink: .sasEuroBonus))
                        if let shouldShowEuroBonus = profileStore.state.partnerData?.shouldShowEuroBonus {
                            self?.deepLinkDisposeBag.dispose()
                            if shouldShowEuroBonus {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    profileStore.send(.openEuroBonus)
                                }
                            }
                        }
                    }
                }
        } else {
            deepLinkDisposeBag += ApplicationContext.shared.$hasFinishedBootstrapping.atOnce().filter { $0 }
                .onValue { _ in
                    let store: UgglanStore = globalPresentableStoreContainer.get()
                    store.send(.makeTabActive(deeplink: path))
                }
        }
    }
}
