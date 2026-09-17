import AppIntents
import Foundation
import hCore

@available(iOS 16.0, *)
public struct FileClaimAppIntent: AppIntent {
    public static let title: LocalizedStringResource = "File a claim"
    public static let description = IntentDescription(
        "Start a new insurance claim with Hedvig."
    )
    public static let openAppWhenRun: Bool = true

    public init() {}

    @MainActor
    public func perform() async throws -> some IntentResult {
        let service: PendingAppIntentServiceProtocol = Dependencies.shared.resolve()
        service.store(.fileNewClaim)
        log.info("AppIntent fired: fileNewClaim", error: nil, attributes: nil)
        return .result()
    }
}
