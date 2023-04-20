import Foundation
import hGraphQL

public struct FlowClaimAudioRecordingStepModel: FlowClaimStepModel {
    let id: String
    let questions: [String]
    var audioContent: AudioContentModel?
    
    init(
        with data: OctopusGraphQL.FlowClaimAudioRecordingStepFragment
    ) {
        self.id = data.id
        self.questions = data.questions
        self.audioContent = .init(with: (data.audioContent?.fragments.flowClaimAudioContentFragment))
    }
    
    func getUrl() -> URL? {
        guard let url = audioContent?.signedUrl else { return nil}
        return URL(string: url)
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
