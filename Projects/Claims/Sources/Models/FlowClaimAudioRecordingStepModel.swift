import Foundation
import hGraphQL

public struct FlowClaimAudioRecordingStepModel: FlowClaimStepModel {
    let id: String
    let questions: [String]
    var audioContent: AudioContentModel?
    let textQuestions: [String]
    let inputTextContent: String?
    let optionalAudio: Bool

    init(
        id: String,
        questions: [String],
        audioContent: AudioContentModel? = nil,
        textQuestions: [String],
        inputTextContent: String?,
        optionalAudio: Bool
    ) {
        self.id = id
        self.questions = questions
        self.audioContent = audioContent
        self.textQuestions = textQuestions
        self.inputTextContent = inputTextContent
        self.optionalAudio = optionalAudio
    }

    init?(
        with data: OctopusGraphQL.FlowClaimAudioRecordingStepFragment?
    ) {
        guard let data else {
            return nil
        }
        self.id = data.id
        self.questions = data.questions
        self.audioContent = .init(with: (data.audioContent?.fragments.flowClaimAudioContentFragment))
        self.textQuestions = data.freeTextQuestions
        self.inputTextContent = data.freeText
        self.optionalAudio = data.freeTextAvailable
    }

    func getUrl() -> URL? {
        guard let url = audioContent?.signedUrl else { return nil }
        return URL(string: url)
    }

    func isAudioInput() -> Bool {
        guard optionalAudio else { return true }
        return inputTextContent == nil
    }
}

struct AudioContentModel: Codable, Equatable, Hashable {
    let audioUrl: String
    let signedUrl: String

    init(audioUrl: String, signedUrl: String) {
        self.audioUrl = audioUrl
        self.signedUrl = signedUrl
    }

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
