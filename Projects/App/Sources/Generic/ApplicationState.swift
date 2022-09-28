import Flow
import Foundation
import Market
import Offer
import UIKit
import hCore
import hCoreUI
import hGraphQL

extension ApplicationState {
    public static let lastNewsSeenKey = "lastNewsSeen"

    static func getLastNewsSeen() -> String {
        UserDefaults.standard.string(forKey: ApplicationState.lastNewsSeenKey) ?? "2.8.3"
    }

    static func setLastNewsSeen() {
        UserDefaults.standard.set(Bundle.main.appVersion, forKey: ApplicationState.lastNewsSeenKey)
    }
}
