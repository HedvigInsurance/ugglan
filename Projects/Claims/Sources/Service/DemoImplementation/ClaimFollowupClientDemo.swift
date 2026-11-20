import Foundation
import hCore

/// Stateful in-memory fake that mimics the claims-service rules until the Octopus schema is published.
public final class ClaimFollowupClientDemo: hClaimFollowupClient {
    @Inject private var claimsClient: hFetchClaimsClient
    private var followup: ClaimFollowup?
    private var stagedFiles: [String: ClaimFollowupFile] = [:]
    private var stagedAudio: [String: URL] = [:]
    private var hasUploadedImage = false

    public init() {}

    public func getFollowups() async throws -> [ClaimFollowup] {
        try await delay()
        if followup == nil, let claimId = try? await claimsClient.getActiveClaims().first?.id {
            let created = Self.makeFollowup(claimId: claimId)
            // The seeded answer counts as an earlier upload, as on the server, so re-answering with its id works.
            for question in created.questions {
                if case let .fileUpload(files) = question.content {
                    files.forEach { stagedFiles[$0.id] = $0 }
                }
            }
            followup = created
        }
        return followup.map { [$0] } ?? []
    }

    public func answer(
        followupId: String,
        questionId: String,
        answer: ClaimFollowupAnswer
    ) async throws -> ClaimFollowup {
        try await delay()
        let (current, question) = try find(followupId: followupId, questionId: questionId)
        guard current.isOpen else { return current }
        let content: ClaimFollowupQuestion.Content
        switch (answer, question.content) {
        case let (.binary(value), .binary):
            content = .binary(currentValue: value)
        case let (.freeText(text), .freeText(minLength, maxLength, _, _)):
            guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw ClaimFollowupError.userError(message: "The answer cannot be empty")
            }
            guard text.count <= 2000 else {
                throw ClaimFollowupError.userError(message: "The answer can be at most 2000 characters")
            }
            content = .freeText(minLength: minLength, maxLength: maxLength, currentValue: text, currentAudio: nil)
        case let (.audio(fileId), .freeText(minLength, maxLength, _, _)):
            guard let url = stagedAudio[fileId] else {
                throw ClaimFollowupError.userError(message: "The file was not uploaded to this follow-up")
            }
            let audio = ClaimFollowupFile(
                id: fileId,
                url: url,
                contentType: "audio/m4a",
                fileName: "recording.m4a",
                relevance: .unknown
            )
            content = .freeText(minLength: minLength, maxLength: maxLength, currentValue: nil, currentAudio: audio)
        case let (.date(value), .date(_, min, max)):
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd"
            guard formatter.date(from: value) != nil else {
                throw ClaimFollowupError.userError(message: "The answer must be a date (yyyy-MM-dd)")
            }
            content = .date(currentValue: value, min: min, max: max)
        case let (.number(value), .number(_, min, max)):
            guard let number = Int(value) else {
                throw ClaimFollowupError.userError(message: "The answer must be a whole number")
            }
            content = .number(currentValue: String(number), min: min, max: max)
        case let (.phoneNumber(value), .phoneNumber):
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                throw ClaimFollowupError.userError(message: "The phone number cannot be empty")
            }
            content = .phoneNumber(currentValue: trimmed)
        case let (.files(fileIds), .fileUpload):
            guard !fileIds.isEmpty else { throw ClaimFollowupError.userError(message: "Add at least one file") }
            let files = fileIds.compactMap { stagedFiles[$0] }
            guard files.count == fileIds.count else {
                throw ClaimFollowupError.userError(message: "The file was not uploaded to this follow-up")
            }
            content = .fileUpload(currentFiles: files)
        default:
            throw ClaimFollowupError.userError(message: "This question expects a different kind of answer")
        }
        return replace(question, state: .answered, comment: nil, content: content, in: current)
    }

    public func cantAnswer(followupId: String, questionId: String, comment: String?) async throws -> ClaimFollowup {
        try await delay()
        let (current, question) = try find(followupId: followupId, questionId: questionId)
        guard current.isOpen else { return current }
        let trimmedComment = comment?.trimmingCharacters(in: .whitespacesAndNewlines)
        return replace(
            question,
            state: .cantAnswer,
            comment: trimmedComment?.isEmpty == false ? trimmedComment : nil,
            content: question.content.cleared,
            in: current
        )
    }

    public func upload(
        followupId: String,
        questionId: String,
        files: [File]
    ) async throws -> [ClaimFollowupUploadedFile] {
        try await delay()
        let (current, _) = try find(followupId: followupId, questionId: questionId)
        guard current.isOpen else { throw ClaimFollowupError.noFollowup }
        var uploaded: [ClaimFollowupUploadedFile] = []
        for file in files {
            let data = try await Self.data(of: file)
            let name = file.name.isEmpty ? "\(file.id).\(file.mimeType.name)" : file.name
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString)-\(name)")
            try data.write(to: url)
            let relevance: ClaimFollowupFileRelevance
            if file.mimeType.isImage {
                relevance = hasUploadedImage ? .match : .mismatch
                hasUploadedImage = true
            } else {
                relevance = .unknown
            }
            let id = UUID().uuidString
            stagedFiles[id] = ClaimFollowupFile(
                id: id,
                url: url,
                contentType: file.mimeType.mime,
                fileName: name,
                relevance: relevance
            )
            uploaded.append(ClaimFollowupUploadedFile(fileId: id, relevance: relevance))
        }
        return uploaded
    }

    public func uploadAudio(followupId _: String, questionId _: String, audioFileURL: URL) async throws -> String {
        try await delay()
        let id = UUID().uuidString
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(id)-recording.m4a")
        try FileManager.default.copyItem(at: audioFileURL, to: url)
        stagedAudio[id] = url
        return id
    }

    public func send(followupId: String) async throws -> ClaimFollowup {
        try await delay()
        guard let current = followup, current.id == followupId else { throw ClaimFollowupError.noFollowup }
        guard current.isOpen else { return current }
        guard current.questionsLeft == 0 else {
            throw ClaimFollowupError.userError(
                message: "Answer every question, or say you can't answer it, before you send"
            )
        }
        let completed = ClaimFollowup(
            id: current.id,
            claimId: current.claimId,
            status: .completed,
            questions: current.questions
        )
        followup = completed
        return completed
    }

    private func delay() async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
    }

    private func find(followupId: String, questionId: String) throws -> (ClaimFollowup, ClaimFollowupQuestion) {
        guard let current = followup, current.id == followupId,
            let question = current.questions.first(where: { $0.id == questionId })
        else {
            throw ClaimFollowupError.noFollowup
        }
        return (current, question)
    }

    private func replace(
        _ question: ClaimFollowupQuestion,
        state: ClaimFollowupQuestion.State,
        comment: String?,
        content: ClaimFollowupQuestion.Content,
        in current: ClaimFollowup
    ) -> ClaimFollowup {
        let updated = ClaimFollowup(
            id: current.id,
            claimId: current.claimId,
            status: current.status,
            questions: current.questions.map {
                $0.id == question.id
                    ? ClaimFollowupQuestion(
                        id: $0.id,
                        text: $0.text,
                        hint: $0.hint,
                        state: state,
                        cantAnswerComment: comment,
                        content: content
                    )
                    : $0
            }
        )
        followup = updated
        return updated
    }

    private static func data(of file: File) async throws -> Data {
        switch file.source {
        case let .data(data):
            return data
        case let .url(url, _):
            return try Data(contentsOf: url)
        case .localFile:
            guard case let .data(data)? = try await file.getAsData()?.source else {
                throw ClaimFollowupError.userError(message: "The file could not be read")
            }
            return data
        }
    }

    private static func makeFollowup(claimId: String) -> ClaimFollowup {
        ClaimFollowup(
            id: "fake-followup-1",
            claimId: claimId,
            status: .submitted,
            questions: [
                ClaimFollowupQuestion(
                    id: "fake-question-police",
                    text: "Skicka din polisanmälan",
                    state: .answered,
                    cantAnswerComment: nil,
                    content: .fileUpload(currentFiles: [
                        ClaimFollowupFile(
                            id: "fake-file-police",
                            url: URL(string: "https://example.com/polisanmalan.pdf")!,
                            contentType: "application/pdf",
                            fileName: "polisanmalan.pdf",
                            relevance: .unknown
                        )
                    ])
                ),
                ClaimFollowupQuestion(
                    id: "fake-question-receipt",
                    text: "Skicka kvittot för cykeln",
                    hint: "Kvittot ska visa pris, datum och butik.",
                    state: .todo,
                    cantAnswerComment: nil,
                    content: .fileUpload(currentFiles: [])
                ),
                ClaimFollowupQuestion(
                    id: "fake-question-price",
                    text: "Vad kostade cykeln?",
                    state: .todo,
                    cantAnswerComment: nil,
                    content: .number(currentValue: nil, min: 500, max: 50000)
                ),
                ClaimFollowupQuestion(
                    id: "fake-question-locked",
                    text: "Var cykeln låst?",
                    state: .todo,
                    cantAnswerComment: nil,
                    content: .binary(currentValue: nil)
                ),
                ClaimFollowupQuestion(
                    id: "fake-question-date",
                    text: "När köpte du cykeln?",
                    state: .todo,
                    cantAnswerComment: nil,
                    content: .date(currentValue: nil, min: "2020-01-01", max: Date().localDateString)
                ),
                ClaimFollowupQuestion(
                    id: "fake-question-phone",
                    text: "Vilket telefonnummer når vi dig på?",
                    state: .todo,
                    cantAnswerComment: nil,
                    content: .phoneNumber(currentValue: nil)
                ),
                ClaimFollowupQuestion(
                    id: "fake-question-text",
                    text: "Beskriv var cykeln stod",
                    state: .todo,
                    cantAnswerComment: nil,
                    content: .freeText(minLength: 1, maxLength: 2000, currentValue: nil, currentAudio: nil)
                ),
            ]
        )
    }
}

extension ClaimFollowupQuestion.Content {
    fileprivate var cleared: ClaimFollowupQuestion.Content {
        switch self {
        case .binary:
            return .binary(currentValue: nil)
        case let .freeText(minLength, maxLength, _, _):
            return .freeText(minLength: minLength, maxLength: maxLength, currentValue: nil, currentAudio: nil)
        case let .date(_, min, max):
            return .date(currentValue: nil, min: min, max: max)
        case let .number(_, min, max):
            return .number(currentValue: nil, min: min, max: max)
        case .phoneNumber:
            return .phoneNumber(currentValue: nil)
        case .fileUpload:
            return .fileUpload(currentFiles: [])
        }
    }
}
