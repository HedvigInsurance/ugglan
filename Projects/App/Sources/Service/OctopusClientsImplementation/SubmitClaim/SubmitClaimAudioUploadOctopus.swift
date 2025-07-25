import Apollo
import Claims
import Environment
import Foundation
import SubmitClaim
import hCore
import hGraphQL

extension NetworkClient: @retroactive FileUploaderClient {
    public func upload(flowId: String, file: UploadFile) async throws -> UploadFileResponseModel {
        let request = try await OdysseyRequest.uploadAudioFile(flowId: flowId, file: file).asRequest()
        let (data, response) = try await self.sessionClient.data(for: request)
        let responseModel: UploadFileResponseModel? = try await self.handleResponse(
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

private enum OdysseyRequest: Sendable {
    case uploadAudioFile(flowId: String, file: UploadFile)

    private var baseUrl: URL {
        return Environment.current.odysseyApiURL
    }

    private var methodType: String {
        switch self {
        case .uploadAudioFile:
            return "POST"
        }
    }

    func asRequest() async throws -> URLRequest {
        var request: URLRequest!
        switch self {
        case let .uploadAudioFile(flowId, file):
            var baseUrlString = baseUrl.absoluteString
            baseUrlString.append("/api/flows/\(flowId)/audio-recording")
            let url = URL(string: baseUrlString)!
            let multipartFormDataRequest = MultipartFormDataRequest(url: url)
            multipartFormDataRequest.addDataField(
                fieldName: file.name,
                fileName: file.name,
                data: file.data,
                mimeType: file.mimeType
            )
            request = multipartFormDataRequest.asURLRequest()
        }
        request.httpMethod = self.methodType
        try await TokenRefresher.shared.refreshIfNeeded()
        var headers = await ApolloClient.headers()
        headers["Odyssey-Platform"] = "ios"
        headers.forEach { element in
            request.setValue(element.value, forHTTPHeaderField: element.key)
        }
        return request
    }
}

private enum FileUploadError: Error {
    case error(message: String)
}

extension FileUploadError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .error(message): return message
        }
    }
}
