import Apollo
import Contracts
import Embark
import Flow
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Home
import Presentation
import UIKit
import Offer

struct MovingFlow {
    @Inject var client: ApolloClient
}

extension MovingFlow: Presentable {
    public func materialize() -> (UIViewController, Disposable) {
        let menuChildren: [MenuChildable] = [
            MenuChild.appInformation,
            MenuChild.appSettings,
            MenuChild.login(onLogin: {
                UIApplication.shared.appDelegate.appFlow.presentLoggedIn()
            }),
        ]

        let menu = Menu(
            title: nil,
            children: menuChildren
        )

        let bag = DisposeBag()

        let (viewController, routeSignal) = MovingFlowIntro(menu: menu).materialize()

        viewController.hidesBottomBarWhenPushed = true

        bag += routeSignal.atValue { route in
            switch route {
            case .chat:
                bag += viewController.present(Chat())
            case let .embark(name):
                bag += viewController
                    .present(
                        Embark(
                            name: name,
                            menu: menu
                        ),
                        options: [.autoPop]
                    )
                    .onValue { redirect in
                        switch redirect {
                        case .mailingList:
                            break
                        case let .offer(ids: ids):
                            viewController.present(Offer(
                                offerIDContainer: .exact(ids: ids, shouldStore: false),
                                menu: Menu(title: nil, children: [])
                            )).onValue { _ in
                                #warning("handle this")
                            }
                        }
                    }
            }
        }

        return (viewController, bag)
    }
}
