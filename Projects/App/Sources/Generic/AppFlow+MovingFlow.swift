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
	struct Coordinator {
		var presentFreeTextChat: () -> Future<Void>
		var presentEmbark: (_ name: String) -> (Embark, Embark.Result)
		var handleEmbarkRedirect:
			(_ embark: Embark, _ redirect: ExternalRedirect, _ coordinator: Coordinator) -> FiniteSignal<
				Void
			>
		var presentOffer: (_ ids: [String]) -> Offer.Result
		var handleEmbarkResult:
			(_ embark: Embark, _ result: Embark.Result, _ coordinator: Coordinator) -> Disposable
	}

	public func materialize() -> (UIViewController, Future<Void>) {
		let bag = DisposeBag()

		let (viewController, routeSignal) = MovingFlowIntro().materialize()

		return (
			viewController,
			Future { completion in
				let coordinator = Coordinator(
					presentFreeTextChat: {
						viewController.present(
							FreeTextChat().wrappedInCloseButton(),
							configure: { chatViewController, _ in
								chatViewController.navigationItem.hidesBackButton = true
							}
						)
					},
					presentEmbark: { name in
						let embark = Embark(
							name: name
						)

						return (
							embark,
							viewController
								.present(
									embark,
									options: [.autoPop]
								)
						)
					},
					handleEmbarkRedirect: { embark, redirect, coordinator in
						switch redirect {
						case .mailingList:
							return FiniteSignal { callback in
								callback(.end(GenericError.cancelled))
								return NilDisposer()
							}
						case .close:
							return FiniteSignal { callback in
								callback(.end(GenericError.cancelled))
								return NilDisposer()
							}
						case let .offer(ids):
							return coordinator.presentOffer(ids)
								.atEnd {
									embark.goBack()
								}
								.flatMapLatest { result -> FiniteSignal<Void> in
									switch result {
									case .close:
										return FiniteSignal { callback in
											callback(
												.end(
													GenericError
														.cancelled
												)
											)
											return NilDisposer()
										}
									case .signed:
										return FiniteSignal { callback in
											callback(.value(()))
											return NilDisposer()
										}
									}
								}
						}
					},
					presentOffer: { ids in
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
					},
					handleEmbarkResult: { embark, result, coordinator in
						result.onValueDisposePrevious { redirect in
							coordinator.handleEmbarkRedirect(
								embark,
								redirect,
								coordinator
							)
							.atValue({ _ in
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
							})
							.onError({ error in
								if let genericError = error as? GenericError,
									genericError == GenericError.cancelled
								{
									completion(.failure(error))
								}
							})
						}
					}
				)

				bag += routeSignal.atValue { route in
					switch route {
					case .chat:
						coordinator.presentFreeTextChat().onResult(completion)
					case let .embark(name):
						let (embark, embarkResult) = coordinator.presentEmbark(name)
						bag += coordinator.handleEmbarkResult(embark, embarkResult, coordinator)
					}
				}

				return bag
			}
		)
	}
}
