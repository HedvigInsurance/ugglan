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

    init?(
        with data: OctopusGraphQL.FlowClaimFileUploadStepFragment?
    ) {
        guard let data else {
            return nil
        }
        self.id = data.id
        self.title = data.title
        self.targetUploadUrl = data.targetUploadUrl
        self.uploads = data.uploads.compactMap({
            FlowClaimFileUploadStepFileModel(
                fileId: $0.fileId,
                signedUrl: $0.signedUrl,
                mimeType: $0.mimeType,
                name: $0.name
            )
        })
    }
}

struct FlowClaimFileUploadStepFileModel: Codable, Equatable, Hashable {
    let fileId: String
    let signedUrl: String
    let mimeType: String
    let name: String

    init(fileId: String, signedUrl: String, mimeType: String, name: String) {
        self.fileId = fileId
        self.signedUrl = signedUrl
        self.mimeType = mimeType
        self.name = name
    }
}
