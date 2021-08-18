import Flow
import Foundation
import Presentation
import UIKit

extension JourneyPresentation {
	/// set title of JourneyPresentations view controller
	public func configureTitle(_ title: String) -> Self {
		addConfiguration { presenter in
			presenter.viewController.title = title
		}
	}
}
