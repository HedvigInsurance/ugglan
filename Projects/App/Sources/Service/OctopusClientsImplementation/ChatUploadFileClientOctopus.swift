import Apollo
import Chat
import Environment
import Foundation
import Kingfisher
import SwiftUI
import hCore
import hGraphQL

@MainActor
class ChatFileUploaderService {
    @Inject var client: ChatFileUploaderClient

    func upload(
        files: [File],
        withProgress: (@Sendable (_ progress: Double) -> Void)?
    ) async throws -> [ChatUploadFileResponseModel] {
        log.info("ChatFileUploaderService: upload", error: nil, attributes: nil)
        return try await client.upload(files: files, withProgress: withProgress)
    }
}

extension NetworkClient: @retroactive ChatFileUploaderClient {
    public func upload(
        files: [File],
        withProgress: (@Sendable (_ progress: Double) -> Void)?
    ) async throws -> [ChatUploadFileResponseModel] {
        let request = try await FileUploadRequest.uploadFile(files: files).asRequest()
        var observation: NSKeyValueObservation?
        let response = try await withCheckedThrowingContinuation {
            (inCont: CheckedContinuation<[ChatUploadFileResponseModel], Error>) -> Void in
            let task = self.sessionClient.dataTask(with: request) { [weak self] (data, response, error) in
                Task {
                    do {
                        if let uploadedFiles: [ChatUploadFileResponseModel] = try await self?
                            .handleResponse(data: data, response: response, error: error)
                        {
                            inCont.resume(returning: uploadedFiles)
                        }
                    } catch let error {
                        inCont.resume(throwing: error)
                    }
                }
            }

            observation = task.progress.observe(\.fractionCompleted) { progress, _ in
                withProgress?(progress.fractionCompleted)
            }
            task.resume()
        }
        observation?.invalidate()
        return response
    }
}

enum FileUploadRequest {
    case uploadFile(files: [File])

    var baseUrl: URL {
        return Environment.current.botServiceApiURL
    }

    var methodType: String {
        switch self {
        case .uploadFile:
            return "POST"
        }
    }
    func asRequest() async throws -> URLRequest {
        var request: URLRequest!
        switch self {
        case let .uploadFile(files):
            var baseUrlString = baseUrl.absoluteString
            baseUrlString.append("api/files/upload")
            let url = URL(string: baseUrlString)!
            let multipartFormDataRequest = MultipartFormDataRequest(url: url)
            for file in files {
                let data: Data? = try await {
                    switch file.source {
                    case .data(let data):
                        return data
                    case .localFile(let results):
                        return try await results?.itemProvider.getData().data
                    case .url:
                        return nil
                    }
                }()
                guard let data else { throw NetworkError.badRequest(message: nil) }
                multipartFormDataRequest.addDataField(
                    fieldName: "files",
                    fileName: file.name,
                    data: data,
                    mimeType: file.mimeType.mime
                )
            }
            request = multipartFormDataRequest.asURLRequest()
        }
        request.httpMethod = self.methodType
        try await TokenRefresher.shared.refreshIfNeeded()
        let headers = await ApolloClient.headers()
        headers.forEach { element in
            request.setValue(element.value, forHTTPHeaderField: element.key)
        }
        return request
    }
}
