import Apollo
import DatadogCore
import Foundation
import SwiftUI
import hCore
import hGraphQL

@MainActor
protocol AnalyticsClient {
    func fetchAndSetUserId() async throws
    func setWith(userId: String)
}
