import Apollo
import DatadogCore
import Foundation
import SwiftUI
import hCore
import hGraphQL

protocol AnalyticsClient {
    func fetchAndSetUserId()
    func setWith(userId: String)
}
