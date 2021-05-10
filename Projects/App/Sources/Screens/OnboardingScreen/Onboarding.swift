import Embark
import Flow
import Foundation
import hCore
import Presentation
import UIKit

struct Onboarding {}

extension Onboarding: Presentable {
	func materialize() -> (UIViewController, Disposable) {
		ApplicationState.preserveState(.onboarding)
		switch Localization.Locale.currentLocale.market {
		case .se: return OnboardingChat().materialize()
		case .dk:
			let (viewController, signal) = WebOnboardingFlow(webScreen: .webOnboarding).materialize()
			return (viewController, signal.nil())
		case .no: return EmbarkOnboardingFlow().materialize()
		}
	}
}
