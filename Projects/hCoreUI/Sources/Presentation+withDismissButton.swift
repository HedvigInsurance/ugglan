import Flow
import Foundation
import Presentation
import UIKit

extension JourneyPresentation {
	public var withDismissButton: Self {
		let closeButton = CloseButton()
		let closeButtonItem = UIBarButtonItem(viewable: closeButton)

		var onDismiss: () -> Void = {}

		let newPresentation = addConfiguration { viewController, bag in
			// move over any barButtonItems to the other side
			if viewController.navigationItem.rightBarButtonItems != nil {
				viewController.navigationItem.leftBarButtonItems =
					viewController.navigationItem.rightBarButtonItems
			}

			bag += closeButton.onTapSignal.onValue { _ in
				onDismiss()
			}

			viewController.navigationItem.rightBarButtonItem = closeButtonItem
		}

		onDismiss = {
			newPresentation.onDismiss(JourneyError.dismissed)
		}

		return newPresentation
	}
}
