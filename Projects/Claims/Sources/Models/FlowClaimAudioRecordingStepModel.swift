import Foundation
import hGraphQL

public struct FlowClaimAudioRecordingStepModel: FlowClaimStepModel {
    let id: String
    let questions: [String]
    //    let signedUrl: String?
    var url: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    init(
        with data: OctopusGraphQL.FlowClaimAudioRecordingStepFragment
    ) {
        self.id = data.id
        self.questions = data.questions
        //        self.signedUrl = data.signedUrl
    }
}
