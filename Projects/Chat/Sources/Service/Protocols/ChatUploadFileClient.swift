import Foundation
import hCore

public protocol ChatFileUploaderClient {
    func upload(
        files: [File],
        withProgress: ((_ progress: Double) -> Void)?
    ) async throws -> [ChatUploadFileResponseModel]
}

public struct ChatUploadFileResponseModel: Decodable {
    let uploadToken: String
}
