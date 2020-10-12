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
        case .se:
            return OnboardingChat().materialize()
        case .no, .dk:
            return WebOnboarding().materialize()
        }
    }
}
