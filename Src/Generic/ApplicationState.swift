//
//  ApplicationState.swift
//  ugglan
//
//  Created by Gustaf Gunér on 2019-05-22.
//  Hedvig
//

import Foundation

struct ApplicationState {
    public static let lastNewsSeenKey = "lastNewsSeen"

    enum Screen: String {
        case marketing, onboardingChat, offer, loggedIn
    }

    static func preserveState(_: Screen) {}

    static func getLastNewsSeen() -> String {
        return UserDefaults.standard.string(forKey: ApplicationState.lastNewsSeenKey) ?? "0.0.0"
    }

    static func setLastNewsSeen() { UserDefaults.standard.set(Bundle.main.appVersion, forKey: ApplicationState.lastNewsSeenKey)
    }
}
