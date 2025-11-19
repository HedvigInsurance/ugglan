import Foundation
import hCore

@MainActor
public protocol hSubmitClaimFileUploadClient {
    func upload<T: Codable & Sendable>(url: URL, multipart: MultipartFormDataRequest) async throws -> T
}
