import Apollo
import Foundation
import hCore
import hGraphQL

public protocol hClaimFileUploadService {
    func upload(
        endPoint: String,
        files: [File],
        withProgress: ((_ progress: Double) -> Void)?
    ) async throws -> [String: String?]
}

public class hClaimFileUploadServiceDemo {
    func upload(
        endPoint: String,
        files: [File],
        withProgress: ((_ progress: Double) -> Void)?
    ) async throws -> [String: String?] {
        return [:]
    }
}

extension NetworkClient: hClaimFileUploadService {
    public func upload(
        endPoint: String,
        files: [File],
        withProgress: ((_ progress: Double) -> Void)?
    ) async throws -> [String: String?] {
        let request = try! await ClaimsRequest.uploadFile(endPoint: endPoint, files: files).asRequest()
        var observation: NSKeyValueObservation?
        let response = try await withCheckedThrowingContinuation {
            (inCont: CheckedContinuation<[ClaimFileUploadResponse], Error>) -> Void in
            let task = self.sessionClient.dataTask(with: request) { [weak self] (data, response, error) in
                do {
                    if let data: [ClaimFileUploadResponse] = try self?
                        .handleResponse(data: data, response: response, error: error)
                    {
                        inCont.resume(returning: data)
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
        var result = [String: String?]()
        for (index, file) in files.enumerated() {
            result[file.id] = response[index].file?.fileId
        }
        return result
    }
}

struct ClaimFileUploadResponse: Codable {
    let file: FileUpload?
    let error: String?
}

struct FileUpload: Codable {
    let fileId: String
}

enum ClaimsRequest {
    case uploadFile(endPoint: String, files: [File])

    var baseUrl: URL {
        return Environment.current.claimsApiURL
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
        case let .uploadFile(endPoint, files):
            var baseUrlString = baseUrl.absoluteString
            baseUrlString.append(endPoint)
            let url = URL(string: baseUrlString)!
            let multipartFormDataRequest = MultipartFormDataRequest(url: url)
            for file in files {
                guard case let .data(data) = file.source else { throw NetworkError.badRequest(message: nil) }
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
