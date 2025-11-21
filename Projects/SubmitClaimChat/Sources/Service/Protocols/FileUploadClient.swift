import Foundation
import hCore

@MainActor
public protocol hSubmitClaimFileUploadClient: Sendable {
    func upload<T: Codable & Sendable>(
        url: URL,
        multipart: MultipartFormDataRequest,
        withProgress: (@Sendable (_ progress: Double) -> Void)?
    ) async throws -> T
}
