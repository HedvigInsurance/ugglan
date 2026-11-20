import Foundation
import hCore

/// The screens and lifecycle a voice tool can ask for. Implemented by `VoiceClaimViewModel`.
@MainActor
protocol VoiceClaimToolboxDelegate: AnyObject {
    /// Show the native photo/document picker for this upload step, over the orb.
    func toolboxRequestsPhotos(for intent: ClaimIntent)
    /// Show the existing summary so the member can tap submit.
    func toolboxRequestsSummary(for intent: ClaimIntent)
    /// End the call and continue the draft in the chat.
    func toolboxRequestsHandoff(reason: String)
    /// The claim was submitted.
    func toolboxDidFinish(outcome: ClaimIntentStepOutcome)
    /// The claim went back to an earlier step: whatever sheet was open belongs to a step that no longer exists.
    func toolboxWentBack()
}

/// The client tools the ElevenLabs agent calls, by name. Each one maps onto the same `ClaimIntentService` calls
/// the chat makes, so the engine and the draft are untouched by voice. The tool names and parameters must match
/// the tools registered on the agent in the ElevenLabs dashboard (see `Projects/SubmitClaimChat/VoiceAgent.md`).
enum VoiceTool: Equatable {
    case getCurrentStep
    /// What the member's confirmed story settles, so the app can answer those steps itself.
    case noteStory(StoryFacts)
    case answerSelect(stepId: String, optionId: String)
    case answerForm(stepId: String, fields: [FieldValue])
    case answerFreeText(stepId: String, memberWords: String)
    case searchField(stepId: String, fieldId: String, query: String)
    case acknowledgeNotice(stepId: String)
    case skipStep(stepId: String)
    case requestPhotos(stepId: String)
    case showSummary(stepId: String)
    case handOffToChat(reason: String)
    /// Without a step id: list the answers so far. With one: go back to that step to change its answer, like the
    /// chat's edit button (the engine's regret), which also clears every answer after it.
    case goBack(stepId: String?)

    struct InvalidCall: LocalizedError {
        let message: String
        var errorDescription: String? { message }
    }

    init(name: String, parameters: [String: Any]) throws {
        func string(_ key: String) throws -> String {
            if let value = parameters[key] as? String, !value.isEmpty { return value }
            if let value = parameters[key] as? NSNumber { return value.stringValue }
            throw InvalidCall(message: "\(name) needs the parameter \(key).")
        }
        switch name {
        case "get_current_step": self = .getCurrentStep
        case "note_story":
            func optional(_ key: String) -> String? {
                let value = (parameters[key] as? String)?.trimmingCharacters(in: .whitespaces) ?? ""
                return value.isEmpty ? nil : value
            }
            self = .noteStory(
                StoryFacts(
                    category: optional("category"),
                    subcategory: optional("subcategory"),
                    date: optional("date"),
                    itemCount: (parameters["item_count"] as? NSNumber)?.intValue
                        ?? optional("item_count").flatMap { Int($0) },
                    item: optional("item")
                )
            )
        case "answer_select": self = .answerSelect(stepId: try string("step_id"), optionId: try string("option_id"))
        case "answer_form": self = .answerForm(stepId: try string("step_id"), fields: try Self.fields(parameters))
        case "answer_free_text":
            self = .answerFreeText(
                stepId: try string("step_id"),
                memberWords: (parameters["member_words"] as? String) ?? ""
            )
        case "search_field":
            self = .searchField(
                stepId: try string("step_id"),
                fieldId: try string("field_id"),
                query: try string("query")
            )
        case "acknowledge_notice": self = .acknowledgeNotice(stepId: try string("step_id"))
        case "skip_step": self = .skipStep(stepId: try string("step_id"))
        case "request_photos": self = .requestPhotos(stepId: try string("step_id"))
        case "show_summary": self = .showSummary(stepId: try string("step_id"))
        case "hand_off_to_chat": self = .handOffToChat(reason: (parameters["reason"] as? String) ?? "")
        case "go_back":
            let stepId = (parameters["step_id"] as? String)?.trimmingCharacters(in: .whitespaces) ?? ""
            self = .goBack(stepId: stepId.isEmpty ? nil : stepId)
        default: throw InvalidCall(message: "There is no tool called \(name).")
        }
    }

    /// `fields` as an array of `{field_id, values}` (or `value`) objects, or the same array as a JSON string.
    private static func fields(_ parameters: [String: Any]) throws -> [FieldValue] {
        var raw = parameters["fields"]
        if let json = raw as? String, let data = json.data(using: .utf8) {
            raw = try? JSONSerialization.jsonObject(with: data)
        }
        guard let items = raw as? [[String: Any]], !items.isEmpty else {
            throw InvalidCall(message: "answer_form needs fields: [{field_id, values}].")
        }
        return try items.map { item in
            guard let id = (item["field_id"] ?? item["id"]) as? String else {
                throw InvalidCall(message: "Each field in answer_form needs a field_id.")
            }
            let values: [String]
            if let many = item["values"] as? [Any] {
                values = many.map { "\($0)" }
            } else if let one = item["value"] {
                values = ["\(one)"]
            } else {
                values = []
            }
            return FieldValue(id: id, values: values)
        }
    }
}

/// The parts of the member's story that answer the engine's opening steps. Category and subcategory are triage
/// option ids (`VoiceStepAdapter.triageOptionIds`); the date is YYYY-MM-DD; `item` is what to search for when the
/// engine asks which item it is ("LG fridge").
struct StoryFacts: Equatable {
    var category: String?
    var subcategory: String?
    var date: String?
    var itemCount: Int?
    var item: String?
}

/// One answer the member gave this call, as `go_back` lists it: the step, its question, and the answer in words.
struct AnsweredStep: Encodable, Equatable {
    /// What was sent to the engine, so the same answer can be sent again after going back to an earlier step.
    enum Replay: Equatable {
        case select(String)
        case form([FieldValue])
        case freeText(String)
        case skip
        case notice
        case files([String])
    }

    let stepId: String
    let question: String?
    let answer: String
    /// Whether the engine lets this step be answered again (`ClaimIntent.isRegrettable`).
    let canChange: Bool
    var kind: VoiceStepPayload.Kind = .none
    /// The step's option or field ids, to recognise it when the engine words it differently.
    var shape: [String] = []
    var replay: Replay = .skip
    /// Notices are heard, not answered: they're replayed but never offered as something to change.
    var isAnswer: Bool { replay != .notice }

    enum CodingKeys: String, CodingKey {
        case question, answer
        case stepId = "step_id"
        case canChange = "can_change"
    }
}

extension FieldValue: Equatable {
    public static func == (lhs: FieldValue, rhs: FieldValue) -> Bool {
        lhs.id == rhs.id && lhs.values == rhs.values
    }
}

/// What a tool call returns to the agent.
enum VoiceToolResult: Encodable {
    case step(VoiceStepPayload)
    case searchResults(fieldId: String, options: [VoiceStepPayload.Option])
    /// The app is showing something (picker, summary); the agent waits for an `[APP]` message.
    case waiting(String)
    case error(message: String, currentStep: VoiceStepPayload?)
    /// The member's answers so far, for `go_back`.
    case answers([AnsweredStep])

    private enum CodingKeys: String, CodingKey {
        case status, fieldId = "field_id", options, instruction, error, answers, currentStep = "current_step"
    }

    func encode(to encoder: Encoder) throws {
        switch self {
        case let .step(payload):
            try payload.encode(to: encoder)
        case let .searchResults(fieldId, options):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode("search_results", forKey: .status)
            try container.encode(fieldId, forKey: .fieldId)
            try container.encode(options, forKey: .options)
            try container.encode(
                options.isEmpty
                    ? "Nothing matched. Ask the member to describe it differently, then search again."
                    : "Talk about the matches the way a person would: brand and model names are fine, but never "
                        + "read out model numbers or codes like \"GBB62BLGGC\". If one clearly fits, check "
                        + "it in a few words. If the member doesn't know the exact model, call answer_form right away "
                        + "with the match marked \"model unknown\" (or skip_step if there's none); never send the "
                        + "field empty. Otherwise use the chosen id in answer_form.",
                forKey: .instruction
            )
        case let .waiting(instruction):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode("waiting", forKey: .status)
            try container.encode(instruction, forKey: .instruction)
        case let .error(message, currentStep):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode("error", forKey: .status)
            try container.encode(message, forKey: .error)
            try container.encodeIfPresent(currentStep, forKey: .currentStep)
        case let .answers(answers):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode("answers", forKey: .status)
            try container.encode(answers, forKey: .answers)
            try container.encode(
                answers.isEmpty
                    ? "Nothing has been saved yet, so there's nothing to change. Carry on with the current question."
                    : """
                    The member's answers so far, oldest first. Find the one they want to change and call go_back \
                    with its step_id. If can_change is false, tell them that answer can't be changed here and \
                    that they can let the claims handler know once the claim is in. If it's unclear which one they \
                    mean, ask them in a few words. Never read this list out.
                    """,
                forKey: .instruction
            )
        }
    }

    func json() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        guard let data = try? encoder.encode(self) else { return #"{"status":"error"}"# }
        return String(decoding: data, as: UTF8.self)
    }
}

/// Runs the voice tools against the engine and keeps the voice session's view of the claim: the current step, the
/// member's own words (from the agent's transcripts), and when the claim leaves voice.
@MainActor
final class VoiceClaimToolbox {
    weak var delegate: VoiceClaimToolboxDelegate?
    private let service: ClaimIntentService
    private let sleep: (Duration) async throws -> Void
    private let taskTimeout: Duration
    /// How long an answer waits for the engine before the agent gets `processing` and fills the pause itself.
    private let answerWait: Duration
    /// How long `get_current_step` waits for a still-thinking engine before the agent gets another filler cue.
    private let fillerGap: Duration
    /// The engine's processing (task steps) for the last answer, running while the agent talks.
    private var pendingAdvance: Task<ClaimIntent, Error>?

    private(set) var currentIntent: ClaimIntent?
    private(set) var outcome: ClaimIntentStepOutcome?
    private var handoffReason: String?

    /// The member's final transcripts this call, and how many of them belong to answers already sent.
    private var memberUtterances: [String] = []
    private var answeredUtteranceCount = 0
    private var hasAnsweredFreeText = false

    /// The step the agent was last handed, and how many member utterances there were then: asking for that same
    /// step again before the member has said anything means the agent is about to repeat its question.
    private var deliveredStepId: String?
    private var utterancesAtDelivery = 0
    /// Whether the call is past the opening (the story noted, or a step answered or skipped).
    private var isPastOpening = false
    /// The agent asked the member something and they haven't spoken since. Nothing may be saved until they do:
    /// some models ask and then "answer" in the same breath.
    private var hasOpenQuestion = false

    init(
        service: ClaimIntentService = ClaimIntentService(),
        sleep: @escaping (Duration) async throws -> Void = { try await Task.sleep(for: $0) },
        taskTimeout: Duration = .seconds(60),
        answerWait: Duration = .seconds(8),
        fillerGap: Duration = .seconds(8)
    ) {
        self.service = service
        self.sleep = sleep
        self.taskTimeout = taskTimeout
        self.answerWait = answerWait
        self.fillerGap = fillerGap
    }

    /// The member's contract ids and what each insures, so policy options in a step say so.
    var policies: [String: String] = [:]

    /// The story the agent noted (`note_story`), once it has.
    private var note: StoryFacts?

    /// What the member has answered this call, oldest first, so `go_back` can find the step they want to change.
    private(set) var answered: [AnsweredStep] = []
    /// The names of the search matches the agent was given, by option id, so a chosen item reads as a name.
    private var searchLabels: [String: String] = [:]
    /// The answers that came after the one the member went back to change, waiting to be sent again.
    private var cleared: [AnsweredStep] = []

    /// The claim intent being created; tools wait for it, so the call can connect at the same time.
    private var starting: Task<VoiceStepPayload, Error>?

    /// Starts a new claim (voice is for new claims only) and returns its first speakable step.
    func start() async throws -> VoiceStepPayload {
        let starting = Task { () async throws -> VoiceStepPayload in
            let result = try await self.service.startClaimIntent(input: .init(type: .regular(hasInProgress: false)))
            return try await self.adopt(result)
        }
        self.starting = starting
        return try await starting.value
    }

    /// The member said this (an agent `user_transcript`).
    func recordMemberUtterance(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        // "..." is how a silent turn comes through: not an answer.
        guard trimmed.contains(where: \.isLetter) || trimmed.contains(where: \.isNumber) else { return }
        memberUtterances.append(trimmed)
        hasOpenQuestion = false
    }

    /// The agent said this (an agent response). A question means the next move is the member's.
    func recordAgentUtterance(_ text: String) {
        if text.contains("?") { hasOpenQuestion = true }
    }

    /// Runs one tool call and returns the JSON the agent gets back. Never throws: failures become error results
    /// that carry the current step, so the agent can recover by itself.
    func handle(toolName: String, parameters: [String: Any]) async -> String {
        do {
            let tool = try VoiceTool(name: toolName, parameters: parameters)
            let result = try await run(tool)
            if case let .step(payload) = result { delivered(payload) }
            return result.json()
        } catch {
            // Waiting for the member carries no step: handed the step again, the agent repeats what it just said.
            let current =
                error is WaitForMember
                ? nil : currentIntent.map { VoiceStepAdapter.payload(for: $0, policies: policies) }
            if let current { delivered(current) }
            let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            return
                VoiceToolResult.error(
                    message: message.isEmpty ? "That didn't work. Try again or ask the member differently." : message,
                    currentStep: current
                )
                .json()
        }
    }

    func run(_ tool: VoiceTool) async throws -> VoiceToolResult {
        let result = try await runTool(tool)
        // After going back, the answers that were cleared are sent again by the app as the engine asks for them.
        guard case let .step(payload) = result, !tool.isGoBack else { return result }
        return .step(try await replayingCleared(payload))
    }

    private func runTool(_ tool: VoiceTool) async throws -> VoiceToolResult {
        // The agent can only reach the engine once the claim exists (it's created while the call connects).
        if currentIntent == nil, let starting { _ = try await starting.value }
        if let handoffReason, !tool.isHandoff {
            return .step(.handoff(reason: handoffReason))
        }
        if outcome != nil { return .step(.done) }
        // The engine is still on the previous answer: wait a bit, then let the agent fill the pause again.
        if let pendingAdvance {
            // Going back can't be put off: a correction handed a pause gets forgotten. Wait the engine out.
            let wait: Duration = tool.isGoBack ? taskTimeout : fillerGap
            guard let intent = try await finished(pendingAdvance, within: wait) else {
                return .step(.processing(again: true))
            }
            if case .getCurrentStep = tool {
                return .step(try currentPayload(after: intent))
            }
            _ = try currentPayload(after: intent)
        }

        if hasOpenQuestion, tool.answersAStep || tool.isNoteStory {
            throw WaitForMember()
        }
        if tool.answersAStep { isPastOpening = true }
        switch tool {
        case .getCurrentStep:
            // Guards that hold whatever the model: no steps before the recap, and no repeating a question the
            // member hasn't answered yet.
            if !isPastOpening, note == nil {
                return .waiting(
                    """
                    Not yet. If what happened, where or when is still missing, ask for just that, plainly, without \
                    a recap. Once you know all three, make your one recap, end your turn and wait for the member \
                    to confirm it; then call note_story with what it settles (it answers the opening steps itself).
                    """
                )
            }
            if let intent = currentIntent, intent.currentStep.id == deliveredStepId,
                memberUtterances.count == utterancesAtDelivery
            {
                return .waiting(
                    """
                    You already have this step and have asked it; the member hasn't answered yet. Don't repeat the \
                    question or say anything else: stop talking and wait for their reply.
                    """
                )
            }
            return .step(try currentPayload())

        case let .noteStory(story):
            note = story
            return .step(try await answerFromStory(story))

        case let .answerSelect(stepId, optionId):
            let intent = try currentIntent(matching: stepId)
            guard case let .singleSelect(model) = intent.currentStep.content else { throw wrongKind(intent) }
            guard let chosen = model.options.first(where: { $0.id == optionId }) else {
                throw VoiceTool.InvalidCall(message: "\(optionId) is not one of this step's option ids.")
            }
            // "No idea" is not a no. The prompt says so, but the model still did it, so it's held here too.
            let yesOrNo: Set<String> = ["yes", "no", "ja", "nej"]
            let since = Array(memberUtterances.dropFirst(answeredUtteranceCount))
            if yesOrNo.contains(chosen.title.lowercased()), Self.saysDontKnow(since) {
                let otherwise =
                    intent.isSkippable
                    ? "otherwise call skip_step."
                    : "otherwise ask them gently which is closer, since this one can't be skipped."
                throw VoiceTool.InvalidCall(
                    message: """
                        The member said they don't know, so don't answer yes or no for them. Pick an option that \
                        says they don't know if there is one; \(otherwise)
                        """
                )
            }
            let leaves = VoiceStepAdapter.leavesPlaybooks(content: intent.currentStep.content, optionId: optionId)
            let result = try await service.claimIntentSubmitSelect(stepId: stepId, selectedValue: optionId)
            let label = model.options.first { $0.id == optionId }?.title ?? optionId
            record(intent, answer: label, replay: .select(optionId))
            let next = try await adopt(result)
            guard leaves else { return .step(next) }
            let reason = "this kind of claim has its own questions in the chat"
            handoffReason = reason
            return .step(.handoff(reason: reason))

        case let .answerForm(stepId, given):
            let intent = try currentIntent(matching: stepId)
            guard case let .form(model) = intent.currentStep.content else { throw wrongKind(intent) }
            // A search match's id is an opaque code the model sometimes copies with a space in it.
            let fields = given.map { value in
                guard model.fields.first(where: { $0.id == value.id })?.type == .search else { return value }
                return FieldValue(id: value.id, values: value.values.map { $0.filter { !$0.isWhitespace } })
            }
            let result = try await service.claimIntentSubmitForm(fields: fields, stepId: stepId)
            record(intent, answer: describe(fields, in: model), replay: .form(fields))
            return .step(try await adopt(result))

        case let .answerFreeText(stepId, agentWords):
            let intent = try currentIntent(matching: stepId)
            guard case let .audioRecording(model) = intent.currentStep.content else { throw wrongKind(intent) }
            var words = String(memberWords(fallback: agentWords).prefix(model.freeTextMaxLength))
            let agentText = String(
                agentWords.trimmingCharacters(in: .whitespacesAndNewlines).prefix(model.freeTextMaxLength)
            )
            // Everything the member says is the agent's memory for the whole call. When they've said nothing new
            // (or only "yes", "okay"), the answer comes from what they said earlier, in the agent's wording of it,
            // as long as it's the member's own: their words and every number in it (see `isGrounded`).
            if words.isEmpty || Self.isAcknowledgement(words) {
                if let earlier = cleared.firstIndex(where: { $0.replay == .freeText(agentText) }) {
                    words = agentText
                    cleared.remove(at: earlier)
                } else if Self.isGrounded(agentText, in: memberUtterances) {
                    words = agentText
                }
            }
            guard !words.isEmpty else {
                throw VoiceTool.InvalidCall(
                    message: """
                        Nothing the member has said in this call answers this. Ask the question, then stop and wait \
                        for their answer before calling answer_free_text. Never answer it for them.
                        """
                )
            }
            let result = try await service.claimIntentSubmitAudio(fileId: nil, freeText: words, stepId: stepId)
            record(intent, answer: words, replay: .freeText(words))
            let next = try await adopt(result)
            hasAnsweredFreeText = true
            return .step(next)

        case let .searchField(stepId, fieldId, query):
            _ = try currentIntent(matching: stepId)
            let result = try await service.claimIntentFormFieldSearch(stepId: stepId, fieldId: fieldId, query: query)
            return .searchResults(fieldId: fieldId, options: rememberLabels(Self.spokenOptions(result)))

        case let .acknowledgeNotice(stepId):
            let intent = try currentIntent(matching: stepId)
            guard case .information = intent.currentStep.content else { throw wrongKind(intent) }
            let result = try await service.claimIntentSubmitInformation(stepId: stepId)
            record(intent, answer: "(heard)", replay: .notice)
            return .step(try await adopt(result))

        case let .skipStep(stepId):
            let intent = try currentIntent(matching: stepId)
            guard intent.isSkippable else {
                throw VoiceTool.InvalidCall(message: "This step can't be skipped; the member needs to answer it.")
            }
            let result = try await service.claimIntentSkipStep(stepId: stepId)
            record(intent, answer: "(skipped: the member didn't know or didn't have it)", replay: .skip)
            return .step(try await adopt(result))

        case let .requestPhotos(stepId):
            let intent = try currentIntent(matching: stepId)
            guard case .fileUpload = intent.currentStep.content else { throw wrongKind(intent) }
            delegate?.toolboxRequestsPhotos(for: intent)
            return .waiting(
                """
                The photo picker is already open on the member's screen. Say so in one short line, as something \
                that has happened ("you should see the photo picker on your screen now"), then stay quiet while they \
                pick. You'll get an [APP] message with the next step when they're done.
                """
            )

        case let .showSummary(stepId):
            let intent = try currentIntent(matching: stepId)
            guard case .summary = intent.currentStep.content else { throw wrongKind(intent) }
            delegate?.toolboxRequestsSummary(for: intent)
            return .waiting(
                """
                The summary is already on the member's screen. Say so as something that has happened ("you should \
                see a summary of your claim on your screen now"), give a short recap of the claim from the summary \
                lines in two or three sentences, and tell them to tap "Submit claim" when it looks right. You'll get \
                an [APP] message when it's submitted or closed.
                """
            )

        case let .handOffToChat(reason):
            delegate?.toolboxRequestsHandoff(reason: handoffReason ?? reason)
            return .waiting("Handing over to the chat. Don't say anything more.")

        case let .goBack(stepId):
            guard let stepId else { return .answers(answered.filter(\.isAnswer)) }
            return .step(try await goBack(to: stepId))
        }
    }

    // MARK: - Changing an answer

    /// Goes back to an answered step so the member can change it, the way the chat's edit button does: the engine
    /// (regret) makes that step current again and drops every answer after it, which it then asks again.
    private func goBack(to stepId: String) async throws -> VoiceStepPayload {
        guard let index = answered.firstIndex(where: { $0.stepId == stepId && $0.isAnswer }) else {
            throw VoiceTool.InvalidCall(
                message: "That isn't one of the member's answers. Call go_back without a step_id to get the list."
            )
        }
        guard answered[index].canChange else {
            throw VoiceTool.InvalidCall(
                message: """
                    That answer can't be changed here. Tell the member, kindly, that they can let the claims handler \
                    know once the claim is in, then carry on with the current question.
                    """
            )
        }
        guard case let .intent(model)? = try await service.claimIntentRegretStep(stepId: stepId) else {
            throw ClaimIntentError.invalidResponse
        }
        // The answers after it are sent again as the engine asks for them; the one being changed is the member's.
        cleared = Array(answered[(index + 1)...])
        answered.removeSubrange(index...)
        // The request to change it is never sent as an answer by itself; what the member said stays the agent's
        // memory, so the new answer can come from it (see `answerFreeText`).
        markAnswered()
        hasAnsweredFreeText = true
        delegate?.toolboxWentBack()
        var payload = try currentPayload(after: try await advancingTasks(model))
        guard payload.status == .step else { return payload }
        payload.instruction = """
            This is the question whose answer the member wants to change. Work out the new answer from what they \
            just said together with what they told you before, and save it right away without asking (for free \
            text, in their own words, putting the correction together with the rest of what they said for this, \
            like "about 1,500 kronor of groceries ruined"). Ask only if it's unclear what it should be now. \
            Everything else they told you is kept and filled in again by itself. Never mention steps, going back \
            or clearing anything.

            """ + payload.instruction
        return payload
    }

    /// Sends the cleared answers again, in order, for as long as the engine asks the same questions, so the member
    /// never hears them twice. Stops at the first question it has no earlier answer for and hands that to the agent,
    /// with whatever earlier answers are left for it to reuse.
    func replayingCleared(_ payload: VoiceStepPayload) async throws -> VoiceStepPayload {
        var payload = payload
        while !cleared.isEmpty, payload.status == .step, let intent = currentIntent {
            guard let index = clearedAnswer(for: intent) else { break }
            let earlier = cleared[index]
            guard let result = try? await send(earlier.replay, to: intent) else { break }
            // Earlier answers it went past belong to questions the engine no longer asks.
            cleared.removeSubrange(...index)
            record(intent, answer: earlier.answer, replay: earlier.replay)
            payload = try await adopt(result, waitFully: true)
        }
        // A pause (the engine still thinking) keeps the rest for the step that follows it.
        // At the summary nothing is left to ask; whatever the engine didn't ask again is no longer part of the claim.
        if payload.status == .done || payload.status == .handoff || payload.kind == .summary { cleared = [] }
        guard payload.status == .step, !cleared.isEmpty else { return payload }
        let earlier = cleared.filter(\.isAnswer).map { "- \($0.question ?? "") → \($0.answer)" }
        if earlier.isEmpty {
            cleared = []
            return payload
        }
        payload.instruction += """


            The member already answered these before changing an earlier answer:
            \(earlier.joined(separator: "\n"))
            Hedvig may word a question differently this time. If one of these (or anything else they said in this \
            call) answers what's being asked now, however it's worded, answer it from there straight away without \
            asking (for free text, send that answer's words as member_words). You're working through your notes: \
            say nothing, or one short generic line ("just making sure everything's in place"), never what the \
            question or answer is and never that you already have it. Only ask if nothing they've said answers \
            it, or if the change they just made affects it.
            """
        return payload
    }

    /// The earlier answer that certainly fits the step the engine is asking now: the exact question, a select or
    /// form with the same options or fields, a notice, or photos. A reworded free-text question is left to the
    /// agent, which gets the earlier answers and judges whether one of them answers it.
    private func clearedAnswer(for intent: ClaimIntent) -> Int? {
        let question = VoiceStepAdapter.payload(for: intent, policies: policies)
        let shape = Self.shape(of: intent)
        if let exact = cleared.firstIndex(where: { $0.kind == question.kind && $0.question == question.question }) {
            return exact
        }
        switch question.kind {
        case .select, .form:
            return cleared.firstIndex { $0.kind == question.kind && !shape.isEmpty && $0.shape == shape }
        case .notice, .photos:
            return cleared.firstIndex { $0.kind == question.kind }
        case .freeText, .summary, .none:
            return nil
        }
    }

    /// A step's option or field ids, which stay the same when the engine rewords the question.
    private static func shape(of intent: ClaimIntent) -> [String] {
        switch intent.currentStep.content {
        case let .singleSelect(model): return model.options.map(\.id).sorted()
        case let .form(model): return model.fields.map(\.id).sorted()
        default: return []
        }
    }

    /// Sends one earlier answer to the step the engine is asking now.
    private func send(_ replay: AnsweredStep.Replay, to intent: ClaimIntent) async throws -> ClaimIntentType? {
        let stepId = intent.currentStep.id
        switch replay {
        case let .select(optionId):
            return try await service.claimIntentSubmitSelect(stepId: stepId, selectedValue: optionId)
        case let .form(fields):
            return try await service.claimIntentSubmitForm(fields: fields, stepId: stepId)
        case let .freeText(words):
            return try await service.claimIntentSubmitAudio(fileId: nil, freeText: words, stepId: stepId)
        case .skip:
            guard intent.isSkippable else { return nil }
            return try await service.claimIntentSkipStep(stepId: stepId)
        case .notice:
            return try await service.claimIntentSubmitInformation(stepId: stepId)
        case let .files(fileIds):
            return try await service.claimIntentSubmitFile(stepId: stepId, fileIds: fileIds)
        }
    }

    /// The member added photos or documents in the picker the app opened for this step.
    func recordUpload(for intent: ClaimIntent, fileIds: [String]) {
        let count = fileIds.count
        guard count > 0 else {
            record(intent, answer: "(skipped: no files added)", replay: .skip)
            return
        }
        record(intent, answer: count == 1 ? "1 file added" : "\(count) files added", replay: .files(fileIds))
    }

    /// Keeps the answer the member gave to this step, for `go_back`. Answering a step again replaces it.
    private func record(_ intent: ClaimIntent, answer: String, replay: AnsweredStep.Replay) {
        let stepId = intent.currentStep.id
        let payload = VoiceStepAdapter.payload(for: intent, policies: policies)
        answered.removeAll { $0.stepId == stepId }
        answered.append(
            AnsweredStep(
                stepId: stepId,
                question: payload.question,
                answer: answer,
                canChange: intent.isRegrettable,
                kind: payload.kind,
                shape: Self.shape(of: intent),
                replay: replay
            )
        )
    }

    /// A form answer in words: each field's title and its values, with options and search matches by name.
    private func describe(_ fields: [FieldValue], in model: ClaimIntentStepContentForm) -> String {
        fields.map { value in
            let field = model.fields.first { $0.id == value.id }
            let shown = value.values.map { raw in
                field?.options.first { $0.value == raw }?.displayTitle ?? searchLabels[raw] ?? raw
            }
            var text = shown.joined(separator: ", ")
            if !shown.isEmpty, let suffix = field?.suffix, !suffix.isEmpty { text += " \(suffix)" }
            guard let title = field?.title else { return text }
            return "\(title): \(text.isEmpty ? "(left empty)" : text)"
        }
        .joined(separator: "; ")
    }

    private func rememberLabels(_ options: [VoiceStepPayload.Option]) -> [VoiceStepPayload.Option] {
        for option in options { searchLabels[option.id] = option.label }
        return options
    }

    /// The result of a step the app ran itself (the picker or summary sheet), as the agent's next step. With
    /// `waitFully`, a thinking engine is waited out instead of handing the agent a `processing` pause.
    func adopt(_ result: ClaimIntentType?, waitFully: Bool = false) async throws -> VoiceStepPayload {
        guard let result else { throw ClaimIntentError.invalidResponse }
        markAnswered()
        switch result {
        case let .outcome(model):
            outcome = model
            delegate?.toolboxDidFinish(outcome: model)
            return .done
        case let .intent(model):
            guard case let .task(task) = model.currentStep.content, !task.isCompleted, !waitFully else {
                currentIntent = try await advancingTasks(model)
                return try currentPayload()
            }
            // The engine is thinking. Give it a moment; if it needs longer, hand the pause to the agent.
            let advance = Task { try await self.advancingTasks(model) }
            pendingAdvance = advance
            guard let intent = try await finished(advance, within: answerWait) else {
                currentIntent = model
                return .processing(again: false)
            }
            return try currentPayload(after: intent)
        }
    }

    // MARK: - Answering from the story

    /// Answers the opening steps the member's confirmed story already settles, one after another, without a round
    /// trip to the agent's LLM for each: the triage questions (when the noted category or subcategory is one of
    /// the options), the description (the member's own words) and a form that only asks for the date. Stops at
    /// the first step the story doesn't answer and returns it, so the agent's next words are a real question.
    private func answerFromStory(_ story: StoryFacts) async throws -> VoiceStepPayload {
        for _ in 0..<10 {
            guard let intent = currentIntent, let answer = storyAnswer(story, for: intent) else { break }
            let next = try await answer()
            if next.status != .step { return next }
        }
        var payload = try currentPayload()
        // Which item it is needs the member, but the search can already run, saving the agent a round trip.
        if let item = story.item, let intent = currentIntent, case let .form(model) = intent.currentStep.content,
            model.fields.count == 1, let field = model.fields.first, field.type == .search
        {
            let result = try await service.claimIntentFormFieldSearch(
                stepId: intent.currentStep.id,
                fieldId: field.id,
                query: item
            )
            payload.searchResults = rememberLabels(Self.spokenOptions(result))
            payload.instruction = """
                The app already searched for "\(item)"; the best matches are in search_results. Talk about them the \
                way a person would: brand and model names are fine, but never read out model numbers or codes like \
                "GBB62BLGGC". Ask about the brand or model only if the member hasn't said; if one clearly fits, check \
                it in a few words. If they don't know the exact model, call answer_form right away with the match \
                marked "model unknown" (or skip_step if there's none); never send the field empty. Otherwise \
                search_field again with what they tell you, then call answer_form with the chosen id.
                """
        }
        return payload
    }

    /// How the story answers this step, if it does.
    private func storyAnswer(
        _ story: StoryFacts,
        for intent: ClaimIntent
    ) -> (() async throws -> VoiceStepPayload)? {
        let stepId = intent.currentStep.id
        switch intent.currentStep.content {
        case let .singleSelect(model):
            let ids = Set(model.options.map(\.id))
            guard
                let optionId = [story.category, story.subcategory].compactMap({ $0 }).first(where: ids.contains)
                    ?? Self.countOption(story.itemCount, in: model.options)
            else { return nil }
            return {
                let leaves = VoiceStepAdapter.leavesPlaybooks(content: intent.currentStep.content, optionId: optionId)
                let result = try await self.service.claimIntentSubmitSelect(stepId: stepId, selectedValue: optionId)
                let label = model.options.first { $0.id == optionId }?.title ?? optionId
                self.record(intent, answer: label, replay: .select(optionId))
                let next = try await self.adopt(result, waitFully: true)
                guard leaves else { return next }
                let reason = "this kind of claim has its own questions in the chat"
                self.handoffReason = reason
                return .handoff(reason: reason)
            }
        case let .audioRecording(model):
            let words = String(memberWords(fallback: "").prefix(model.freeTextMaxLength))
            guard !hasAnsweredFreeText, !words.isEmpty else { return nil }
            return {
                let result = try await self.service.claimIntentSubmitAudio(fileId: nil, freeText: words, stepId: stepId)
                self.record(intent, answer: words, replay: .freeText(words))
                let next = try await self.adopt(result, waitFully: true)
                self.hasAnsweredFreeText = true
                return next
            }
        case let .form(model):
            // Only dates and choices, each from the story or already filled in by the engine (it reads the
            // description too). Anything else, like a phone number, is the member's to confirm.
            let values = model.fields.map { field -> FieldValue? in
                switch field.type {
                case .date:
                    if let date = story.date, Self.isDate(date) { return FieldValue(id: field.id, values: [date]) }
                case .singleSelect:
                    break
                default:
                    return nil
                }
                let filled = field.currentValues.isEmpty ? field.defaultValues : field.currentValues
                return filled.isEmpty ? nil : FieldValue(id: field.id, values: filled)
            }
            guard !values.isEmpty, !values.contains(where: { $0 == nil }) else { return nil }
            return {
                let fields = values.compactMap { $0 }
                let result = try await self.service.claimIntentSubmitForm(fields: fields, stepId: stepId)
                self.record(intent, answer: self.describe(fields, in: model), replay: .form(fields))
                return try await self.adopt(result, waitFully: true)
            }
        default:
            return nil
        }
    }

    /// Search matches for the agent: the five best, plus the "model unknown" entry (the member's own words as an
    /// unidentified item) wherever it ranks, labelled so the agent can use it when they don't know the exact model.
    private static func spokenOptions(_ result: FormFieldSearchResult) -> [VoiceStepPayload.Option] {
        let unknown = result.options.filter(isUnidentified)
        let matches = result.options.filter { !isUnidentified($0) }.prefix(5)
        return matches.map { VoiceStepPayload.Option(id: $0.value, label: $0.title, subtitle: $0.subtitle) }
            + unknown.map {
                VoiceStepPayload.Option(
                    id: $0.value,
                    label: $0.title,
                    subtitle: "model unknown: use this when the member doesn't know the exact model"
                )
            }
    }

    private static func isUnidentified(
        _ option: ClaimIntentStepContentForm.ClaimIntentStepContentFormFieldOption
    ) -> Bool {
        if option.isCustomSearchEntry { return true }
        // The value is base64 JSON describing the item; an unidentified one says so.
        guard let data = Data(base64Encoded: option.value), let json = String(data: data, encoding: .utf8) else {
            return false
        }
        return json.contains(#""isUnidentified":true"#)
    }

    /// The option for "how many items" questions, whose options are numbers and a last "4 +".
    private static func countOption(
        _ count: Int?,
        in options: [ClaimIntentContentSelectOption]
    ) -> String? {
        guard let count, count > 0 else { return nil }
        let numbered = options.compactMap { option -> (Int, String)? in
            let digits = option.title.prefix { $0.isNumber }
            return Int(digits).map { ($0, option.id) }
        }
        guard numbered.count == options.count else { return nil }
        if let exact = numbered.first(where: { $0.0 == count }) { return exact.1 }
        return numbered.max(by: { $0.0 < $1.0 }).flatMap { count > $0.0 ? $0.1 : nil }
    }

    private static func isDate(_ text: String) -> Bool {
        text.range(of: #"^\d{4}-\d{2}-\d{2}$"#, options: .regularExpression) != nil
    }

    // MARK: - Internals

    /// The advance's result if it finishes within `timeout`, else nil while it keeps running. Returns as soon as
    /// either happens: a task group would wait for the engine's child too, which is exactly what this avoids.
    private func finished(_ advance: Task<ClaimIntent, Error>, within timeout: Duration) async throws -> ClaimIntent? {
        let race = FirstResult<ClaimIntent?>()
        let result = try await withCheckedThrowingContinuation { continuation in
            race.continuation = continuation
            Task { @MainActor in
                do { race.finish(.success(try await advance.value)) } catch { race.finish(.failure(error)) }
            }
            Task { @MainActor in
                try? await Task.sleep(for: timeout)
                race.finish(.success(nil))
            }
        }
        if result != nil, pendingAdvance == advance { pendingAdvance = nil }
        return result
    }

    private func currentPayload(after intent: ClaimIntent) throws -> VoiceStepPayload {
        pendingAdvance = nil
        currentIntent = intent
        return try currentPayload()
    }

    private func currentPayload() throws -> VoiceStepPayload {
        guard let currentIntent else { throw ClaimIntentError.invalidResponse }
        let payload = VoiceStepAdapter.payload(for: currentIntent, policies: policies)
        if payload.status == .handoff {
            handoffReason = "the member is redirected to another kind of help"
        }
        return payload
    }

    /// Task steps are the engine thinking (the LLM turn, transcription). Voice waits them out here, polling like
    /// `SubmitClaimTaskStep`, so the agent only ever sees steps it can say.
    private func advancingTasks(_ intent: ClaimIntent) async throws -> ClaimIntent {
        var intent = intent
        let clock = ContinuousClock()
        let deadline = clock.now.advanced(by: taskTimeout)
        while case let .task(model) = intent.currentStep.content {
            if model.isCompleted {
                guard case let .intent(next)? = try await service.claimIntentSubmitTask(stepId: intent.currentStep.id)
                else { throw ClaimIntentError.invalidResponse }
                intent = next
                continue
            }
            guard clock.now < deadline else { throw ClaimIntentError.error(message: "Hedvig is taking too long.") }
            // Often enough that a finished engine turn isn't left waiting for the next poll.
            try await sleep(.milliseconds(300))
            guard case let .intent(polled)? = try await service.getNextStep(claimIntentId: intent.id) else {
                throw ClaimIntentError.invalidResponse
            }
            intent = polled
        }
        return intent
    }

    private func currentIntent(matching stepId: String) throws -> ClaimIntent {
        guard let currentIntent else { throw ClaimIntentError.invalidResponse }
        guard currentIntent.currentStep.id == stepId else {
            throw VoiceTool.InvalidCall(message: "That step is no longer current. Continue with current_step.")
        }
        return currentIntent
    }

    private func wrongKind(_ intent: ClaimIntent) -> Error {
        let kind = VoiceStepAdapter.payload(for: intent).kind.rawValue
        return VoiceTool.InvalidCall(message: "The current step is a \(kind) step; use the tool for that kind.")
    }

    /// The member's own words for a free-text answer: everything they said up to the first free-text answer (the
    /// opening story, which the engine's description step wants whole), then what they said since the last answer.
    /// Empty when they haven't said anything new: the agent must not answer for them. The agent's version is only
    /// used when no transcript has arrived in the whole call (transcription not working).
    private func memberWords(fallback: String) -> String {
        guard !memberUtterances.isEmpty else { return fallback.trimmingCharacters(in: .whitespacesAndNewlines) }
        let words = hasAnsweredFreeText ? Array(memberUtterances.dropFirst(answeredUtteranceCount)) : memberUtterances
        return words.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func markAnswered() {
        answeredUtteranceCount = memberUtterances.count
    }

    /// Whether the agent's version of an answer is the member's own, said at some point in the call: every number
    /// in it was said by the member ("2,500", "2 500" and "twenty-five hundred" are the same), and at least three
    /// quarters of its other words too. Small words like "the" or "about" and currency names don't count either
    /// way, and a word counts as said when the member said a form of it ("leak" for "leaked").
    static func isGrounded(_ text: String, in utterances: [String]) -> Bool {
        let words = spokenWords(text)
        guard !words.isEmpty else { return false }
        let heardWords = utterances.flatMap(spokenWords)
        let heardNumbers = utterances.reduce(into: Set<Int>()) { $0.formUnion(numbers(in: spokenWords($1))) }
        let numbersSaid = numbers(in: words)
        guard numbersSaid.isSubset(of: heardNumbers) else { return false }
        let content = words.filter { word in
            Int(word) == nil && numberWords[word] == nil && !["hundred", "thousand"].contains(word)
                && !smallWords.contains(word)
        }
        guard !content.isEmpty else { return !numbersSaid.isEmpty }
        let heard = Set(heardWords)
        let found = content.filter { word in heard.contains(word) || heardWords.contains { sameStem(word, $0) } }
        return Double(found.count) >= Double(content.count) * 0.75
    }

    /// Words that say nothing about the answer itself, so the agent adding or dropping them doesn't matter.
    private static let smallWords: Set<String> = [
        "the", "a", "an", "and", "or", "of", "to", "in", "on", "at", "it", "its", "it's", "is", "was", "were", "be",
        "been", "i", "i'm", "me", "my", "we", "our", "you", "your", "that", "this", "for", "with", "about", "around",
        "roughly", "approximately", "some", "uh", "um", "so", "but", "just", "really", "actually", "then", "there",
        "kronor", "kroner", "krona", "crowns", "kr", "sek", "och", "det", "den", "en", "ett", "jag", "min", "mitt",
        "mina", "att", "på", "som", "var", "är", "har", "med", "för", "om", "av", "till", "ungefär", "typ", "cirka",
    ]

    /// "leak" and "leaked", "grocery" and "groceries": the same word for grounding.
    private static func sameStem(_ word: String, _ other: String) -> Bool {
        guard word.count >= 4, other.count >= 4 else { return false }
        let common = zip(word, other).prefix { $0 == $1 }.count
        return common >= min(word.count, other.count, 5)
    }

    private static let numberWords: [String: Int] = [
        "zero": 0, "one": 1, "two": 2, "three": 3, "four": 4, "five": 5, "six": 6, "seven": 7, "eight": 8,
        "nine": 9, "ten": 10, "eleven": 11, "twelve": 12, "thirteen": 13, "fourteen": 14, "fifteen": 15,
        "sixteen": 16, "seventeen": 17, "eighteen": 18, "nineteen": 19, "twenty": 20, "thirty": 30, "forty": 40,
        "fifty": 50, "sixty": 60, "seventy": 70, "eighty": 80, "ninety": 90,
    ]

    /// The numbers in some words, written ("2500") or spoken ("twenty five hundred", "two thousand five hundred").
    static func numbers(in words: [String]) -> Set<Int> {
        var found = Set<Int>()
        var total = 0
        var current = 0
        var inNumber = false
        func finish() {
            if inNumber { found.insert(total + current) }
            total = 0
            current = 0
            inNumber = false
        }
        for word in words {
            if let value = Int(word) {
                finish()
                found.insert(value)
            } else if let value = numberWords[word] {
                current += value
                inNumber = true
            } else if word == "hundred" {
                current = max(current, 1) * 100
                inNumber = true
            } else if word == "thousand" {
                total += max(current, 1) * 1000
                current = 0
                inNumber = true
            } else if !(word == "and" && inNumber) {
                finish()
            }
        }
        finish()
        return found
    }

    /// Whether the member said they don't know, in English or Swedish.
    static func saysDontKnow(_ utterances: [String]) -> Bool {
        let phrases = [
            "don't know", "dont know", "do not know", "no idea", "not sure", "unsure", "no clue", "haven't checked",
            "vet inte", "ingen aning", "osäker", "inte säker",
        ]
        let text = utterances.joined(separator: " ").lowercased().replacingOccurrences(of: "’", with: "'")
        return phrases.contains { text.contains($0) }
    }

    /// A bare yes, okay or thanks, in English or Swedish, with nothing else in it: not an answer to an open
    /// question, so what it confirms or what they said before is.
    static func isAcknowledgement(_ text: String) -> Bool {
        let acknowledging: Set<String> = [
            "yes", "yeah", "yep", "yup", "correct", "right", "exactly", "that's", "it", "is", "okay", "ok", "sure",
            "mm", "mhm", "hmm", "alright", "fine", "good", "great", "perfect", "sounds", "absolutely", "definitely",
            "thanks", "thank", "you", "cheers", "ja", "japp", "jo", "precis", "exakt", "stämmer", "det", "rätt",
            "okej", "visst", "absolut", "bra", "tack",
        ]
        let words = spokenWords(text)
        return !words.isEmpty && words.count <= 5 && words.allSatisfy(acknowledging.contains)
    }

    private static func spokenWords(_ text: String) -> [String] {
        // Thousands separators out first, so numbers survive the split as one word.
        let joined = text.lowercased()
            .replacingOccurrences(of: "’", with: "'")
            .replacingOccurrences(of: #"(?<=\d)[,  ](?=\d{3})"#, with: "", options: .regularExpression)
        return joined.split { !$0.isLetter && !$0.isNumber && $0 != "'" }.map(String.init)
    }

    /// The agent now has this step (as a tool result or an [APP] message).
    func delivered(_ payload: VoiceStepPayload) {
        guard payload.status == .step, let stepId = payload.stepId else { return }
        deliveredStepId = stepId
        utterancesAtDelivery = memberUtterances.count
    }
}

/// The agent tried to save something while its question to the member is still unanswered.
private struct WaitForMember: LocalizedError {
    var errorDescription: String? {
        """
        You just asked the member something and they heard you; they haven't answered yet. Don't repeat or rephrase \
        it and don't say anything else: end your turn now, and save their answer once they reply.
        """
    }
}

extension VoiceTool {
    fileprivate var isHandoff: Bool {
        if case .handOffToChat = self { return true }
        return false
    }

    fileprivate var isGoBack: Bool {
        if case .goBack = self { return true }
        return false
    }

    fileprivate var isNoteStory: Bool {
        if case .noteStory = self { return true }
        return false
    }

    fileprivate var answersAStep: Bool {
        switch self {
        case .answerSelect, .answerForm, .answerFreeText, .acknowledgeNotice, .skipStep: return true
        default: return false
        }
    }
}

/// Resumes a continuation with whichever result arrives first and ignores the rest.
@MainActor
private final class FirstResult<Value: Sendable> {
    var continuation: CheckedContinuation<Value, Error>?

    func finish(_ result: Result<Value, Error>) {
        continuation?.resume(with: result)
        continuation = nil
    }
}
