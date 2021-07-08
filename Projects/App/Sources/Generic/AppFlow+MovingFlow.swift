import Apollo
import Contracts
import Embark
import Flow
import Foundation
import Home
import Offer
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

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
				let embark = Embark(
					name: name,
					menu: menu
				)

				bag +=
					viewController
					.present(
						embark,
						options: [.autoPop]
					)
					.onValue { redirect in
						switch redirect {
						case .mailingList:
							break
						case let .offer(ids: ids):
							viewController.present(
								Offer(
									offerIDContainer: .exact(
										ids: ids,
										shouldStore: false
									),
									menu: Menu(title: nil, children: []),
									options: [.menuToTrailing]
								)
							)
							.onCancel {
								embark.goBack()
							}
							.onValue { _ in
								#warning("handle this")
							}
						}
					}
			}
		}

		return (viewController, bag)
	}
}
