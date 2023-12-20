import Foundation
import hGraphQL

public struct FlowClaimFileUploadStepModel: FlowClaimStepModel {
    let id: String
    let title: String
    let targetUploadUrl: String
    let uploads: [FlowClaimFileUploadStepFileModel]

    init(
        id: String,
        title: String,
        targetUploadUrl: String,
        uploads: [FlowClaimFileUploadStepFileModel]
    ) {
        self.id = id
        self.title = title
        self.targetUploadUrl = targetUploadUrl
        self.uploads = uploads
    }

    init(
        with data: OctopusGraphQL.FlowClaimFileUploadStepFragment
    ) {
        self.id = data.id
        self.title = data.title
        self.targetUploadUrl = data.targetUploadUrl
        self.uploads = data.uploads.compactMap({
            FlowClaimFileUploadStepFileModel(fileId: $0.fileId, signedUrl: $0.signedUrl)
        })
    }
}

struct FlowClaimFileUploadStepFileModel: Codable, Equatable, Hashable {
    let fileId: String
    let signedUrl: String

    init(fileId: String, signedUrl: String) {
        self.fileId = fileId
        self.signedUrl = signedUrl
    }
}
