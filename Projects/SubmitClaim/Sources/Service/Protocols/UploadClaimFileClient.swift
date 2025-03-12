import Foundation
import hCore

@MainActor
public protocol hClaimFileUploadClient {
    func upload(
        endPoint: String,
        files: [File],
        withProgress: (@Sendable (_ progress: Double) -> Void)?
    ) async throws -> [ClaimFileUploadResponse]
}
