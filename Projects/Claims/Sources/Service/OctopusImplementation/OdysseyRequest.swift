import Apollo
import Foundation
import hCore
import hGraphQL

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
        var headers = ApolloClient.headers()
        headers["Odyssey-Platform"] = "ios"
        headers.forEach { element in
            request.setValue(element.value, forHTTPHeaderField: element.key)
        }
        return request
    }
}
