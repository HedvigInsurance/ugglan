//
//  TabJourneyHelpers.swift
//  Ugglan
//
//  Created by Sam Pettersson on 2021-07-26.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import UIKit
import Flow
import Presentation
import hCore
import hCoreUI
import Form

extension JourneyPresentation {
    func tabIndexReducer() -> Self where P.Matter: UITabBarController {
        return addConfiguration { presenter in
            let store: UgglanStore = self.presentable.get()
            let tabBarController = presenter.matter

            tabBarController.selectedIndex = store.state.selectedTabIndex

            presenter.bag += tabBarController.signal(for: \.selectedViewController)
                .onValue { _ in
                    store.send(.setSelectedTabIndex(index: tabBarController.selectedIndex))
                }
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
        let window = view.window!
        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: {}
        )
        window.rootViewController = viewController

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
        let tabBarController = UITabBarController()
        addChild(tabBarController)
        self.view.addSubview(tabBarController.view)

        tabBarController.viewControllers = [Loader(tabBarController: tabBarController).materialize(into: bag)]
    }
}

extension JourneyPresentation {
    func onTabActive(_ perform: @escaping () -> Void) -> Self {
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
