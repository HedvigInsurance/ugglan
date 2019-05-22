//
//  ApplicationState.swift
//  ugglan
//
//  Created by Gustaf Gunér on 2019-05-22.
//  Hedvig
//

import Foundation

struct ApplicationState {
    enum Screen: String {
        case marketing, onboardingChat, offer, loggedIn
    }

    static func preserveState(_: Screen) {}
}
