import Embark
import Flow
import Foundation
import hCore
import hCoreUI
import Presentation
import UIKit
import Offer

public struct AppFlow {
    private let rootNavigationController = UINavigationController()

    let window: UIWindow
    let bag = DisposeBag()

    init(window: UIWindow) {
        self.window = window
        self.window.rootViewController = rootNavigationController
    }

    func presentLoggedIn() {
        let loggedIn = LoggedIn()
        bag += window.present(loggedIn)
    }
}

struct WebOnboardingFlow: Presentable {
    let webScreen: WebOnboardingScreen
    
    public func materialize() -> (UIViewController, Signal<Void>) {
        let (viewController, signal) = WebOnboarding(webScreen: webScreen).materialize()

        let bag = DisposeBag()

        return (viewController, Signal { callback in
            bag += signal.onValue { _ in
                bag += viewController.present(
                    PostOnboarding(),
                    style: .detented(.large),
                    options: [.prefersNavigationBarHidden(true)]
                ).onValue(callback)
            }
            
            return bag
        })
    }
}

struct EmbarkOnboardingFlow: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let menuChildren: [MenuChildable] = [
            MenuChild.appInformation,
            MenuChild.appSettings,
            MenuChild.login(onLogin: {
                UIApplication.shared.appDelegate.appFlow.presentLoggedIn()
            })
        ]
        
        let (viewController, signal) = EmbarkPlans(menu: Menu(title: nil, children: menuChildren)).materialize()
        viewController.navigationItem.largeTitleDisplayMode = .always
        let bag = DisposeBag()

        bag += signal.atValue { story in
            let embark = Embark(
                name: story.name,
                menu: Menu(
                    title: nil,
                    children: menuChildren
                )
            )

            bag += viewController
                .present(
                    embark,
                    options: [.autoPop]
                ).onValue { redirect in
                    switch redirect {
                    case .mailingList:
                        break
                    case let .offer(ids):
                        let offerFuture = viewController.present(Offer(ids: ids))
                        
                        bag += offerFuture.onCancel({
                            embark.goBack()
                        })
                    }
                }
        }

        return (viewController, bag)
    }
}
