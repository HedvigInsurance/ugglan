import Foundation
import hCore
import hGraphQL

@MainActor
protocol NotificationClient {
    func register(for token: String) async throws
}
