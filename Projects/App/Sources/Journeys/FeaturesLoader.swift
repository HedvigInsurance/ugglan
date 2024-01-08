import Claims
import Contracts
import Flow
import Form
import Foundation
import Presentation
import Profile
import UIKit
import hCoreUI

struct ExperimentsLoader: Presentable {
    func materialize() -> (UIViewController, Signal<Void>) {
        let viewController = PlaceholderViewController()

        let bag = DisposeBag()

        return (
            viewController,
            Signal { callback in
                let contractStore: ContractStore = globalPresentableStoreContainer.get()
                contractStore.send(.fetchContracts)

                let contractSignal = contractStore.stateSignal
                    .map({ $0.activeContracts })
                    .distinct()

                let profileStore: ProfileStore = globalPresentableStoreContainer.get()
                profileStore.send(.fetchMemberDetails)

                let profileSignal = profileStore.stateSignal
                    .map({ $0.memberDetails?.id != nil })
                    .distinct()

                bag += combineLatest(
                    contractSignal,
                    profileSignal
                )
                .distinct({ previousContracts, contracts in
                    if previousContracts.0.count != contracts.0.count || previousContracts.1 != contracts.1 {
                        return true
                    }
                    return false
                })
                .onValue { value in
                    UIApplication.shared.appDelegate.setupFeatureFlags(onComplete: { success in
                        callback(())
                    })
                }
                return bag
            }
        )
    }
}

struct StoreLoadingPresentable<S: Store>: Presentable {
    let action: S.Action
    let endOn: (S.Action) -> Bool

    func materialize() -> (UIViewController, Signal<S.State>) {
        let viewController = PlaceholderViewController()

        let bag = DisposeBag()

        return (
            viewController,
            Signal { callback in
                let store: S = self.get()
                store.send(action)

                bag += store.actionSignal.onValue { action in
                    if endOn(action) {
                        callback(store.stateSignal.value)
                    }
                }

                return bag
            }
        )
    }
}

struct NotificationLoader: Presentable {

    func materialize() -> (UIViewController, FiniteSignal<UNAuthorizationStatus>) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        viewController.view.backgroundColor = .brand(.primaryBackground())

        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        viewController.view.addSubview(activityIndicatorView)

        activityIndicatorView.startAnimating()

        activityIndicatorView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
        }

        return (
            viewController,
            FiniteSignal { callback in
                let current = UNUserNotificationCenter.current()
                current.getNotificationSettings(completionHandler: { settings in
                    callback(.value(settings.authorizationStatus))
                })

                return bag
            }
        )
    }
}
