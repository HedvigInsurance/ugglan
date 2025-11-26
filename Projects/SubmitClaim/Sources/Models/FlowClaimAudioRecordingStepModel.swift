import Foundation

public struct FlowClaimAudioRecordingStepModel: FlowClaimStepModel {
    let questions: [String]
    public internal(set) var audioContent: AudioContentModel?
    let textQuestions: [String]
    let inputTextContent: String?
    let optionalAudio: Bool

    public init(
        questions: [String],
        audioContent: AudioContentModel? = nil,
        textQuestions: [String],
        inputTextContent: String?,
        optionalAudio: Bool
    ) {
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

public struct AudioContentModel: Codable, Equatable, Hashable, Sendable {
    public let audioUrl: String
    let signedUrl: String

    public init(audioUrl: String, signedUrl: String) {
        self.audioUrl = audioUrl
        self.signedUrl = signedUrl
    }
}

public enum SubmitAudioRecordingType: Hashable {
    case audio(url: URL)
    case text(text: String)
}
