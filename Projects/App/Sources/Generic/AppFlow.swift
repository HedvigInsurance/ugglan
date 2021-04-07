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
        ApplicationState.preserveState(.loggedIn)
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
            let embark = Embark(name: story.name, flowType: .onboarding)

            bag += viewController
                .present(
                    embark,
                    options: [.autoPop]
                ).onValue { embarkValue in
                    switch embarkValue {
                    case let .left(redirect):
                        switch redirect {
                        case .mailingList:
                            break
                        case let .offer(ids):
                            bag += viewController.present(WebOnboarding(webScreen: .webOffer(ids: ids))).onValue { _ in
                                bag += viewController.present(PostOnboarding())
                            }
                        }
                    case let .right(route):
                        guard let presentable = presentable(for: route) else { return }
                        bag += viewController.present(presentable)
                    }
                }
        }

        return (viewController, bag)
    }
}

extension EmbarkOnboardingFlow {
    func presentable(for route: EmbarkMenuRoute) -> AnyPresentation<UIViewController, Future<Void>>? {
        switch route {
        case .appInformation:
            return Presentation(
                AppInfo(state: .appInformation).withCloseButton,
                style: .modal,
                options: [
                    .allowSwipeDismissAlways,
                    .defaults,
                    .largeTitleDisplayMode(.always),
                    .prefersLargeTitles(true),
                ]
            )
        case .appSettings:
            return Presentation(
                AppInfo(state: .appSettings).withCloseButton,
                style: .modal,
                options: [
                    .allowSwipeDismissAlways,
                    .defaults,
                    .largeTitleDisplayMode(.always),
                    .prefersLargeTitles(true),
                ]
            )
        case .restart:
            return nil
        case .login:
            return Presentation(
                Login(),
                style: .detented(.large),
                options: [.allowSwipeDismissAlways, .defaults, .autoPop]
            ).onValue {
                UIApplication.shared.appDelegate.appFlow.presentLoggedIn()
            }
        }
    }
}
