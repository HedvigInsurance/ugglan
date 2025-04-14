import Claims
import hCore

@MainActor
public class FileUploaderService {
    @Inject var client: FileUploaderClient

    public init() {}

    public func upload(flowId: String, file: UploadFile) async throws -> UploadFileResponseModel {
        log.info("\(FileUploaderService.self): upload flowId \(flowId)")
        let data = try await client.upload(flowId: flowId, file: file)
        log.info("\(FileUploaderService.self): response for upload flowId \(flowId) is \(data)")
        return data
    }
}

@MainActor
public protocol FileUploaderClient {
    func upload(flowId: String, file: UploadFile) async throws -> UploadFileResponseModel
}
