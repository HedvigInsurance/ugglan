import AutomaticLog
import Foundation
import hCore

@MainActor
public protocol ChatFileUploaderClient {
    func upload(
        files: [File],
        withProgress: (@Sendable (_ progress: Double) -> Void)?
    ) async throws -> [ChatUploadFileResponseModel]
}

@Loggable
public struct ChatUploadFileResponseModel: Decodable, Sendable {
    @Masked public let uploadToken: String
}
