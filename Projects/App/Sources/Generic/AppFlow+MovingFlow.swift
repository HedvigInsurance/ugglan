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
        let viewController: UIViewController
        let completion: (_ result: Result<Void>) -> Void
        
        func presentFreeTextChat() -> Future<Void> {
            viewController.present(
                FreeTextChat().wrappedInCloseButton(),
                configure: { chatViewController, _ in
                    chatViewController.navigationItem.hidesBackButton = true
                }
            )
        }
        
        func presentEmbark(name: String) -> (Embark, Embark.Result) {
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
        }
        
        func handleEmbarkRedirect(_ embark: Embark, _ redirect: ExternalRedirect) -> FiniteSignal<
            Void
        > {
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
                return self.presentOffer(ids: ids)
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
        }
        
        func presentOffer(ids: [String]) -> Offer.Result {
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
        }
		
        func handleEmbarkResult(_ embark: Embark, _ result: Embark.Result) -> Disposable {
            result.onValueDisposePrevious { redirect in
                self.handleEmbarkRedirect(
                    embark,
                    redirect
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

                    self.completion(.success)
                })
                .onError({ error in
                    if let genericError = error as? GenericError,
                        genericError == GenericError.cancelled
                    {
                        self.completion(.failure(error))
                    }
                })
            }
        }
	}

	public func materialize() -> (UIViewController, Future<Void>) {
		let bag = DisposeBag()

		let (viewController, routeSignal) = MovingFlowIntro().materialize()

		return (
			viewController,
			Future { completion in
				let coordinator = Coordinator(
                    viewController: viewController
                ) { result in
                    completion(result)
                }

				bag += routeSignal.atValue { route in
					switch route {
					case .chat:
						coordinator.presentFreeTextChat().onResult(completion)
					case let .embark(name):
                        let (embark, embarkResult) = coordinator.presentEmbark(name: name)
						bag += coordinator.handleEmbarkResult(embark, embarkResult)
					}
				}

				return bag
			}
		)
	}
}
