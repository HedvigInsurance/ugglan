import Foundation
import Presentation
import Embark
import Flow
import hCore
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
        let vc = UINavigationController()
        let bag = DisposeBag()
        
        bag += vc.present(EmbarkOnboardingFlow()).onValue({ (redirect) in
            switch redirect {
            case .mailingList:
                break
            case .offer(let ids):
                bag += vc.present(WebOnboarding(webScreen: .webOffer(ids: ids))).onResult { result in
                    switch result {
                    case .success:
                        bag += vc.present(PostOnboarding())
                    case .failure:
                        break
                    }
                }
            }
        })
        return (vc, bag)
    }
}

struct EmbarkOnboardingFlow: Presentable {
    public func materialize() -> (UIViewController, Future<ExternalRedirect>) {
        let (viewController, storySignal) = EmbarkPlans().materialize()
        let bag = DisposeBag()
        
        return (viewController, Future { completion in
            bag += storySignal.atValue({ story in
                bag += viewController
                    .present(
                        Embark(name: story.name),
                        options: [.autoPop]
                    ).onValue { (redirect) in completion(.success(redirect)) }
            })
            return bag
        })
    }
}
