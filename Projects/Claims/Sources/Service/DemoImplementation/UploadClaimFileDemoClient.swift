import Foundation
import hCore

public class hClaimFileUploadClientDemo: hClaimFileUploadClient {
    public init() {}
    public func upload(
        endPoint _: String,
        files _: [File],
        withProgress _: (@Sendable (_ progress: Double) -> Void)?
    ) async throws -> [ClaimFileUploadResponse] {
        []
    }

    public func uploadClaimsChatFile(
        endPoint: String,
        files: [hCore.File],
        withProgress: (@Sendable (Double) -> Void)?
    ) async throws -> [String] {
        []
    }
}
