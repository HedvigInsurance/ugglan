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

public enum SubmitAudioRecordingType: Hashable {
    case audio(url: URL)
    case text(text: String)
}
