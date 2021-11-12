import Flow
import Foundation
import Presentation
import UIKit

struct FeaturesLoader: Presentable {
    func materialize() -> (UIViewController, Signal<[UgglanState.Feature]>) {
        let viewController = PlaceholderViewController()

        let bag = DisposeBag()

        return (
            viewController,
            Signal { callback in
                let store: UgglanStore = get()
                store.send(.fetchFeatures)

                bag += store.stateSignal.atOnce().compactMap { $0.features }
                    .onFirstValue { value in
                        callback(value)
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
