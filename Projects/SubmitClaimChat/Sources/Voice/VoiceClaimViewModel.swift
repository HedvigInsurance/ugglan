import AVFoundation
import Foundation
import Observation
import hCore
import hCoreUI
import os

/// The call's lifecycle, readable with `log stream --predicate 'subsystem == "com.hedvig.voiceclaim"'`.
private let callLog = Logger(subsystem: "com.hedvig.voiceclaim", category: "call")

/// One voice call that files one new claim: starts the claim intent, connects the ElevenLabs agent, runs its
/// tool calls through `VoiceClaimToolbox`, and shows the existing upload and summary views when the engine asks.
@MainActor
@Observable
final class VoiceClaimViewModel {
    enum Phase: Equatable {
        case starting
        case inCall
        case finished
        case failed
    }

    /// Why the call left voice; the launcher continues in the chat.
    enum Exit: Equatable {
        /// The claim intent exists: resume the draft in the chat.
        case continueDraftInChat
        /// No claim intent yet (no microphone, or starting failed): start the chat normally.
        case startInChat
    }

    private(set) var phase: Phase = .starting
    private(set) var status: VoiceCallStatus = .idle
    private(set) var isMuted = false
    /// The engine's upload step, shown over the orb while non-nil.
    var uploadStep: SubmitClaimFileUploadStep? = nil
    /// The engine's summary step, shown over the orb while non-nil.
    var summaryStep: SubmitClaimSummaryStep? = nil

    let router = NavigationRouter()
    @ObservationIgnored let session: VoiceAgentSession
    @ObservationIgnored private let toolbox: VoiceClaimToolbox
    @ObservationIgnored private let service: ClaimIntentService
    @ObservationIgnored private let agentId: String
    @ObservationIgnored private let locale: Localization.Locale
    @ObservationIgnored private let requestMicrophone: @MainActor () async -> Bool
    @ObservationIgnored var onExit: ((Exit) -> Void)?
    @ObservationIgnored private var hasExited = false
    /// Set when the member hangs up, so the call's own `.ended` doesn't read as a dropped line.
    @ObservationIgnored private var isEnding = false

    init(
        agentId: String,
        locale: Localization.Locale = Localization.Locale.currentLocale.value,
        session: VoiceAgentSession? = nil,
        service: ClaimIntentService = ClaimIntentService(),
        toolbox: VoiceClaimToolbox? = nil,
        requestMicrophone: @escaping @MainActor () async -> Bool = {
            await VoiceClaimViewModel.requestMicrophonePermission()
        }
    ) {
        self.agentId = agentId
        self.locale = locale
        self.session = session ?? ElevenLabsVoiceAgentSession()
        self.service = service
        self.toolbox = toolbox ?? VoiceClaimToolbox(service: service)
        self.requestMicrophone = requestMicrophone
        self.toolbox.delegate = self
        self.session.onStatusChange = { [weak self] status in self?.statusChanged(status) }
        self.session.onMuteChange = { [weak self] muted in self?.isMuted = muted }
        self.session.onMemberTranscript = { [weak self] text in self?.toolbox.recordMemberUtterance(text) }
        self.session.onAgentText = { [weak self] text in self?.toolbox.recordAgentUtterance(text) }
        self.session.toolHandler = { [weak self] name, parameters in
            guard let self else {
                return VoiceToolResult.error(message: "The call has ended.", currentStep: nil).json()
            }
            return await self.toolbox.handle(toolName: name, parameters: parameters)
        }
    }

    /// Microphone first, then the call and the claim intent at the same time: the greeting doesn't need the claim,
    /// and the agent's first tool call waits for it.
    func start() async {
        guard phase == .starting else { return }
        guard await requestMicrophone() else {
            leave(.startInChat)
            return
        }
        let claim = Task { try await toolbox.start() }
        do {
            try await session.start(
                .init(
                    agentId: agentId,
                    prompt: VoiceAgentPrompt.system,
                    firstMessage: VoiceAgentPrompt.firstMessage(for: locale),
                    languageCode: VoiceAgentPrompt.languageCode(for: locale),
                    dynamicVariables: VoiceAgentPrompt.dynamicVariables(for: locale)
                )
            )
            _ = try await claim.value
            phase = .inCall
        } catch {
            phase = .failed
            await session.end()
        }
    }

    func toggleMute() {
        let muted = !isMuted
        Task { await session.setMuted(muted) }
    }

    /// The member hung up: the draft stays, and the chat offers to continue it next time.
    func endCall() {
        isEnding = true
        Task {
            await session.end()
            close()
        }
    }

    /// The member's contract ids and what each insures, for policy choices ("which insurance is it about?").
    func setPolicies(_ policies: [String: String]) {
        toolbox.policies = policies
    }

    func switchToTyping() {
        leave(toolbox.currentIntent == nil ? .startInChat : .continueDraftInChat)
    }

    private func statusChanged(_ status: VoiceCallStatus) {
        self.status = status
        switch status {
        case .ended, .failed:
            // The line dropped, or the agent hung up, before the claim was done: offer the chat.
            if phase == .inCall, !hasExited, !isEnding { phase = .failed }
        default:
            break
        }
    }

    /// Returns once the agent has had its say: it starts speaking within `toStart` (or never does), then stays
    /// quiet for `quiet`, so a pause between two sentences doesn't count as done. Never longer than `limit`.
    /// "Speaking" is the agent's state or its actual audio: the audio stops the moment the last word is played,
    /// while the state can lag behind it.
    private func waitForAgentToFinish(
        toStart: Duration,
        quiet: Duration = .seconds(1.2),
        limit: Duration = .seconds(30)
    ) async {
        let clock = ContinuousClock()
        let startedAt = clock.now
        var hasSpoken = false
        var quietSince: ContinuousClock.Instant?
        while clock.now - startedAt < limit {
            let audible = session.audioLevels().agent > 0.05
            if audible || (status == .speaking && !hasSpoken) {
                hasSpoken = true
                quietSince = nil
            } else if hasSpoken {
                let since = quietSince ?? clock.now
                quietSince = since
                if clock.now - since >= quiet { return }
            } else if clock.now - startedAt >= toStart {
                return
            }
            try? await Task.sleep(for: .milliseconds(200))
        }
    }

    /// The app's messages, sent one after another.
    private var appMessages: Task<Void, Never>?

    /// Tells the agent something about the app ("[APP] …") without cutting it off: a message is a new turn and
    /// interrupts whatever Hedvig is saying, so it waits until she has been listening for a moment. In order.
    private func sendWhenQuiet(_ text: String) async {
        let previous = appMessages
        let task = Task { [weak self] in
            await previous?.value
            guard let self else { return }
            await self.waitUntilListening(for: .milliseconds(600), limit: .seconds(15))
            await self.session.sendAppMessage(text)
        }
        appMessages = task
        await task.value
    }

    /// Returns once the agent has been listening (not speaking or thinking) for `quiet`, or after `limit`.
    private func waitUntilListening(for quiet: Duration, limit: Duration) async {
        let clock = ContinuousClock()
        let startedAt = clock.now
        var listeningSince: ContinuousClock.Instant?
        while clock.now - startedAt < limit {
            if status == .listening {
                let since = listeningSince ?? clock.now
                listeningSince = since
                if clock.now - since >= quiet { return }
            } else {
                listeningSince = nil
            }
            try? await Task.sleep(for: .milliseconds(100))
        }
    }

    // MARK: - Sheets

    /// The member picked photos or documents: tell the agent at once (so it can react like a person would), then
    /// upload. The next step reaches the agent when the upload finishes (`stepFinished`).
    func photosPicked(_ step: SubmitClaimFileUploadStep) {
        guard step === uploadStep, !step.state.isLoading, !step.state.isStepExecuted else { return }
        let count = step.fileUploadVm.fileGridViewModel.files.count
        step.submitResponse()
        Task {
            await sendWhenQuiet(
                """
                [APP] The member just picked \(count) \(count == 1 ? "file" : "files") and it's uploading now. \
                Thank them warmly in a few words, and nothing more: no question, and nothing about waiting or \
                anything coming through. The next step arrives in another [APP] message in a moment.
                """
            )
        }
    }

    /// The upload sheet went away. After a finished step `stepFinished` has already cleared it, so this only
    /// speaks up when the member swiped it away.
    func uploadSheetDismissed() {
        guard let step = uploadStep else { return }
        uploadStep = nil
        guard !step.state.isStepExecuted else { return }
        Task {
            await sendWhenQuiet(
                """
                [APP] The member closed the photo picker without adding anything. Ask whether they want to try again \
                (request_photos) or add files later (skip_step).
                """
            )
        }
    }

    /// The summary sheet went away; see `uploadSheetDismissed`.
    func summarySheetDismissed() {
        guard let step = summaryStep else { return }
        summaryStep = nil
        guard !step.state.isStepExecuted else { return }
        Task {
            await sendWhenQuiet(
                """
                [APP] The member closed the summary without submitting. Ask whether something is wrong. To change \
                an earlier answer, use go_back. Or show the summary again (show_summary).
                """
            )
        }
    }

    private func stepFinished(_ event: SubmitClaimEvent) {
        let result: ClaimIntentType
        switch event {
        case let .goToNext(model): result = .intent(model: model)
        case let .outcome(model): result = .outcome(model: model)
        case .regret, .removeStep: return
        }
        if let upload = uploadStep, upload.state.isStepExecuted {
            toolbox.recordUpload(for: upload.claimIntent, fileIds: upload.submittedFileIds)
        }
        uploadStep = nil
        summaryStep = nil
        Task {
            do {
                let next = try await toolbox.replayingCleared(try await toolbox.adopt(result))
                guard next.status != .done else { return }  // toolboxDidFinish handles the goodbye
                toolbox.delivered(next)
                await sendWhenQuiet(
                    "[APP] The member finished that step. Next: \(VoiceToolResult.step(next).json())"
                )
            } catch {
                await sendWhenQuiet("[APP] That step failed. Call get_current_step and continue.")
            }
        }
    }

    // MARK: - Exit

    private func leave(_ exit: Exit) {
        guard !hasExited else { return }
        hasExited = true
        Task {
            await session.end()
            onExit?(exit)
        }
    }

    private func close() {
        guard !hasExited else { return }
        hasExited = true
        router.dismiss()
    }

    nonisolated static func requestMicrophonePermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
}

extension VoiceClaimViewModel: VoiceClaimToolboxDelegate {
    func toolboxRequestsPhotos(for intent: ClaimIntent) {
        uploadStep = SubmitClaimFileUploadStep(claimIntent: intent, service: service) { [weak self] event in
            self?.stepFinished(event)
        }
    }

    func toolboxRequestsSummary(for intent: ClaimIntent) {
        summaryStep = SubmitClaimSummaryStep(claimIntent: intent, service: service) { [weak self] event in
            self?.stepFinished(event)
        }
    }

    func toolboxWentBack() {
        // Cleared first, so the sheets' own dismissal doesn't tell the agent the member closed them.
        uploadStep = nil
        summaryStep = nil
    }

    func toolboxRequestsHandoff(reason _: String) {
        // The agent says its line before the tool call; let it finish before the line drops.
        Task {
            await waitForAgentToFinish(toStart: .seconds(2))
            leave(.continueDraftInChat)
        }
    }

    func toolboxDidFinish(outcome: ClaimIntentStepOutcome) {
        phase = .finished
        Task {
            await sendWhenQuiet("[APP] The claim is submitted. \(VoiceToolResult.step(.done).json())")
            // Let the agent say its whole goodbye, then hang up and show the existing success screen.
            callLog.info("claim submitted, waiting for the goodbye")
            await waitForAgentToFinish(toStart: .seconds(8), quiet: .milliseconds(800), limit: .seconds(20))
            callLog.info("goodbye done, ending the call")
            await session.end()
            router.push(outcome)
        }
    }
}
