import Foundation
import TestDependencies
import Testing
import hCore

@testable import SubmitClaimChat

// MARK: - Pure mapping (no shared state)

@MainActor
final class VoiceStepAdapterTests {
    @Test
    func selectStepCarriesOptionIdsAndQuestion() {
        let payload = VoiceStepAdapter.payload(for: VoiceFixtures.triageCategory)

        #expect(payload.status == .step)
        #expect(payload.kind == .select)
        #expect(payload.stepId == "triage-category")
        #expect(payload.question == "What happened?")
        #expect(payload.options?.map(\.id) == ["Home", "Things", "Travel"])
    }

    @Test
    func policyOptionsSayWhatTheyCover() throws {
        let payload = VoiceStepAdapter.payload(
            for: VoiceFixtures.insurancePicker,
            policies: ["home-policy": "apartment (rented)", "summer-policy": "vacation home or summer house"]
        )
        let options = try #require(payload.fields?.first?.options)

        #expect(options.map(\.covers) == ["apartment (rented)", "vacation home or summer house", nil])
    }

    @Test
    func noticeIsSpokenFromTheNoticeText() {
        let payload = VoiceStepAdapter.payload(for: VoiceFixtures.notice)

        #expect(payload.kind == .notice)
        #expect(payload.question == "Shut off the water within 48 hours.")
    }

    @Test
    func deflectionHandsOver() {
        let payload = VoiceStepAdapter.payload(for: VoiceFixtures.deflectMessage)

        #expect(payload.status == .handoff)
    }

    @Test
    func formFieldsKeepTypesAndDefaults() throws {
        let payload = VoiceStepAdapter.payload(for: VoiceFixtures.dateForm)
        let field = try #require(payload.fields?.first)

        #expect(payload.kind == .form)
        #expect(field.id == "date")
        #expect(field.type == "date")
        #expect(field.currentValues == ["2026-11-18"])
    }

    @Test
    func triageAnswersOutsideThePlaybooksLeaveVoice() {
        let triage = VoiceFixtures.triageCategory.currentStep.content
        #expect(VoiceStepAdapter.leavesPlaybooks(content: triage, optionId: "Travel"))
        #expect(!VoiceStepAdapter.leavesPlaybooks(content: triage, optionId: "Home"))
        #expect(
            VoiceStepAdapter.leavesPlaybooks(content: VoiceFixtures.thingsItem.currentStep.content, optionId: "Bike")
        )
        #expect(
            !VoiceStepAdapter.leavesPlaybooks(
                content: VoiceFixtures.thingsItem.currentStep.content,
                optionId: "WhiteGoods"
            )
        )
    }

    @Test
    func nonTriageSelectNeverLeavesVoice() {
        #expect(!VoiceStepAdapter.leavesPlaybooks(content: VoiceFixtures.yesNo.currentStep.content, optionId: "no"))
    }

    @Test
    func answerFormAcceptsAnArrayOrAJsonString() throws {
        let fromArray = try VoiceTool(
            name: "answer_form",
            parameters: ["step_id": "s", "fields": [["field_id": "date", "values": ["2026-11-18"]]]]
        )
        let fromString = try VoiceTool(
            name: "answer_form",
            parameters: ["step_id": "s", "fields": #"[{"field_id":"date","value":"2026-11-18"}]"#]
        )
        let expected = VoiceTool.answerForm(stepId: "s", fields: [FieldValue(id: "date", values: ["2026-11-18"])])

        #expect(fromArray == expected)
        #expect(fromString == expected)
    }

    @Test
    func missingParameterIsAnInvalidCall() {
        #expect(throws: VoiceTool.InvalidCall.self) {
            try VoiceTool(name: "answer_select", parameters: ["step_id": "s"])
        }
    }
}

// MARK: - Toolbox against a mocked engine (shares Dependencies.shared)

extension SubmitClaimChatDependencySuite {
    @MainActor
    final class VoiceClaimToolboxTests {
        // Each test registers its own client and removes it before returning (see `cleanUp`), since the suite's
        // siblings share Dependencies.shared.
        private func makeToolbox(
            _ client: MockVoiceClaimIntentClient,
            answerWait: Duration = .seconds(3)
        ) -> VoiceClaimToolbox {
            Dependencies.shared.add(module: Module { () -> ClaimIntentClient in client })
            return VoiceClaimToolbox(
                sleep: { _ in },
                taskTimeout: .seconds(5),
                answerWait: answerWait,
                fillerGap: .seconds(3)
            )
        }

        private func cleanUp() {
            Dependencies.shared.remove(for: ClaimIntentClient.self)
        }

        @Test
        func startReturnsTheFirstStep() async throws {
            defer { cleanUp() }
            let toolbox = makeToolbox(MockVoiceClaimIntentClient(start: VoiceFixtures.triageCategory))

            let payload = try await toolbox.start()

            #expect(payload.stepId == "triage-category")
        }

        @Test
        func freeTextSendsTheMembersOwnWordsNotTheAgentsSummary() async throws {
            defer { cleanUp() }
            let client = MockVoiceClaimIntentClient(start: VoiceFixtures.triageCategory)
            client.nextAfterSelect = VoiceFixtures.description
            let toolbox = makeToolbox(client)
            _ = try await toolbox.start()

            toolbox.recordMemberUtterance("The dishwasher leaked all over the kitchen floor last night.")
            toolbox.recordMemberUtterance("Yes, that's right.")
            _ = await toolbox.handle(
                toolName: "answer_select",
                parameters: ["step_id": "triage-category", "option_id": "Home"]
            )
            _ = await toolbox.handle(
                toolName: "answer_free_text",
                parameters: ["step_id": "description", "member_words": "Dishwasher leak."]
            )

            #expect(
                client.submittedFreeText
                    == "The dishwasher leaked all over the kitchen floor last night. Yes, that's right."
            )
        }

        @Test
        func aFreeTextAnswerTheMemberNeverGaveIsRefused() async throws {
            defer { cleanUp() }
            let client = MockVoiceClaimIntentClient(start: VoiceFixtures.description)
            client.nextAfterAudio = VoiceFixtures.spoiledFood
            let toolbox = makeToolbox(client)
            _ = try await toolbox.start()
            toolbox.recordMemberUtterance("It just stopped cooling.")
            _ = await toolbox.handle(
                toolName: "answer_free_text",
                parameters: ["step_id": "description", "member_words": "It stopped cooling."]
            )

            // The agent asks the next question and, without waiting, answers it itself.
            let result = try json(
                await toolbox.handle(
                    toolName: "answer_free_text",
                    parameters: ["step_id": "spoiled-food", "member_words": "Some milk and meat, about 300 kronor."]
                )
            )

            #expect(result["status"] as? String == "error")
            #expect(client.events == [.start, .submitAudio])
            #expect(client.submittedFreeText == "It just stopped cooling.")
        }

        @Test
        func choosingANonPlaybookTriageOptionHandsOver() async throws {
            defer { cleanUp() }
            let client = MockVoiceClaimIntentClient(start: VoiceFixtures.triageCategory)
            client.nextAfterSelect = VoiceFixtures.dateForm
            let toolbox = makeToolbox(client)
            _ = try await toolbox.start()

            let answer = try json(
                await toolbox.handle(
                    toolName: "answer_select",
                    parameters: ["step_id": "triage-category", "option_id": "Travel"]
                )
            )
            let afterwards = try json(await toolbox.handle(toolName: "get_current_step", parameters: [:]))

            #expect(client.events == [.start, .submitSelect("Travel")])
            #expect(answer["status"] as? String == "handoff")
            #expect(afterwards["status"] as? String == "handoff")
        }

        @Test
        func taskStepsAreWaitedOutBeforeTheAgentSeesTheNextStep() async throws {
            defer { cleanUp() }
            let client = MockVoiceClaimIntentClient(start: VoiceFixtures.yesNo)
            client.nextAfterSelect = VoiceFixtures.task(completed: false)
            client.nextStepPolls = [VoiceFixtures.task(completed: true)]
            client.nextAfterTask = VoiceFixtures.notice
            let toolbox = makeToolbox(client)
            _ = try await toolbox.start()

            let result = try json(
                await toolbox.handle(toolName: "answer_select", parameters: ["step_id": "yes-no", "option_id": "no"])
            )

            #expect(result["kind"] as? String == "notice")
            #expect(client.events == [.start, .submitSelect("no"), .getNextStep, .submitTask])
        }

        @Test
        func aSlowEngineTurnHandsThePauseToTheAgentThenDeliversTheStep() async throws {
            defer { cleanUp() }
            let client = MockVoiceClaimIntentClient(start: VoiceFixtures.yesNo)
            client.nextAfterSelect = VoiceFixtures.task(completed: false)
            client.nextStepPolls = [VoiceFixtures.task(completed: true)]
            client.nextAfterTask = VoiceFixtures.notice
            client.holdNextStep = true
            let toolbox = makeToolbox(client, answerWait: .milliseconds(50))
            _ = try await toolbox.start()

            let answer = try json(
                await toolbox.handle(toolName: "answer_select", parameters: ["step_id": "yes-no", "option_id": "no"])
            )
            client.holdNextStep = false
            let next = try json(await toolbox.handle(toolName: "get_current_step", parameters: [:]))

            #expect(answer["status"] as? String == "processing")
            #expect(next["kind"] as? String == "notice")
        }

        @Test
        func aStaleStepIdIsAnErrorCarryingTheCurrentStep() async throws {
            defer { cleanUp() }
            let toolbox = makeToolbox(MockVoiceClaimIntentClient(start: VoiceFixtures.triageCategory))
            _ = try await toolbox.start()

            let result = try json(
                await toolbox.handle(toolName: "answer_select", parameters: ["step_id": "old", "option_id": "Home"])
            )
            let current = try #require(result["current_step"] as? [String: Any])

            #expect(result["status"] as? String == "error")
            #expect(current["step_id"] as? String == "triage-category")
        }

        @Test
        func notedStoryAnswersTheOpeningStepsUpToTheFirstRealQuestion() async throws {
            defer { cleanUp() }
            let client = MockVoiceClaimIntentClient(start: VoiceFixtures.triageCategory)
            client.selectChain = [VoiceFixtures.thingsItem, VoiceFixtures.description]
            client.nextAfterAudio = VoiceFixtures.dateForm
            client.nextAfterForm = VoiceFixtures.yesNo
            let toolbox = makeToolbox(client)
            _ = try await toolbox.start()
            toolbox.recordMemberUtterance("My fridge stopped cooling at home yesterday.")

            let result = try json(
                await toolbox.handle(
                    toolName: "note_story",
                    parameters: ["category": "Things", "subcategory": "WhiteGoods", "date": "2026-11-18"]
                )
            )

            #expect(
                client.events == [
                    .start, .submitSelect("Things"), .submitSelect("WhiteGoods"), .submitAudio, .submitForm,
                ]
            )
            #expect(client.submittedFreeText == "My fridge stopped cooling at home yesterday.")
            #expect(client.submittedFormValues == ["2026-11-18"])
            #expect(result["step_id"] as? String == "yes-no")
        }

        @Test
        func notedStoryFillsPrefilledFormsAndTheCountThenSearchesForTheItem() async throws {
            defer { cleanUp() }
            let client = MockVoiceClaimIntentClient(start: VoiceFixtures.triageCategory)
            client.selectChain = [VoiceFixtures.thingsItem, VoiceFixtures.description, VoiceFixtures.itemSearch]
            client.nextAfterAudio = VoiceFixtures.dateAndLocationForm
            client.nextAfterForm = VoiceFixtures.itemCount
            client.searchOptions = [.init(title: "GBB62 fridge-freezer", subtitle: "LG", value: "lg-gbb62")]
            let toolbox = makeToolbox(client)
            _ = try await toolbox.start()
            toolbox.recordMemberUtterance("My LG fridge stopped cooling at home yesterday.")

            let result = try json(
                await toolbox.handle(
                    toolName: "note_story",
                    parameters: [
                        "category": "Things", "subcategory": "WhiteGoods", "date": "2026-11-18", "item_count": 1,
                        "item": "LG fridge",
                    ]
                )
            )
            let matches = try #require(result["search_results"] as? [[String: Any]])

            #expect(
                client.events == [
                    .start, .submitSelect("Things"), .submitSelect("WhiteGoods"), .submitAudio, .submitForm,
                    .submitSelect("count-1"), .other("search"),
                ]
            )
            #expect(client.submittedFormValues == ["2026-11-18", "AT_HOME"])
            #expect(result["step_id"] as? String == "item-search")
            #expect(matches.first?["id"] as? String == "lg-gbb62")
        }

        @Test
        func stepsBeforeTheRecapAreHeldBack() async throws {
            defer { cleanUp() }
            let client = MockVoiceClaimIntentClient(start: VoiceFixtures.triageCategory)
            let toolbox = makeToolbox(client)
            _ = try await toolbox.start()

            let result = try json(await toolbox.handle(toolName: "get_current_step", parameters: [:]))

            #expect(result["status"] as? String == "waiting")
        }

        @Test
        func theSameStepIsNotHandedOutAgainUntilTheMemberSpeaks() async throws {
            defer { cleanUp() }
            let client = MockVoiceClaimIntentClient(start: VoiceFixtures.triageCategory)
            let toolbox = makeToolbox(client)
            _ = try await toolbox.start()
            _ = await toolbox.handle(toolName: "note_story", parameters: [:])

            let beforeAnswer = try json(await toolbox.handle(toolName: "get_current_step", parameters: [:]))
            toolbox.recordMemberUtterance("Hmm, what do you mean?")
            let afterAnswer = try json(await toolbox.handle(toolName: "get_current_step", parameters: [:]))

            #expect(beforeAnswer["status"] as? String == "waiting")
            #expect(afterAnswer["step_id"] as? String == "triage-category")
        }

        @Test
        func nothingIsSavedWhileTheAgentsQuestionIsUnanswered() async throws {
            defer { cleanUp() }
            let client = MockVoiceClaimIntentClient(start: VoiceFixtures.triageCategory)
            let toolbox = makeToolbox(client)
            _ = try await toolbox.start()
            toolbox.recordMemberUtterance("My fridge broke at home yesterday.")

            // The recap ends in a question; the agent calls note_story without waiting.
            toolbox.recordAgentUtterance("Your fridge broke at home yesterday. Is that right?")
            let tooEarly = try json(await toolbox.handle(toolName: "note_story", parameters: ["category": "Home"]))
            toolbox.recordMemberUtterance("Yes.")
            let afterYes = try json(await toolbox.handle(toolName: "note_story", parameters: [:]))

            #expect(tooEarly["status"] as? String == "error")
            #expect(client.events == [.start])
            #expect(afterYes["step_id"] as? String == "triage-category")
        }

        @Test
        func theModelUnknownMatchIsAlwaysOfferedAndLabelled() async throws {
            defer { cleanUp() }
            let client = MockVoiceClaimIntentClient(start: VoiceFixtures.itemSearch)
            client.searchOptions =
                (1...6).map { .init(title: "Model \($0)", subtitle: "LG", value: "lg-\($0)") }
                + [.init(title: "LG fridge", subtitle: nil, value: "unknown", isCustomSearchEntry: true)]
            let toolbox = makeToolbox(client)
            _ = try await toolbox.start()

            let result = try json(
                await toolbox.handle(
                    toolName: "search_field",
                    parameters: ["step_id": "item-search", "field_id": "item", "query": "LG fridge"]
                )
            )
            let options = try #require(result["options"] as? [[String: Any]])

            #expect(options.count == 6)
            #expect(options.last?["id"] as? String == "unknown")
            #expect((options.last?["subtitle"] as? String)?.hasPrefix("model unknown") == true)
        }

        @Test
        func notedStoryLeavesAStepItDoesntAnswerToTheAgent() async throws {
            defer { cleanUp() }
            let client = MockVoiceClaimIntentClient(start: VoiceFixtures.triageCategory)
            let toolbox = makeToolbox(client)
            _ = try await toolbox.start()

            let result = try json(await toolbox.handle(toolName: "note_story", parameters: ["date": "2026-11-18"]))

            #expect(client.events == [.start])
            #expect(result["step_id"] as? String == "triage-category")
        }

        @Test
        func notedStoryWaitsOutTheEngineInsteadOfPausing() async throws {
            defer { cleanUp() }
            let client = MockVoiceClaimIntentClient(start: VoiceFixtures.triageCategory)
            client.selectChain = [VoiceFixtures.task(completed: false)]
            client.nextStepPolls = [VoiceFixtures.task(completed: true)]
            client.nextAfterTask = VoiceFixtures.notice
            let toolbox = makeToolbox(client, answerWait: .milliseconds(1))
            _ = try await toolbox.start()

            let result = try json(await toolbox.handle(toolName: "note_story", parameters: ["category": "Home"]))

            #expect(result["kind"] as? String == "notice")
        }

        private func json(_ text: String) throws -> [String: Any] {
            let object = try JSONSerialization.jsonObject(with: Data(text.utf8))
            return try #require(object as? [String: Any])
        }
    }
}

// MARK: - Fixtures

@MainActor
enum VoiceFixtures {
    static func intent(_ id: String, _ content: ClaimIntentStepContent, text: String? = nil) -> ClaimIntent {
        ClaimIntent(
            currentStep: .init(content: content, id: id, text: text),
            id: "intent-1",
            isSkippable: true,
            isRegrettable: false,
            progress: 0
        )
    }

    static let triageCategory = intent(
        "triage-category",
        .singleSelect(
            model: .init(
                defaultSelectedId: nil,
                options: [
                    .init(id: "Home", title: "Home"), .init(id: "Things", title: "Things"),
                    .init(id: "Travel", title: "Travel"),
                ],
                style: .pill
            )
        ),
        text: "What happened?"
    )

    static let thingsItem = intent(
        "things-item",
        .singleSelect(
            model: .init(
                defaultSelectedId: nil,
                options: [
                    .init(id: "Phone", title: "Phone"), .init(id: "Bike", title: "Bike"),
                    .init(id: "WhiteGoods", title: "Appliance"),
                ],
                style: .pill
            )
        )
    )

    static let yesNo = intent(
        "yes-no",
        .singleSelect(
            model: .init(
                defaultSelectedId: nil,
                options: [.init(id: "yes", title: "Yes"), .init(id: "no", title: "No")],
                style: .binary
            )
        ),
        text: "Is water still leaking?"
    )

    static let description = intent(
        "description",
        .audioRecording(model: .init(uploadURI: "/upload", freeTextMinLength: 1, freeTextMaxLength: 2000)),
        text: "Tell us what happened."
    )

    static let spoiledFood = intent(
        "spoiled-food",
        .audioRecording(model: .init(uploadURI: "/upload", freeTextMinLength: 1, freeTextMaxLength: 2000)),
        text: "Did anything inside spoil?"
    )

    static let notice = intent(
        "notice",
        .information(model: .init(notice: "Shut off the water within 48 hours.", buttonTitle: "OK"))
    )

    static let deflectMessage = intent("deflect", .deflectMessage(model: .init(message: "Call 112.")))

    static let dateForm = intent(
        "date-form",
        .form(
            model: .init(fields: [
                .init(
                    defaultValues: ["2026-11-18"],
                    id: "date",
                    isRequired: true,
                    maxValue: nil,
                    minValue: nil,
                    options: [],
                    suffix: nil,
                    searchData: nil,
                    title: "When did it happen?",
                    type: .date
                )
            ])
        )
    )

    static let dateAndLocationForm = intent(
        "date-location",
        .form(
            model: .init(fields: [
                .init(
                    defaultValues: [],
                    id: "dateOfOccurrence",
                    isRequired: false,
                    maxValue: nil,
                    minValue: nil,
                    options: [],
                    suffix: nil,
                    searchData: nil,
                    title: "Date of incident",
                    type: .date
                ),
                .init(
                    defaultValues: [],
                    id: "location",
                    isRequired: false,
                    maxValue: nil,
                    minValue: nil,
                    options: [.init(title: "At home", subtitle: nil, value: "AT_HOME")],
                    suffix: nil,
                    searchData: nil,
                    title: "Location",
                    type: .singleSelect,
                    currentValues: ["AT_HOME"]
                ),
            ])
        )
    )

    static let singleInsurance = intent(
        "insurance",
        .form(
            model: .init(fields: [
                .init(
                    defaultValues: [],
                    id: "agreement",
                    isRequired: true,
                    maxValue: nil,
                    minValue: nil,
                    options: [
                        .init(title: "Home Standard", subtitle: "Emaljvägen 8 lgh 1401", value: "home-policy"),
                        .init(title: "I'm not sure", subtitle: nil, value: "NOT_SURE"),
                    ],
                    suffix: nil,
                    searchData: nil,
                    title: "Which insurance is it about?",
                    type: .singleSelect
                )
            ])
        )
    )

    static let insurancePicker = intent(
        "insurance",
        .form(
            model: .init(fields: [
                .init(
                    defaultValues: [],
                    id: "agreement",
                    isRequired: true,
                    maxValue: nil,
                    minValue: nil,
                    options: [
                        .init(title: "Home Standard", subtitle: "Emaljvägen 8 lgh 1401", value: "home-policy"),
                        .init(title: "Vacation Home Standard", subtitle: "Skydraget 38", value: "summer-policy"),
                        .init(title: "I'm not sure", subtitle: nil, value: "NOT_SURE"),
                    ],
                    suffix: nil,
                    searchData: nil,
                    title: "Which insurance is it about?",
                    type: .singleSelect
                )
            ])
        )
    )

    static let itemCount = intent(
        "item-count",
        .singleSelect(
            model: .init(
                defaultSelectedId: nil,
                options: [
                    .init(id: "count-1", title: "1"), .init(id: "count-2", title: "2"),
                    .init(id: "count-more", title: "4 +"),
                ],
                style: .pill
            )
        )
    )

    static let itemSearch = intent(
        "item-search",
        .form(
            model: .init(fields: [
                .init(
                    defaultValues: [],
                    id: "item",
                    isRequired: true,
                    maxValue: nil,
                    minValue: nil,
                    options: [],
                    suffix: nil,
                    searchData: nil,
                    title: "Search for an item",
                    type: .search
                )
            ])
        )
    )

    static func task(completed: Bool) -> ClaimIntent {
        intent("task", .task(model: .init(description: "Thinking", isCompleted: completed)))
    }
}

@MainActor
final class MockVoiceClaimIntentClient: ClaimIntentClient {
    enum Event: Equatable {
        case start
        case submitSelect(String)
        case submitAudio
        case submitForm
        case submitTask
        case getNextStep
        case other(String)
    }

    var events: [Event] = []
    var submittedFreeText: String?
    var submittedFormValues: [String]?
    /// Steps returned by successive selects, before falling back to `nextAfterSelect`.
    var selectChain: [ClaimIntent] = []
    var nextAfterSelect: ClaimIntent?
    var nextAfterAudio: ClaimIntent?
    var nextAfterForm: ClaimIntent?
    var searchOptions: [ClaimIntentStepContentForm.ClaimIntentStepContentFormFieldOption] = []
    var nextAfterTask: ClaimIntent?
    var nextStepPolls: [ClaimIntent] = []
    /// While true, getNextStep waits: the engine is "still thinking".
    var holdNextStep = false
    private let start: ClaimIntent

    init(start: ClaimIntent) {
        self.start = start
    }

    func startClaimIntent(input _: StartClaimInput) async throws -> ClaimIntentType? {
        events.append(.start)
        return .intent(model: start)
    }

    func claimIntentSubmitSelect(stepId _: String, selectedValue: String) async throws -> ClaimIntentType? {
        events.append(.submitSelect(selectedValue))
        if !selectChain.isEmpty { return selectChain.removeFirst().asType }
        return (nextAfterSelect ?? start).asType
    }

    func claimIntentSubmitAudio(fileId _: String?, freeText: String?, stepId _: String) async throws -> ClaimIntentType?
    {
        events.append(.submitAudio)
        submittedFreeText = freeText
        return (nextAfterAudio ?? VoiceFixtures.notice).asType
    }

    func claimIntentSubmitFile(stepId _: String, fileIds _: [String]) async throws -> ClaimIntentType? {
        events.append(.other("file"))
        return VoiceFixtures.notice.asType
    }

    func claimIntentSubmitForm(fields: [FieldValue], stepId _: String) async throws -> ClaimIntentType? {
        events.append(.submitForm)
        submittedFormValues = fields.flatMap(\.values)
        return (nextAfterForm ?? VoiceFixtures.notice).asType
    }

    func claimIntentSubmitSummary(stepId _: String) async throws -> ClaimIntentType? {
        events.append(.other("summary"))
        return .outcome(model: .unknown)
    }

    func claimIntentSubmitTask(stepId _: String) async throws -> ClaimIntentType? {
        events.append(.submitTask)
        return (nextAfterTask ?? VoiceFixtures.notice).asType
    }

    func claimIntentSubmitInformation(stepId _: String) async throws -> ClaimIntentType? {
        events.append(.other("information"))
        return VoiceFixtures.yesNo.asType
    }

    func claimIntentSkipStep(stepId _: String) async throws -> ClaimIntentType? {
        events.append(.other("skip"))
        return VoiceFixtures.notice.asType
    }

    func claimIntentRegretStep(stepId _: String) async throws -> ClaimIntentType? {
        events.append(.other("regret"))
        return nil
    }

    func getNextStep(claimIntentId _: String) async throws -> ClaimIntentType? {
        while holdNextStep { try await Task.sleep(for: .milliseconds(10)) }
        events.append(.getNextStep)
        return nextStepPolls.isEmpty ? nil : nextStepPolls.removeFirst().asType
    }

    func claimIntentFormFieldSearch(
        stepId _: String,
        fieldId _: String,
        query _: String
    ) async throws
        -> FormFieldSearchResult
    {
        events.append(.other("search"))
        return .init(options: searchOptions, suggestedQuery: nil)
    }
}

extension ClaimIntent {
    fileprivate var asType: ClaimIntentType { .intent(model: self) }
}
