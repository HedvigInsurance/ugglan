import Foundation
import hCore

public protocol hClaimFileUploadClient {
    func upload(
        endPoint: String,
        files: [File],
        withProgress: ((_ progress: Double) -> Void)?
    ) async throws -> [ClaimFileUploadResponse]
}
