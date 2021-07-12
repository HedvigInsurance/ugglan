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

public struct MovingFlow {
	@Inject var client: ApolloClient
}

extension MovingFlow: Presentable {
	public func materialize() -> (UIViewController, Future<Void>) {
		let bag = DisposeBag()

		let (viewController, routeSignal) = MovingFlowIntro().materialize()

		return (
			viewController,
			Future { completion in
				bag += routeSignal.atValue { route in
					switch route {
					case .chat:
						viewController.present(
							FreeTextChat().wrappedInCloseButton(),
							configure: { chatViewController, _ in
								chatViewController.navigationItem.hidesBackButton = true
							}
						)
						.onResult(completion)
					case let .embark(name):
						bag +=
							viewController
							.present(
								Embark(
									name: name,
									menu: Menu(title: nil, children: [])
								),
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
											menu: Menu(
												title: nil,
												children: []
											),
											options: [.menuToTrailing]
										)
									)
									.onValue { _ in
										Toasts.shared.displayToast(
											toast: Toast(
												symbol: .icon(
													hCoreUIAssets
														.circularCheckmark
														.image
												),
												body: L10n
													.movingFlowSuccessToast
											)
										)
										completion(.success)
									}
								}
							}
					}
				}

				return bag
			}
		)
	}
}
