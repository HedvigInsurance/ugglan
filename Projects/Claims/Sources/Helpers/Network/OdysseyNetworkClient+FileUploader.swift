import Flow
import Foundation
import hGraphQL

public protocol FileUploaderClient {
    func upload(flowId: String, file: UploadFile) throws -> Future<Void>
}

extension OdysseyNetworkClient: FileUploaderClient {
    public func upload(flowId: String, file: UploadFile) throws -> Future<Void> {
        return Future { completion in
            OdysseyRequest.uploadAudioFile(flowId: flowId, file: file).asRequest
                .onValue { request in
                    let task = self.sessionClient.dataTask(with: request) { data, response, error in
                        completion(.success(()))
                    }
                    task.resume()
                }
            return NilDisposer()
        }
    }
}

enum OdysseyRequest {
    case uploadAudioFile(flowId: String, file: UploadFile)

    var baseUrl: URL {
        return Environment.current.odysseyApiURL
    }

    var methodType: String {
        switch self {
        case .uploadAudioFile:
            return "POST"
        }
    }

    var asRequest: Future<URLRequest> {
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
        return Future { completion in
            TokenRefresher.shared.refreshIfNeeded()
                .onValue {
                    if let token = TokenRefresher.shared.getAccessToken() {
                        request.setValue(token, forHTTPHeaderField: "Authorization")
                    }
                    completion(.success(request))
                }
            return NilDisposer()
        }

    }
}
