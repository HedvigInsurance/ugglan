import Apollo
import Contracts
import Flow
import Forever
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Home
import Mixpanel
import Presentation
import UIKit

struct LoggedIn {
    @Inject var client: ApolloClient
    let didSign: Bool

    init(didSign: Bool = false) {
        self.didSign = didSign
    }
}

extension Notification.Name {
    static let shouldOpenReferrals = Notification.Name("shouldOpenReferrals")
}

extension LoggedIn {
    func handleOpenReferrals(tabBarController: UITabBarController) -> Disposable {
        NotificationCenter.default.signal(forName: .shouldOpenReferrals).onValue { _ in
            tabBarController.selectedIndex = 3
        }
    }
}

extension LoggedIn: Presentable {
    func materialize() -> (UITabBarController, Disposable) {
        let tabBarController = UITabBarController()
        let loadingViewController = UIViewController()
        loadingViewController.view.backgroundColor = .brand(.primaryBackground())
        tabBarController.viewControllers = [loadingViewController]

        ApplicationState.preserveState(.loggedIn)

        let bag = DisposeBag()

        enum Tab {
            case home
            case contracts
            case keyGear
            case forever
            case profile
        }

        let indexForTabsSignal = ReadWriteSignal<[Int: Tab]>([:])

        let home = Home()
        let contracts = Contracts()
        let keyGear = KeyGearOverview()
        let referrals = Forever(service: ForeverServiceGraphQL())
        let profile = Profile()

        let homePresentation = Presentation(
            home,
            style: .default,
            options: [.defaults, .prefersLargeTitles(true)]
        )

        let contractsPresentation = Presentation(
            contracts,
            style: .default,
            options: [.defaults, .prefersLargeTitles(true)]
        )

        let keyGearPresentation = Presentation(
            keyGear,
            style: .default,
            options: [.prefersLargeTitles(true)]
        )

        let referralsPresentation = Presentation(
            referrals,
            style: .default,
            options: [.defaults, .prefersLargeTitles(true)]
        )

        let profilePresentation = Presentation(
            profile,
            style: .default,
            options: [.defaults, .prefersLargeTitles(true)]
        )

        bag += client.fetch(
            query: GraphQL.FeaturesQuery(),
            cachePolicy: .fetchIgnoringCacheData
        ).valueSignal.compactMap { $0.member.features }.onValue { features in
            if features.contains(.keyGear) {
                if features.contains(.referrals) {
                    bag += tabBarController.presentTabs(
                        homePresentation,
                        contractsPresentation,
                        keyGearPresentation,
                        referralsPresentation,
                        profilePresentation
                    )

                    indexForTabsSignal.value = [
                        0: .home,
                        1: .contracts,
                        2: .keyGear,
                        3: .forever,
                        4: .profile,
                    ]
                } else {
                    bag += tabBarController.presentTabs(
                        homePresentation,
                        contractsPresentation,
                        keyGearPresentation,
                        profilePresentation
                    )

                    indexForTabsSignal.value = [
                        0: .home,
                        1: .contracts,
                        2: .keyGear,
                        3: .profile,
                    ]
                }
            } else {
                if features.contains(.referrals) {
                    bag += tabBarController.presentTabs(
                        homePresentation,
                        contractsPresentation,
                        referralsPresentation,
                        profilePresentation
                    )

                    indexForTabsSignal.value = [
                        0: .home,
                        1: .contracts,
                        2: .forever,
                        3: .profile,
                    ]
                } else {
                    bag += tabBarController.presentTabs(
                        homePresentation,
                        contractsPresentation,
                        profilePresentation
                    )

                    indexForTabsSignal.value = [
                        0: .home,
                        1: .contracts,
                        2: .profile,
                    ]
                }
            }
        }

        if didSign {
            tabBarController.present(WelcomePager()).onValue { _ in
                AskForRating().ask()
            }
        } else {
            tabBarController.presentConditionally(WhatsNewPager()).onValue { _ in }
        }

        ApplicationState.setLastNewsSeen()

        bag += handleOpenReferrals(tabBarController: tabBarController)

        bag += combineLatest(tabBarController.signal(for: \.selectedViewController), indexForTabsSignal).atOnce().onValue { viewController, indexForTabs in
            let tab = indexForTabs[tabBarController.selectedIndex]

            switch tab {
            case .home:
                ContextGradient.currentOption = .home
            case .contracts:
                ContextGradient.currentOption = .insurance
            case .forever:
                ContextGradient.currentOption = .forever
            case .profile:
                ContextGradient.currentOption = .profile
            case .keyGear:
                ContextGradient.currentOption = .none
            case .none:
                ContextGradient.currentOption = .none
            }

            if let debugPresentationTitle = viewController?.debugPresentationTitle {
                Mixpanel.mainInstance().track(event: "SCREEN_VIEW_\(debugPresentationTitle)")
            }
        }

        bag += ChatState.shared.activateNewMessageToasts(tabBarController)

        return (tabBarController, bag)
    }
}
