import Embark
import Flow
import Foundation
import hCore
import hCoreUI
import Presentation
import UIKit

struct AppFlow {
    private let rootNavigationController = UINavigationController()

    let window: UIWindow

    init(window: UIWindow) {
        self.window = window
        self.window.rootViewController = rootNavigationController
    }
}

struct OnboardingFlow: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let (viewController, future) = EmbarkOnboardingFlow().materialize()
        let bag = DisposeBag()

        bag += future.onValue { redirect in
            switch redirect {
            case .mailingList:
                break
            case let .offer(ids):
                bag += viewController.present(WebOnboarding(webScreen: .webOffer(ids: ids))).onResult { result in
                    switch result {
                    case .success:
                        bag += viewController.present(PostOnboarding())
                    case .failure:
                        break
                    }
                }
            }
        }

        return (viewController, bag)
    }
}

struct EmbarkOnboardingFlow: Presentable {
    public func materialize() -> (UIViewController, Future<ExternalRedirect>) {
        let (viewController, storySignal) = EmbarkPlans().materialize()
        let bag = DisposeBag()

        return (viewController, Future { completion in
            bag += storySignal.atValue { story in
                let embark = Embark(name: story.name, flowType: .onboarding)
                bag += embark.routeSignal.onValue { route in
                    guard let route = route,
                          let presentable = presentable(for: route) else { return }

                    bag += viewController.present(presentable)
                }

                bag += viewController
                    .present(
                        embark,
                        options: [.autoPop]
                    ).onValue { redirect in completion(.success(redirect)) }
            }
            return bag
        })
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
                style: .detented(.medium, .large),
                options: [.allowSwipeDismissAlways, .defaults]
            )
        }
    }
}
