import Claims
import Environment
import Foundation
import SubmitClaimChat
import hCore
import hGraphQL

final class ClaimFollowupClientOctopus: hClaimFollowupClient {
    @Inject private var octopus: hOctopus
    @Inject private var fileUploadClient: hSubmitClaimFileUploadClient
    /// The upload path comes with each question, but the protocol only passes ids, so it is kept from the last read.
    private var uploadUriByQuestionId: [String: String] = [:]

    init() {}

    func getFollowups() async throws -> [ClaimFollowup] {
        let data = try await octopus.client.fetch(query: OctopusGraphQL.ClaimFollowupsQuery())
        return data.currentMember.claimFollowups.map { followup(from: $0.fragments.claimFollowupFragment) }
    }

    func answer(
        followupId: String,
        questionId: String,
        answer: ClaimFollowupAnswer
    ) async throws -> ClaimFollowup {
        switch answer {
        case let .binary(value):
            let mutation = OctopusGraphQL.ClaimFollowupAnswerBinaryMutation(
                followupId: followupId,
                questionId: questionId,
                value: value ? "true" : "false"
            )
            let data = try await octopus.client.mutation(mutation: mutation)
            return try followup(from: data?.claimFollowupAnswerBinary.fragments.claimFollowupOutputFragment)
        case let .freeText(text):
            let mutation = OctopusGraphQL.ClaimFollowupAnswerFreeTextMutation(
                followupId: followupId,
                questionId: questionId,
                text: text
            )
            let data = try await octopus.client.mutation(mutation: mutation)
            return try followup(from: data?.claimFollowupAnswerFreeText.fragments.claimFollowupOutputFragment)
        case let .audio(fileId):
            let mutation = OctopusGraphQL.ClaimFollowupAnswerAudioMutation(
                followupId: followupId,
                questionId: questionId,
                audioFileId: fileId
            )
            let data = try await octopus.client.mutation(mutation: mutation)
            return try followup(from: data?.claimFollowupAnswerAudio.fragments.claimFollowupOutputFragment)
        case let .date(value):
            let mutation = OctopusGraphQL.ClaimFollowupAnswerDateMutation(
                followupId: followupId,
                questionId: questionId,
                value: value
            )
            let data = try await octopus.client.mutation(mutation: mutation)
            return try followup(from: data?.claimFollowupAnswerDate.fragments.claimFollowupOutputFragment)
        case let .number(value):
            let mutation = OctopusGraphQL.ClaimFollowupAnswerNumberMutation(
                followupId: followupId,
                questionId: questionId,
                value: value
            )
            let data = try await octopus.client.mutation(mutation: mutation)
            return try followup(from: data?.claimFollowupAnswerNumber.fragments.claimFollowupOutputFragment)
        case let .phoneNumber(value):
            let mutation = OctopusGraphQL.ClaimFollowupAnswerPhoneNumberMutation(
                followupId: followupId,
                questionId: questionId,
                value: value
            )
            let data = try await octopus.client.mutation(mutation: mutation)
            return try followup(from: data?.claimFollowupAnswerPhoneNumber.fragments.claimFollowupOutputFragment)
        case let .files(fileIds):
            let mutation = OctopusGraphQL.ClaimFollowupAnswerFileUploadMutation(
                followupId: followupId,
                questionId: questionId,
                fileIds: fileIds
            )
            let data = try await octopus.client.mutation(mutation: mutation)
            return try followup(from: data?.claimFollowupAnswerFileUpload.fragments.claimFollowupOutputFragment)
        }
    }

    func cantAnswer(followupId: String, questionId: String, comment: String?) async throws -> ClaimFollowup {
        let mutation = OctopusGraphQL.ClaimFollowupCantAnswerMutation(
            followupId: followupId,
            questionId: questionId,
            comment: GraphQLNullable(optionalValue: comment)
        )
        let data = try await octopus.client.mutation(mutation: mutation)
        return try followup(from: data?.claimFollowupCantAnswer.fragments.claimFollowupOutputFragment)
    }

    func upload(
        followupId _: String,
        questionId: String,
        files: [File]
    ) async throws -> [ClaimFollowupUploadedFile] {
        let url = try uploadURL(questionId: questionId)
        let multipart = MultipartFormDataRequest(url: url)
        for file in files {
            multipart.addDataField(
                fieldName: "files",
                fileName: file.name,
                data: try await data(of: file),
                mimeType: file.mimeType.mime
            )
        }
        let response: UploadResponse = try await fileUploadClient.upload(
            url: url,
            multipart: multipart,
            withProgress: nil
        )
        return response.uploadedFiles
    }

    func uploadAudio(followupId _: String, questionId: String, audioFileURL: URL) async throws -> String {
        let multipart = MultipartFormDataRequest(url: try uploadURL(questionId: questionId))
        multipart.addDataField(
            fieldName: "files",
            fileName: audioFileURL.lastPathComponent,
            data: try Data(contentsOf: audioFileURL),
            mimeType: "audio/m4a"
        )
        let response: UploadResponse = try await fileUploadClient.upload(
            url: audioFileURL,
            multipart: multipart,
            withProgress: nil
        )
        guard let fileId = response.uploadedFiles.first?.fileId else {
            throw ClaimFollowupError.noFollowup
        }
        return fileId
    }

    func send(followupId: String) async throws -> ClaimFollowup {
        let mutation = OctopusGraphQL.ClaimFollowupSendMutation(followupId: followupId)
        let data = try await octopus.client.mutation(mutation: mutation)
        return try followup(from: data?.claimFollowupSend.fragments.claimFollowupOutputFragment)
    }

    // MARK: - Mapping

    /// `questionId` lets the backend check whether an image looks like what was asked for.
    private func uploadURL(questionId: String) throws -> URL {
        guard let uploadUri = uploadUriByQuestionId[questionId] else {
            throw ClaimFollowupError.noFollowup
        }
        let url = Environment.current.claimsApiURL.appendingPathComponent(uploadUri)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "questionId", value: questionId)]
        guard let urlWithQuestion = components?.url else {
            throw ClaimFollowupError.noFollowup
        }
        return urlWithQuestion
    }

    private func data(of file: File) async throws -> Data {
        switch file.source {
        case let .data(data):
            return data
        case let .url(url, _):
            return try Data(contentsOf: url)
        case .localFile:
            guard case let .data(data)? = try await file.getAsData()?.source else {
                throw ClaimFollowupError.noFollowup
            }
            return data
        }
    }

    private func followup(from output: OctopusGraphQL.ClaimFollowupOutputFragment?) throws -> ClaimFollowup {
        if let userError = output?.userError {
            throw ClaimFollowupError.userError(message: userError.message ?? "")
        }
        guard let fragment = output?.followup?.fragments.claimFollowupFragment else {
            throw ClaimFollowupError.noFollowup
        }
        return followup(from: fragment)
    }

    private func followup(from fragment: OctopusGraphQL.ClaimFollowupFragment) -> ClaimFollowup {
        ClaimFollowup(
            id: fragment.id,
            claimId: fragment.claimId,
            status: fragment.status.value == .completed ? .completed : .submitted,
            questions: fragment.questions.map { question(from: $0) }
        )
    }

    private func question(from question: OctopusGraphQL.ClaimFollowupFragment.Question) -> ClaimFollowupQuestion {
        let state: ClaimFollowupQuestion.State =
            switch question.state.value {
            case .answered: .answered
            case .cantAnswer: .cantAnswer
            case .todo, .none: .todo
            }
        return ClaimFollowupQuestion(
            id: question.id,
            text: question.text,
            hint: question.hint,
            cantAnswerLabel: question.cantAnswerLabel,
            state: state,
            cantAnswerComment: question.cantAnswerComment,
            content: content(from: question.content, questionId: question.id)
        )
    }

    private func content(
        from content: OctopusGraphQL.ClaimFollowupFragment.Question.Content,
        questionId: String
    ) -> ClaimFollowupQuestion.Content {
        if let binary = content.asClaimFollowupBinary {
            return .binary(currentValue: binary.currentValue.map { $0 == "true" })
        }
        if let freeText = content.asClaimFollowupFreeText {
            uploadUriByQuestionId[questionId] = freeText.uploadUri
            return .freeText(
                minLength: freeText.minLength,
                maxLength: freeText.maxLength,
                currentValue: freeText.currentValue,
                currentAudio: freeText.currentAudio.flatMap {
                    file(
                        id: $0.id,
                        url: $0.url,
                        contentType: $0.contentType,
                        fileName: $0.fileName,
                        relevance: $0.relevance
                    )
                }
            )
        }
        if let date = content.asClaimFollowupDate {
            return .date(currentValue: date.currentValue, min: date.minDate, max: date.maxDate)
        }
        if let number = content.asClaimFollowupNumber {
            return .number(currentValue: number.currentValue, min: number.min, max: number.max)
        }
        if let fileUpload = content.asClaimFollowupFileUpload {
            uploadUriByQuestionId[questionId] = fileUpload.uploadUri
            return .fileUpload(
                currentFiles: fileUpload.currentFiles.compactMap {
                    file(
                        id: $0.id,
                        url: $0.url,
                        contentType: $0.contentType,
                        fileName: $0.fileName,
                        relevance: $0.relevance
                    )
                }
            )
        }
        return .phoneNumber(currentValue: content.asClaimFollowupPhoneNumber?.currentValue)
    }

    private func file(
        id: String,
        url: String,
        contentType: String,
        fileName: String,
        relevance: GraphQLEnum<OctopusGraphQL.ClaimFollowupFileRelevance>
    ) -> ClaimFollowupFile? {
        guard let url = URL(string: url) else { return nil }
        return ClaimFollowupFile(
            id: id,
            url: url,
            contentType: contentType,
            fileName: fileName,
            relevance: ClaimFollowupFileRelevance(rawValue: relevance.rawValue.lowercased()) ?? .unknown
        )
    }
}

/// The follow-up upload answers `{ "files": [{ "fileId", "relevance" }] }`; plain `{ "fileIds" }` is read as unknown.
private struct UploadResponse: Codable, Sendable {
    struct UploadedFile: Codable, Sendable {
        let fileId: String
        let relevance: String?
    }

    let files: [UploadedFile]?
    let fileIds: [String]?

    var uploadedFiles: [ClaimFollowupUploadedFile] {
        if let files {
            return files.map {
                ClaimFollowupUploadedFile(
                    fileId: $0.fileId,
                    relevance: ClaimFollowupFileRelevance(rawValue: ($0.relevance ?? "").lowercased()) ?? .unknown
                )
            }
        }
        return (fileIds ?? []).map { ClaimFollowupUploadedFile(fileId: $0, relevance: .unknown) }
    }
}
