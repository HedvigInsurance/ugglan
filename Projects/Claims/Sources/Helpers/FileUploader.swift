import Flow
import Foundation

protocol FileUploaderClient {
    func upload(request: MultipartFormDataRequest) async throws -> Result<Void>
}

struct OdysseyUploaderClient: FileUploaderClient {

    let session: URLSession = {
        let config = URLSessionConfiguration.default
        let newSession = URLSession(configuration: config)
        return newSession
    }()

    func upload(request: MultipartFormDataRequest) async throws -> Flow.Result<Void> {
        let session = URLSession.shared
        let request = request.asURLRequest()
        let task = try await session.data(for: request)  //session.dataTask(with: request)
        return Flow.Result.success
    }
}
