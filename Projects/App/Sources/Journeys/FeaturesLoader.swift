import Flow
import Form
import Foundation
import Presentation
import UIKit
import hAnalytics
import hCoreUI

struct ExperimentsLoader: Presentable {
    func materialize() -> (UIViewController, Signal<Void>) {
        let viewController = PlaceholderViewController()

        let bag = DisposeBag()

        return (
            viewController,
            Signal { callback in
                hAnalyticsExperiment.load { _ in
                    callback(())
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

extension UNUserNotificationCenter {
    func status() -> UNAuthorizationStatus {
        var status: UNAuthorizationStatus!
        let semaphore = DispatchSemaphore(value: 0)
        self.getNotificationSettings { settings in
            status = settings.authorizationStatus
            semaphore.signal()
        }
        semaphore.wait()
        return status
    }
}
