import Foundation
import hCore

public protocol hClaimFileUploadService {
    func upload(
        endPoint: String,
        files: [File],
        withProgress: ((_ progress: Double) -> Void)?
    ) async throws -> [ClaimFileUploadResponse]
}
