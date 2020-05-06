//
//  Onboarding.swift
//  test
//
//  Created by Sam Pettersson on 2020-03-19.
//

import Flow
import Foundation
import Presentation
import UIKit

struct Onboarding {}

extension Onboarding: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        ApplicationState.preserveState(.onboarding)
        
        switch Localization.Locale.currentLocale.market {
        case .se:
            return Embark(name: "Web Onboarding - Swedish Needer").materialize()
        case .no:
            return WebOnboarding().materialize()
        }
    }
}
