import Apollo
import Environment
import Foundation
import Kingfisher
import SwiftUI
import hCore

@MainActor
public class hClaimFileUploadService {
    @Inject var client: hClaimFileUploadClient

    public init() {}

    public func upload(
        endPoint: String,
        files: [File],
        withProgress: (@Sendable (_ progress: Double) -> Void)?
    ) async throws -> [ClaimFileUploadResponse] {
        log.info("hClaimFileUploadService: upload", error: nil, attributes: nil)
        do {
            return try await client.upload(endPoint: endPoint, files: files, withProgress: withProgress)
        } catch {
            log.error("hClaimFileUploadService: upload", error: error, attributes: [:])
            throw error
        }
    }
}

public struct ClaimFileUploadResponse: Codable, Sendable {
    public let file: FileUpload?
    let error: String?
}

public struct FileUpload: Codable, Sendable {
    public let fileId: String
    public let name: String
    public let mimeType: String
    public let url: String
}
