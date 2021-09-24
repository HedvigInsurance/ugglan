import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

extension JourneyPresentation {
    func syncTabIndex() -> Self where P.Matter: UITabBarController {
        return addConfiguration { presenter in
            let store: UgglanStore = self.presentable.get()
            let tabBarController = presenter.matter

            tabBarController.selectedIndex = store.state.selectedTabIndex

            presenter.bag += tabBarController.signal(for: \.selectedViewController)
                .onValue { _ in
                    store.send(.setSelectedTabIndex(index: tabBarController.selectedIndex))
                }
        }
        .onState(UgglanStore.self) { state, presenter in
            presenter.matter.selectedIndex = state.selectedTabIndex
        }
    }

    /// Makes a tab active when store emits an action and true is returned in closure
    func makeTabSelected<S: Store>(
        _ storeType: S.Type,
        _ when: @escaping (_ action: S.Action) -> Bool
    ) -> Self {
        onAction(storeType) { action, presenter in
            guard let tabBarController = presenter.viewController.tabBarController else {
                return
            }

            if when(action),
                let presenterIndex = tabBarController.viewControllers?
                    .firstIndex(of: presenter.viewController)
            {
                tabBarController.selectedIndex = presenterIndex
            }
        }
    }
}

extension JourneyPresentation where P: Tabable {
    var configureTabBarItem: Self {
        addConfiguration { presenter in
            presenter.viewController.tabBarItem = self.presentable.tabBarItem()
        }
    }
}

struct Loader: Presentable {
    let tabBarController: UITabBarController

    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        let scrollView = FormScrollView()
        let form = FormView()
        bag += viewController.install(form, scrollView: scrollView)

        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        scrollView.addSubview(activityIndicatorView)

        activityIndicatorView.startAnimating()

        return (
            viewController,
            scrollView.didLayout {
                activityIndicatorView.snp.remakeConstraints { make in
                    make.center.equalTo(scrollView.frameLayoutGuide.snp.center)
                }
            }
        )
    }
}

class PlaceholderViewController: UIViewController, PresentingViewController {
    let bag = DisposeBag()

    func present(
        _ viewController: UIViewController,
        options: PresentationOptions
    ) -> (result: Future<()>, dismisser: () -> Future<()>) {
        bag += view.windowSignal.atOnce().compactMap { $0 }
            .onValue { window in
                UIView.transition(
                    with: window,
                    duration: 0.3,
                    options: .transitionCrossDissolve,
                    animations: {}
                )
                window.rootViewController = viewController
            }
        
        return (
            result: Future { completion in
                return NilDisposer()
            },
            dismisser: {
                return .init(immediate: { () })
            }
        )
    }

    override func targetViewController(forAction action: Selector, sender: Any?) -> UIViewController? {
        return self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let tabBarController = UITabBarController()
        addChild(tabBarController)
        self.view.addSubview(tabBarController.view)

        tabBarController.viewControllers = [Loader(tabBarController: tabBarController).materialize(into: bag)]
    }
}

extension JourneyPresentation {
    func onTabSelected(_ perform: @escaping () -> Void) -> Self {
        addConfiguration { presenter in
            guard let tabBarController = presenter.viewController.tabBarController else {
                return
            }

            func compareViewController() {
                if tabBarController.selectedViewController == presenter.viewController {
                    perform()
                }
            }

            compareViewController()

            presenter.bag += tabBarController.signal(for: \.selectedViewController)
                .onValue { _ in
                    compareViewController()
                }

            presenter.bag += tabBarController.signal(for: \.selectedIndex)
                .onValue { _ in
                    compareViewController()
                }
        }
    }
}
