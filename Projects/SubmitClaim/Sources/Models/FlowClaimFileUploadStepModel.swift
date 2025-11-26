import Foundation

public struct FlowClaimFileUploadStepModel: FlowClaimStepModel {
    let targetUploadUrl: String
    let uploads: [FlowClaimFileUploadStepFileModel]

    public init(
        targetUploadUrl: String,
        uploads: [FlowClaimFileUploadStepFileModel]
    ) {
        self.targetUploadUrl = targetUploadUrl
        self.uploads = uploads
    }
}

public struct FlowClaimFileUploadStepFileModel: Codable, Equatable, Hashable, Sendable {
    let fileId: String
    let signedUrl: String
    let mimeType: String
    let name: String

    public init(fileId: String, signedUrl: String, mimeType: String, name: String) {
        self.fileId = fileId
        self.signedUrl = signedUrl
        self.mimeType = mimeType
        self.name = name
    }
}
