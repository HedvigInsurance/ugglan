import Flow
import Foundation
import Market
import UIKit
import hCore
import hCoreUI
import hGraphQL

extension ApplicationState {
    private static let firebaseMessagingTokenKey = "firebaseMessagingToken"

    static func setFirebaseMessagingToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: ApplicationState.firebaseMessagingTokenKey)
    }

    static func getFirebaseMessagingToken() -> String? {
        UserDefaults.standard.value(forKey: firebaseMessagingTokenKey) as? String
    }

    public static let lastNewsSeenKey = "lastNewsSeen"

    static func getLastNewsSeen() -> String {
        UserDefaults.standard.string(forKey: ApplicationState.lastNewsSeenKey) ?? "2.8.3"
    }
}
