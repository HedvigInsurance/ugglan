import Apollo
import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hGraphQL

struct OfferChat {
	@Inject var client: ApolloClient
}

extension OfferChat: Presentable {
	func materialize() -> (UIViewController, Future<Void>) {
		let bag = DisposeBag()
		let chat = Chat()
		let (viewController, future) = chat.materialize()

		let restartButton = UIBarButtonItem()
		restartButton.image = Asset.restart.image
		restartButton.tintColor = .darkGray

		bag += restartButton.onValue { _ in
			let alert = Alert(
				title: L10n.chatRestartAlertTitle,
				message: L10n.chatRestartAlertMessage,
				actions: [
					Alert.Action(
						title: L10n.chatRestartAlertConfirm,
						action: {
							UIView.transition(
								with: UIApplication.shared.appDelegate.appFlow.window,
								duration: 0.25,
								options: .transitionCrossDissolve,
								animations: {
									ApplicationState.preserveState(.onboarding)
									UIApplication.shared.appDelegate.logout()
								},
								completion: nil
							)
						}
					),
					Alert.Action(
						title: L10n.chatRestartAlertCancel,
						action: {}
					),
				]
			)

			viewController.present(alert)
		}

		viewController.navigationItem.leftBarButtonItem = restartButton

		viewController.navigationItem.titleView = .titleWordmarkView

		return (
			viewController,
			Future { completion in
				bag += future.onResult { result in
					completion(result)
				}

				return bag
			}
		)
	}
}
