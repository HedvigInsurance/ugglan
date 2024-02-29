import Flow
import Foundation
import hCore

public protocol FileUploaderClient {
    func upload(flowId: String, file: UploadFile) async throws -> UploadFileResponseModel
}

enum FileUploadError: Error {
    case error(message: String)
}
extension FileUploadError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .error(message): return message
        }
    }
}

extension NetworkClient: FileUploaderClient {
    public func upload(flowId: String, file: UploadFile) async throws -> UploadFileResponseModel {
        let request = try await OdysseyRequest.uploadAudioFile(flowId: flowId, file: file).asRequest()
        let (data, response) = try await self.sessionClient.data(for: request)
        let responseModel: UploadFileResponseModel? = try self.handleResponse(
            data: data,
            response: response,
            error: nil
        )
        if let responseModel {
            return responseModel
        }
        throw FileUploadError.error(message: L10n.General.errorBody)
    }
}
