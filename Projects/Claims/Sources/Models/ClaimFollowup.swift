import Foundation

public struct ClaimFollowup: Codable, Equatable, Hashable, Identifiable, Sendable {
    public let id: String
    public let claimId: String
    public let status: Status
    public let questions: [ClaimFollowupQuestion]

    public init(id: String, claimId: String, status: Status, questions: [ClaimFollowupQuestion]) {
        self.id = id
        self.claimId = claimId
        self.status = status
        self.questions = questions
    }

    public var isOpen: Bool { status == .submitted }
    public var questionsLeft: Int { questions.filter { $0.state == .todo }.count }
    public var canSend: Bool { isOpen && questionsLeft == 0 }

    public enum Status: String, Codable, Sendable {
        case submitted
        case completed
    }
}

public struct ClaimFollowupQuestion: Codable, Equatable, Hashable, Identifiable, Sendable {
    public let id: String
    public let text: String
    /// A short line shown under the question, set by the handler.
    public let hint: String?
    /// The question's own wording for passing on it; the app falls back to a generic one when nil.
    public let cantAnswerLabel: String?
    public let state: State
    public let cantAnswerComment: String?
    public let content: Content

    public init(
        id: String,
        text: String,
        hint: String? = nil,
        cantAnswerLabel: String? = nil,
        state: State,
        cantAnswerComment: String?,
        content: Content
    ) {
        self.id = id
        self.text = text
        self.hint = hint
        self.cantAnswerLabel = cantAnswerLabel
        self.state = state
        self.cantAnswerComment = cantAnswerComment
        self.content = content
    }

    public enum State: String, Codable, Sendable {
        case todo
        case answered
        case cantAnswer
    }

    public enum Content: Codable, Equatable, Hashable, Sendable {
        case binary(currentValue: Bool?)
        case freeText(minLength: Int, maxLength: Int, currentValue: String?, currentAudio: ClaimFollowupFile?)
        /// `min` and `max` are advisory `yyyy-MM-dd` dates: the app warns outside them and never blocks.
        case date(currentValue: String?, min: String?, max: String?)
        case number(currentValue: String?, min: Int?, max: Int?)
        case phoneNumber(currentValue: String?)
        case fileUpload(currentFiles: [ClaimFollowupFile])
    }
}

public struct ClaimFollowupFile: Codable, Equatable, Hashable, Identifiable, Sendable {
    public let id: String
    public let url: URL
    public let contentType: String
    public let fileName: String
    public let relevance: ClaimFollowupFileRelevance

    public init(id: String, url: URL, contentType: String, fileName: String, relevance: ClaimFollowupFileRelevance) {
        self.id = id
        self.url = url
        self.contentType = contentType
        self.fileName = fileName
        self.relevance = relevance
    }
}

public enum ClaimFollowupFileRelevance: String, Codable, Sendable {
    case match
    case mismatch
    case unknown
}

public struct ClaimFollowupUploadedFile: Equatable, Sendable {
    public let fileId: String
    public let relevance: ClaimFollowupFileRelevance

    public init(fileId: String, relevance: ClaimFollowupFileRelevance) {
        self.fileId = fileId
        self.relevance = relevance
    }
}
