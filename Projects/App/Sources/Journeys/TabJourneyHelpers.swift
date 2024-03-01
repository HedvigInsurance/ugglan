import Claims
import Contracts
import Flow
import Form
import Foundation
import Home
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

class PlaceholderViewController: UIViewController, PresentingViewController {
    let bag = DisposeBag()
    private let tabController = UITabBarController()
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

    func setTabBar(hidden: Bool) {
        tabController.tabBar.isHidden = hidden
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(tabController)
        self.view.addSubview(tabController.view)
        tabController.viewControllers = [LoadingLogoScreen().materialize(into: bag)]
        tabController.tabBar.isHidden = true
    }
}

struct LoadingLogoScreen: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        viewController.view.backgroundColor = .brand(.primaryBackground())

        let containerView = UIView()
        containerView.backgroundColor = .brand(.primaryBackground())

        let imageView = UIImageView()
        imageView.image = hCoreUIAssets.wordmark.image
        imageView.contentMode = .scaleAspectFit

        containerView.addSubview(imageView)

        imageView.snp.makeConstraints { make in make.width.equalTo(140)
            make.height.equalTo(50)
            make.center.equalToSuperview()
        }
        viewController.view.addSubview(containerView)

        containerView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
        }

        return (
            viewController,
            NilDisposer()
        )
    }
}
