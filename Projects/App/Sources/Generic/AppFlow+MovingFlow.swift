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
						let embark = Embark(
							name: name
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
								case .close:
									completion(.failure(GenericError.cancelled))
								case let .offer(ids: ids):
									bag +=
										viewController.present(
											Offer(
												offerIDContainer:
													.exact(
														ids:
															ids,
														shouldStore:
															false
													),
												menu: nil,
												options: [
													.menuToTrailing
												]
											)
										)
										.atValue { result in
											switch result {
											case .close:
												completion(
													.failure(
														GenericError
															.cancelled
													)
												)
											case .signed:
												Toasts.shared
													.displayToast(
														toast:
															Toast(
																symbol:
																	.icon(
																		hCoreUIAssets
																			.circularCheckmark
																			.image
																	),
																body:
																	L10n
																	.movingFlowSuccessToast
															)
													)
												completion(.success)
											}
										}
										.onEnd {
											embark.goBack()
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
