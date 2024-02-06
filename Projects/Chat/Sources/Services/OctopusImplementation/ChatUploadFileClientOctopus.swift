import Apollo
import Foundation
import Kingfisher
import UIKit
import hCore
import hGraphQL

extension NetworkClient: ChatFileUploaderClient {
    public func upload(
        files: [File],
        withProgress: ((_ progress: Double) -> Void)?
    ) async throws -> [ChatUploadFileResponseModel] {
        let request = try! await FileUploadRequest.uploadFile(files: files).asRequest()
        var observation: NSKeyValueObservation?
        let response = try await withCheckedThrowingContinuation {
            (inCont: CheckedContinuation<[ChatUploadFileResponseModel], Error>) -> Void in
            let task = self.sessionClient.dataTask(with: request) { [weak self] (data, response, error) in
                do {
                    if let uploadedFiles: [ChatUploadFileResponseModel] = try self?
                        .handleResponse(data: data, response: response, error: error)
                    {
                        inCont.resume(returning: uploadedFiles)
                    }
                } catch let error {
                    inCont.resume(throwing: error)
                }
            }

            observation = task.progress.observe(\.fractionCompleted) { progress, _ in
                withProgress?(progress.fractionCompleted)
            }
            task.resume()
        }
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
                guard case let .localFile(url, _) = file.source,
                    let data = try? Data(contentsOf: url) /*FileManager.default.contents(atPath: url.path)*/
                else { throw NetworkError.badRequest(message: nil) }
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
        try await TokenRefresher.shared.refreshIfNeededAsync()
        let headers = ApolloClient.headers()
        headers.forEach { element in
            request.setValue(element.value, forHTTPHeaderField: element.key)
        }
        return request
    }
}
