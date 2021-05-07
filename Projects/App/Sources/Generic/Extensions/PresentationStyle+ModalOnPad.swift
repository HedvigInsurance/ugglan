import Foundation
import Presentation

extension PresentationStyle {
	static let defaultOrModal = PresentationStyle(name: "DefaultOrModal") {
		(viewController, from, options) -> PresentationStyle.Result in
		if from.traitCollection.userInterfaceIdiom == .pad {
			return PresentationStyle.modally(
				presentationStyle: .formSheet,
				transitionStyle: nil,
				capturesStatusBarAppearance: true
			).present(viewController, from: from, options: options)
		}

		return PresentationStyle.default.present(viewController, from: from, options: options)
	}
}
