//
//  ApplicationState+presentRootViewController.swift
//  test
//
//  Created by Sam Pettersson on 2020-03-05.
//

import Foundation
import Common
import UIKit
import Flow
import Space

extension ApplicationState {
    static func presentRootViewController(_ window: UIWindow) -> Disposable {
        guard let applicationState = currentState
        else {
            if Localization.Locale.currentLocale == .en_SE {
                return window.present(
                    PreMarketingLanguagePicker(),
                    options: [.defaults, .prefersNavigationBarHidden(true)],
                    animated: false
                )
            } else {
                return window.present(
                    Marketing(),
                    options: [.defaults, .prefersNavigationBarHidden(true)],
                    animated: false
                ).disposable
            }
        }

        switch applicationState {
        case .languagePicker:
            return window.present(
                PreMarketingLanguagePicker(),
                options: [.defaults, .prefersNavigationBarHidden(true)],
                animated: false
            )
        case .marketing:
            return window.present(
                Marketing(),
                options: [.defaults, .prefersNavigationBarHidden(true)],
                animated: false
            ).disposable
        case .onboardingChat:
            return window.present(OnboardingChat(), options: [.defaults], animated: false)
        case .offer:
            return window.present(
                Offer(),
                options: [.defaults, .prefersNavigationBarHidden(true)],
                animated: false
            )
        case .loggedIn:
            return window.present(
                LoggedIn(),
                options: [],
                animated: false
            )
        }
    }
}
