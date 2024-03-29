import Claims
import Contracts
import Flow
import Form
import Foundation
import Home
import Presentation
import SwiftUI
import hCore
import hCoreUI

extension JourneyPresentation {
    func syncTabIndex() -> Self where P.Matter: UITabBarController {
        return addConfiguration { presenter in
            let store: UgglanStore = self.presentable.get()
            let tabBarController = presenter.matter

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

    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        let scrollView = FormScrollView()
        let form = FormView()
        bag += viewController.install(form, scrollView: scrollView)

        let activityIndicatorView = HostingView(
            rootView: ActivityIndicator(
                style: .large,
                color: hTextColor.primary
            )
        )
        scrollView.addSubview(activityIndicatorView)

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

        tabBarController.viewControllers = [Loader().materialize(into: bag)]
    }
}
