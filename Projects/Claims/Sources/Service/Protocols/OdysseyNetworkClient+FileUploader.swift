import hCore

@MainActor
public protocol FileUploaderClient: Sendable {
    func upload(flowId: String, file: UploadFile) async throws -> UploadFileResponseModel
}
