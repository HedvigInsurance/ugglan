import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

public struct InvitationScreen {
	let potentialDiscountAmountSignal: ReadSignal<MonetaryAmount?>

	public init(potentialDiscountAmountSignal: ReadSignal<MonetaryAmount?>) {
		self.potentialDiscountAmountSignal = potentialDiscountAmountSignal
	}
}

extension InvitationScreen: Presentable {
	public func materialize() -> (UIViewController, Future<Void>) {
		let viewController = UIViewController()
		let bag = DisposeBag()

		let imageTextAction = ImageTextAction<Void>(
			image: ImageWithOptions(image: Asset.invitationIllustration.image),
			title: L10n.ReferralsIntroScreen.title,
			body: "",
			actions: [
				(
					(),
					Button(
						title: L10n.ReferralsIntroScreen.button,
						type: .standard(
							backgroundColor: .brand(.primaryButtonBackgroundColor),
							textColor: .brand(.primaryButtonTextColor)
						)
					)
				)
			],
			showLogo: false
		)

		bag += potentialDiscountAmountSignal.atOnce().compactMap { $0 }.map {
			L10n.ReferralsIntroScreen.body($0.formattedAmount)
		}.bindTo(imageTextAction.$body)

		return (
			viewController,
			Future { completion in
				bag += viewController.install(imageTextAction).onValue { completion(.success) }

				return DelayedDisposer(bag, delay: 2)
			}
		)
	}
}
