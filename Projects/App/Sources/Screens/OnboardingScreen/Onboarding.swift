import Flow
import Foundation
import hCore
import Presentation
import UIKit
import Embark

struct Onboarding {}

extension Onboarding: Presentable {
    
    func materialize() -> (UIViewController, Disposable) {
        ApplicationState.preserveState(.onboarding)
        
        switch Localization.Locale.currentLocale.market {
        case .se:
            return OnboardingChat().materialize()
        case .dk:
            return OnboardingChat().materialize()
        case .no:
            return OnboardingFlow().materialize()
        }
    }
}
