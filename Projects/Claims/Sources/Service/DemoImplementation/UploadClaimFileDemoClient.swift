import Foundation
import hCore

public class hClaimFileUploadClientDemo: hClaimFileUploadClient {
    public init() {}
    public func upload(
        endPoint: String,
        files: [File],
        withProgress: ((_ progress: Double) -> Void)?
    ) async throws -> [ClaimFileUploadResponse] {
        return []
    }
}