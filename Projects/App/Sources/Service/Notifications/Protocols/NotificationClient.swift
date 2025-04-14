import Foundation
import hCore

@MainActor
protocol NotificationClient {
    func register(for token: String) async throws
}
