import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

public struct MovingFlowSuccess {
	public init() {}
}

extension MovingFlowSuccess: Presentable {
	public func materialize() -> (UIViewController, Signal<Void>) {
		let viewController = UIViewController()
		let bag = DisposeBag()

		let button = Button(
			title: L10n.MovingConfirmation.Success.buttonText,
			type: .standardOutline(
				borderColor: .brand(.primaryBorderColor),
				textColor: .brand(.primaryButtonTextColor)
			)
		)

		let imageTextAction = ImageTextAction(
			image: .init(image: hCoreUIAssets.welcome.image, size: nil, contentMode: .scaleAspectFit),
			title: L10n.MovingConfirmation.Success.title,
			body: L10n.MovingConfirmation.SuccessNoDate.paragraphCopy(""),
			actions: [((), button)],
			showLogo: false
		)

		return (
			viewController,
			Signal { callback in
				bag += viewController.view
					.add(imageTextAction) { view in
						view.snp.makeConstraints { make in
							make.edges.equalToSuperview()
						}

					}
					.onValue { _ in
						callback(())
					}

				return DelayedDisposer(bag, delay: 2)
			}
		)
	}
}
