//
//  MainTabbedJourney.swift
//  Ugglan
//
//  Created by Sam Pettersson on 2021-07-18.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import Presentation
import Flow
import UIKit
import Home
import Contracts
import Forever
import Form
import hCoreUI

extension JourneyPresentation {
    func tabIndexReducer() -> Self where P.Matter: UITabBarController {
        return addConfiguration { presenter in
            let store: UgglanStore = self.presentable.get()
            let tabBarController = presenter.matter
            
            tabBarController.selectedIndex = store.value.selectedTabIndex
            
            presenter.bag += tabBarController.signal(for: \.selectedViewController).onValue { _ in
                store.send(.setSelectedTabIndex(tabBarController.selectedIndex))
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
        
        return (viewController, scrollView.didLayout {
            activityIndicatorView.snp.remakeConstraints { make in
                make.center.equalTo(scrollView.frameLayoutGuide.snp.center)
            }
        })
    }
}

class PlaceholderViewController: UIViewController, PresentingViewController {
    let bag = DisposeBag()
    
    func present(_ viewController: UIViewController, options: PresentationOptions) -> (result: Future<()>, dismisser: () -> Future<()>) {
        let window = view.window!
        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: {}
        )
        window.rootViewController = viewController
        
        return (result: Future { completion in
            return NilDisposer()
        }, dismisser: {
            return .init(immediate: { () })
        })
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

struct MainTabbedJourney {
    struct FeaturesLoader: Presentable {
        func materialize() -> (UIViewController, Signal<[UgglanState.Feature]>) {
            let viewController = PlaceholderViewController()
            
            let bag = DisposeBag()
            
            return (viewController, Signal { callback in
                let store: UgglanStore = get()
                store.send(.fetchFeatures)
                
                bag += store.compactMap { $0.features }.onFirstValue { value in
                    callback(value)
                }
                
                return bag
            })
        }
    }
    
    static var homeTab: some JourneyPresentation {
        let home = Home(sections: Contracts.getSections())
        
        return Journey(home, options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)]).addConfiguration { presenter in
            presenter.viewController.tabBarItem = home.tabBarItem()
        }
    }
    
    static var contractsTab: some JourneyPresentation {
        let contracts = Contracts()
        
        return Journey(Contracts()).addConfiguration { presenter in
            presenter.viewController.tabBarItem = contracts.tabBarItem()
        }
    }
    
    static var keyGearTab: some JourneyPresentation {
        let keyGearOverview = KeyGearOverview()
    
        return Journey(keyGearOverview).addConfiguration { presenter in
            presenter.viewController.tabBarItem = keyGearOverview.tabBarItem()
        }
    }
    
    static var foreverTab: some JourneyPresentation {
        let forever = Forever(service: ForeverServiceGraphQL())
        
        return Journey(forever).addConfiguration { presenter in
            presenter.viewController.tabBarItem = forever.tabBarItem()
        }
    }
    
    static var profileTab: some JourneyPresentation {
        let profile = Profile()
    
        return Journey(Profile()).addConfiguration { presenter in
            presenter.viewController.tabBarItem = profile.tabBarItem()
        }
    }
    
    static var journey: some JourneyPresentation {
        Journey(FeaturesLoader(), options: []) { features in
            TabbedJourney(
                {
                    homeTab
                },
                {
                    contractsTab
                },
                {
                    if features.contains(.keyGear) {
                        keyGearTab
                    }
                },
                {
                    if features.contains(.referrals) {
                        foreverTab
                    }
                },
                {
                    profileTab
                }
            ).tabIndexReducer()
        }
    }
}
