import Foundation
import hCore
import hGraphQL

protocol NotificationClient {
    func register(for token: String) async throws
}
