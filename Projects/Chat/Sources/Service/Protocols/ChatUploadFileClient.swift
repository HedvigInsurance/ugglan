import Foundation
import hCore

@MainActor
public protocol ChatFileUploaderClient {
    func upload(
        files: [File],
        withProgress: (@Sendable (_ progress: Double) -> Void)?
    ) async throws -> [ChatUploadFileResponseModel]
}

public struct ChatUploadFileResponseModel: Decodable, Sendable {
    public let uploadToken: String
}
