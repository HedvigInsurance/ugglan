import Embark
import Flow
import Foundation
import hCore
import hCoreUI
import Presentation
import UIKit

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
    public func materialize() -> (UIViewController, Disposable) {
        let (viewController, signal) = WebOnboarding(webScreen: .webOnboarding).materialize()

        let bag = DisposeBag()

        bag += signal.onValue { _ in
            bag += viewController.present(PostOnboarding())
        }

        return (viewController, bag)
    }
}

struct EmbarkOnboardingFlow: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let (viewController, signal) = EmbarkPlans().materialize()
        let bag = DisposeBag()

        bag += signal.atValue { story in
            let embark = Embark(
                name: story.name,
                menu: Menu(
                    title: nil,
                    children: [
                        MenuChild.appInformation,
                        MenuChild.appSettings,
                        MenuChild.login
                    ]
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
                        let webOnboardingSignal = viewController.present(WebOnboarding(webScreen: .webOffer(ids: ids)))
                        
                        bag += webOnboardingSignal.onEnd({
                            embark.goBack()
                        })
                        
                        bag += webOnboardingSignal.onValue { result in
                            bag += viewController.present(PostOnboarding())
                        }
                    }
                }
        }

        return (viewController, bag)
    }
}
