import Apollo
import DatadogCore
import Foundation
import SwiftUI
import hCore

@MainActor
protocol AnalyticsClient {
    func fetchUserId() async throws -> String
    func setWith(userId: String)
    func setDeviceInfo(model: MemberLogDeviceModel) async
}

struct MemberLogDeviceModel: Encodable {
    let os: String
    let brand: String
    let model: String
    let pushNotificationEnabled: Bool
}
