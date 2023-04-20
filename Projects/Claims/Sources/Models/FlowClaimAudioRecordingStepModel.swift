import Foundation
import hGraphQL

public struct FlowClaimAudioRecordingStepModel: FlowClaimStepModel {
    let id: String
    let questions: [String]
    let audioContent: AudioContentModel?
    var url: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    init(
        with data: OctopusGraphQL.FlowClaimAudioRecordingStepFragment
    ) {
        self.id = data.id
        self.questions = data.questions
        self.audioContent = .init(with: (data.audioContent?.fragments.flowClaimAudioContentFragment))
    }
}

struct AudioContentModel: Codable, Equatable, Hashable {
    let audioUrl: String
    let signedUrl: String

    init?(
        with data: OctopusGraphQL.FlowClaimAudioContentFragment?
    ) {
        guard let data else {
            return nil
        }
        self.audioUrl = data.audioUrl
        self.signedUrl = data.signedUrl
    }
}
