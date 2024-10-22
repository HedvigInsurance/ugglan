import Apollo
import Foundation
import Kingfisher
import SwiftUI
import UniformTypeIdentifiers
import hCore
import hGraphQL

public class ChatFileUploaderService {
    @Inject var client: ChatFileUploaderClient

    func upload(
        files: [File],
        withProgress: ((_ progress: Double) -> Void)?
    ) async throws -> [ChatUploadFileResponseModel] {
        log.info("ChatFileUploaderService: upload", error: nil, attributes: nil)
        return try await client.upload(files: files, withProgress: withProgress)
    }
}

extension NetworkClient: ChatFileUploaderClient {
    public func upload(
        files: [File],
        withProgress: ((_ progress: Double) -> Void)?
    ) async throws -> [ChatUploadFileResponseModel] {
        let request = try await FileUploadRequest.uploadFile(files: files).asRequest()
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
                let data: Data? = {
                    switch file.source {
                    case .data(let data):
                        return data
                    case .localFile(let url):
                        var data: Data?
                        if let url {
                            let semaphore = DispatchSemaphore(value: 0)
                            url.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.item.identifier) {
                                imageUrl,
                                error in
                                if let imageUrl,
                                    let pathData = FileManager.default.contents(atPath: imageUrl.relativePath)
                                {
                                    data = pathData
                                }

                                semaphore.signal()
                            }
                            semaphore.wait()
                        }
                        return data
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
        let headers = ApolloClient.headers()
        headers.forEach { element in
            request.setValue(element.value, forHTTPHeaderField: element.key)
        }
        return request
    }
}
