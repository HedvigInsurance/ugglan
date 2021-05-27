import Flow
import Foundation
import hCore
import hCoreUI
import Presentation
import UIKit

enum AdyenError: Error { case cancelled, tokenization, action, failed }

extension AdyenError: Presentable {
	func materialize() -> (UIViewController, Future<Void>) {
		let tryAgainButton = Button(
			title: L10n.PayInError.retryButton,
			type: .standard(
				backgroundColor: .brand(.secondaryButtonBackgroundColor),
				textColor: .brand(.secondaryButtonTextColor)
			)
		)

		let cancelButton = Button(
			title: L10n.PayInError.postponeButton,
			type: .standardOutline(borderColor: .brand(.primaryText()), textColor: .brand(.primaryText()))
		)

		let didFailAction = ImageTextAction<Bool>(
			image: .init(
				image: hCoreUIAssets.warningTriangle.image,
				size: CGSize(width: 32, height: 32),
				contentMode: .scaleAspectFit,
				insets: UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
			),
			title: L10n.PayInError.headline,
			body: L10n.PayInError.body,
			actions: [(true, tryAgainButton), (false, cancelButton)],
			showLogo: false
		)

		let (viewController, signal) = PresentableViewable(viewable: didFailAction) { viewController in
			viewController.navigationItem.hidesBackButton = true
		}
		.materialize()

		return (
			viewController,
			Future { completion in let bag = DisposeBag()

				bag += signal.onValue { shouldRetry in
					if shouldRetry {
						completion(.success)
					} else {
						completion(.failure(AdyenError.cancelled))
					}
				}

				return DelayedDisposer(bag, delay: 2)
			}
		)
	}
}
