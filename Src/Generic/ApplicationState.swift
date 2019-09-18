//
//  ApplicationState.swift
//  ugglan
//
//  Created by Gustaf Gunér on 2019-05-22.
//  Hedvig
//

import Flow
import Foundation
import UIKit

struct ApplicationState {
    public static let lastNewsSeenKey = "lastNewsSeen"

    enum Screen: String {
        case marketing, onboardingChat, offer, loggedIn

        func isOneOf(_ possibilities: Set<Self>) -> Bool {
            possibilities.contains(self)
        }
    }

    private static let key = "applicationState"

    static func preserveState(_ screen: Screen) {
        UserDefaults.standard.set(screen.rawValue, forKey: key)
    }

    static var currentState: Screen? {
        guard
            let applicationStateRawValue = UserDefaults.standard.value(forKey: key) as? String,
            let applicationState = Screen(rawValue: applicationStateRawValue) else {
            return nil
        }
        return applicationState
    }

    static func hasPreviousState() -> Bool {
        return UserDefaults.standard.value(forKey: key) as? String != nil
    }

    static func hasLastNewsSeen() -> Bool {
        return UserDefaults.standard.value(forKey: lastNewsSeenKey) as? String != nil
    }

    static func getLastNewsSeen() -> String {
        return UserDefaults.standard.string(forKey: ApplicationState.lastNewsSeenKey) ?? "0.0.0"
    }

    static func setLastNewsSeen() {
        UserDefaults.standard.set(Bundle.main.appVersion, forKey: ApplicationState.lastNewsSeenKey)
    }

    static func presentRootViewController(_ window: UIWindow) -> Disposable {
        guard let applicationState = currentState
        else { return window.present(
            Marketing(),
            options: [.defaults, .prefersNavigationBarHidden(true)],
            animated: false
        ).disposable }

        switch applicationState {
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
