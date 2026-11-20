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
            #expect(tooEarly["current_step"] == nil)  // handed the step again, the agent repeats it
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

        @Test
        func goingBackListsTheAnswersThenReopensTheChosenStep() async throws {
            defer { cleanUp() }
            let yesNo = VoiceFixtures.regrettable(VoiceFixtures.yesNo)
            let client = MockVoiceClaimIntentClient(start: yesNo)
            client.nextAfterSelect = VoiceFixtures.dateForm
            client.nextAfterRegret = yesNo
            let toolbox = makeToolbox(client)
            let delegate = ToolboxDelegateSpy()
            toolbox.delegate = delegate
            _ = try await toolbox.start()
            toolbox.recordMemberUtterance("No, it stopped.")
            _ = await toolbox.handle(toolName: "answer_select", parameters: ["step_id": "yes-no", "option_id": "no"])

            toolbox.recordMemberUtterance("Wait, it's actually still leaking.")
            let list = try json(await toolbox.handle(toolName: "go_back", parameters: [:]))
            let answers = try #require(list["answers"] as? [[String: Any]])
            let reopened = try json(await toolbox.handle(toolName: "go_back", parameters: ["step_id": "yes-no"]))

            #expect(list["status"] as? String == "answers")
            #expect(answers.first?["step_id"] as? String == "yes-no")
            #expect(answers.first?["question"] as? String == "Is water still leaking?")
            #expect(answers.first?["answer"] as? String == "No")
            #expect(answers.first?["can_change"] as? Bool == true)
            #expect(reopened["step_id"] as? String == "yes-no")
            #expect((reopened["instruction"] as? String)?.hasPrefix("This is the question whose answer") == true)
            #expect(client.events.last == .other("regret yes-no"))
            #expect(toolbox.answered.isEmpty)
            #expect(delegate.wentBack)
        }

        @Test
        func anAnswerTheEngineWontReopenIsNotChanged() async throws {
            defer { cleanUp() }
            let client = MockVoiceClaimIntentClient(start: VoiceFixtures.yesNo)
            client.nextAfterSelect = VoiceFixtures.dateForm
            let toolbox = makeToolbox(client)
            _ = try await toolbox.start()
            _ = await toolbox.handle(toolName: "answer_select", parameters: ["step_id": "yes-no", "option_id": "no"])

            let result = try json(await toolbox.handle(toolName: "go_back", parameters: ["step_id": "yes-no"]))

            #expect(result["status"] as? String == "error")
            #expect(!client.events.contains(.other("regret yes-no")))
            #expect(toolbox.answered.map(\.stepId) == ["yes-no"])
        }

        @Test
        func aRetoldDescriptionIsOnlyWhatTheMemberSaysAfterGoingBack() async throws {
            defer { cleanUp() }
            let description = VoiceFixtures.regrettable(VoiceFixtures.description)
            let client = MockVoiceClaimIntentClient(start: description)
            client.nextAfterAudio = VoiceFixtures.yesNo
            client.nextAfterRegret = description
            let toolbox = makeToolbox(client)
            _ = try await toolbox.start()
            toolbox.recordMemberUtterance("My fridge stopped cooling.")
            _ = await toolbox.handle(
                toolName: "answer_free_text",
                parameters: ["step_id": "description", "member_words": "Fridge stopped."]
            )

            toolbox.recordMemberUtterance("Sorry, I said that wrong.")
            _ = await toolbox.handle(toolName: "go_back", parameters: ["step_id": "description"])
            toolbox.recordMemberUtterance("It's the freezer that stopped, not the fridge.")
            _ = await toolbox.handle(
                toolName: "answer_free_text",
                parameters: ["step_id": "description", "member_words": "Freezer stopped."]
            )

            #expect(client.submittedFreeText == "It's the freezer that stopped, not the fridge.")
            #expect(toolbox.answered.map(\.answer) == ["It's the freezer that stopped, not the fridge."])
        }

        @Test
        func afterAChangeTheLaterAnswersAreSentAgainWithoutAsking() async throws {
            defer { cleanUp() }
            let yesNo = VoiceFixtures.regrettable(VoiceFixtures.yesNo)
            let client = MockVoiceClaimIntentClient(start: yesNo)
            client.selectChain = [VoiceFixtures.description]
            client.nextAfterAudio = VoiceFixtures.dateForm
            client.nextAfterRegret = yesNo
            let toolbox = makeToolbox(client)
            _ = try await toolbox.start()
            _ = await toolbox.handle(toolName: "answer_select", parameters: ["step_id": "yes-no", "option_id": "no"])
            toolbox.recordMemberUtterance("The fridge stopped cooling.")
            _ = await toolbox.handle(
                toolName: "answer_free_text",
                parameters: ["step_id": "description", "member_words": "Fridge stopped."]
            )

            toolbox.recordMemberUtterance("Actually, it is still leaking.")
            _ = await toolbox.handle(toolName: "go_back", parameters: ["step_id": "yes-no"])
            client.selectChain = [VoiceFixtures.description]
            let next = try json(
                await toolbox.handle(toolName: "answer_select", parameters: ["step_id": "yes-no", "option_id": "yes"])
            )

            #expect(Array(client.events.suffix(3)) == [.other("regret yes-no"), .submitSelect("yes"), .submitAudio])
            #expect(client.submittedFreeText == "The fridge stopped cooling.")
            #expect(next["step_id"] as? String == "date-form")
            #expect(toolbox.answered.map(\.answer) == ["Yes", "The fridge stopped cooling."])
        }

        @Test
        func aRewordedFreeTextQuestionIsLeftToTheAgentWithTheEarlierAnswersAfterAPause() async throws {
            defer { cleanUp() }
            let yesNo = VoiceFixtures.regrettable(VoiceFixtures.yesNo)
            let client = MockVoiceClaimIntentClient(start: yesNo)
            client.selectChain = [VoiceFixtures.description]
            client.nextAfterAudio = VoiceFixtures.dateForm
            client.nextAfterRegret = yesNo
            let toolbox = makeToolbox(client, answerWait: .milliseconds(50))
            _ = try await toolbox.start()
            _ = await toolbox.handle(toolName: "answer_select", parameters: ["step_id": "yes-no", "option_id": "no"])
            toolbox.recordMemberUtterance("The fridge stopped cooling.")
            _ = await toolbox.handle(
                toolName: "answer_free_text",
                parameters: ["step_id": "description", "member_words": "Fridge stopped."]
            )

            _ = await toolbox.handle(toolName: "go_back", parameters: ["step_id": "yes-no"])
            // This time the engine thinks first, and asks for the description in other words.
            client.selectChain = [VoiceFixtures.task(completed: false)]
            client.nextStepPolls = [VoiceFixtures.task(completed: true)]
            client.nextAfterTask = VoiceFixtures.intent(
                "description-2",
                VoiceFixtures.description.currentStep.content,
                text: "What went wrong with it?"
            )
            client.holdNextStep = true
            let paused = try json(
                await toolbox.handle(toolName: "answer_select", parameters: ["step_id": "yes-no", "option_id": "yes"])
            )
            client.holdNextStep = false
            let reworded = try json(await toolbox.handle(toolName: "get_current_step", parameters: [:]))
            // The agent judges that the earlier description answers it, and sends those words.
            let next = try json(
                await toolbox.handle(
                    toolName: "answer_free_text",
                    parameters: ["step_id": "description-2", "member_words": "The fridge stopped cooling."]
                )
            )

            #expect(paused["status"] as? String == "processing")
            #expect(reworded["step_id"] as? String == "description-2")
            #expect((reworded["instruction"] as? String)?.contains("→ The fridge stopped cooling.") == true)
            #expect(next["step_id"] as? String == "date-form")
            #expect(client.submittedFreeText == "The fridge stopped cooling.")
        }

        @Test
        func goingBackWaitsForABusyEngineInsteadOfPausing() async throws {
            defer { cleanUp() }
            let yesNo = VoiceFixtures.regrettable(VoiceFixtures.yesNo)
            let client = MockVoiceClaimIntentClient(start: yesNo)
            client.selectChain = [VoiceFixtures.task(completed: false)]
            client.nextStepPolls = [VoiceFixtures.task(completed: true)]
            client.nextAfterTask = VoiceFixtures.notice
            client.nextAfterRegret = yesNo
            client.holdNextStep = true
            let toolbox = makeToolbox(client, answerWait: .milliseconds(50))
            _ = try await toolbox.start()
            _ = await toolbox.handle(toolName: "answer_select", parameters: ["step_id": "yes-no", "option_id": "no"])

            Task { @MainActor in
                try await Task.sleep(for: .milliseconds(100))
                client.holdNextStep = false
            }
            let reopened = try json(await toolbox.handle(toolName: "go_back", parameters: ["step_id": "yes-no"]))

            #expect(reopened["step_id"] as? String == "yes-no")
            #expect(client.events.last == .other("regret yes-no"))
        }

        @Test
        func aNoticeHeardBeforeAChangeIsNotReadAgain() async throws {
            defer { cleanUp() }
            let yesNo = VoiceFixtures.regrettable(VoiceFixtures.yesNo)
            let client = MockVoiceClaimIntentClient(start: yesNo)
            client.selectChain = [VoiceFixtures.notice]
            client.nextAfterInformation = VoiceFixtures.dateForm
            client.nextAfterRegret = yesNo
            let toolbox = makeToolbox(client)
            _ = try await toolbox.start()
            _ = await toolbox.handle(toolName: "answer_select", parameters: ["step_id": "yes-no", "option_id": "no"])
            _ = await toolbox.handle(toolName: "acknowledge_notice", parameters: ["step_id": "notice"])

            _ = await toolbox.handle(toolName: "go_back", parameters: ["step_id": "yes-no"])
            client.selectChain = [VoiceFixtures.notice]
            let next = try json(
                await toolbox.handle(toolName: "answer_select", parameters: ["step_id": "yes-no", "option_id": "yes"])
            )
            let list = try json(await toolbox.handle(toolName: "go_back", parameters: [:]))

            #expect(Array(client.events.suffix(2)) == [.submitSelect("yes"), .other("information")])
            #expect(next["step_id"] as? String == "date-form")
            #expect((list["answers"] as? [[String: Any]])?.count == 1)  // the notice is never offered to change
        }

        @Test
        func storyAnswersAreListedWithTheirNames() async throws {
            defer { cleanUp() }
            let client = MockVoiceClaimIntentClient(start: VoiceFixtures.triageCategory)
            client.selectChain = [VoiceFixtures.thingsItem, VoiceFixtures.dateAndLocationForm]
            client.nextAfterForm = VoiceFixtures.yesNo
            let toolbox = makeToolbox(client)
            _ = try await toolbox.start()

            _ = await toolbox.handle(
                toolName: "note_story",
                parameters: ["category": "Things", "subcategory": "WhiteGoods", "date": "2026-11-18"]
            )

            #expect(
                toolbox.answered.map(\.answer) == [
                    "Things", "Appliance", "Date of incident: 2026-11-18; Location: At home",
                ]
            )
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
    static func intent(
        _ id: String,
        _ content: ClaimIntentStepContent,
        text: String? = nil,
        regrettable: Bool = false
    ) -> ClaimIntent {
        ClaimIntent(
            currentStep: .init(content: content, id: id, text: text),
            id: "intent-1",
            isSkippable: true,
            isRegrettable: regrettable,
            progress: 0
        )
    }

    /// The same step, as one the engine lets the member go back to and change.
    static func regrettable(_ intent: ClaimIntent) -> ClaimIntent {
        self.intent(intent.currentStep.id, intent.currentStep.content, text: intent.currentStep.text, regrettable: true)
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
    var nextAfterRegret: ClaimIntent?
    var nextAfterInformation: ClaimIntent?
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
        return (nextAfterInformation ?? VoiceFixtures.yesNo).asType
    }

    func claimIntentSkipStep(stepId _: String) async throws -> ClaimIntentType? {
        events.append(.other("skip"))
        return VoiceFixtures.notice.asType
    }

    func claimIntentRegretStep(stepId: String) async throws -> ClaimIntentType? {
        events.append(.other("regret \(stepId)"))
        return nextAfterRegret?.asType
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

@MainActor
final class ToolboxDelegateSpy: VoiceClaimToolboxDelegate {
    var wentBack = false

    func toolboxRequestsPhotos(for _: ClaimIntent) {}
    func toolboxRequestsSummary(for _: ClaimIntent) {}
    func toolboxRequestsHandoff(reason _: String) {}
    func toolboxDidFinish(outcome _: ClaimIntentStepOutcome) {}
    func toolboxWentBack() { wentBack = true }
}
