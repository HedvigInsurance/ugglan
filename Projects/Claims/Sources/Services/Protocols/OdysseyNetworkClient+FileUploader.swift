import hCore

public protocol FileUploaderClient {
    func upload(flowId: String, file: UploadFile) async throws -> UploadFileResponseModel
}
