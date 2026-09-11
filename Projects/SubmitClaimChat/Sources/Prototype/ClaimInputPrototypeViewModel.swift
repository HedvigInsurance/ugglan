import Combine
import SwiftUI
import hCore
import hCoreUI

// MARK: - Prototype of the updated claim description step
//
// Figma: Claude Code App → page "Claim input chat" (449:49211).
// Skriv · Spela in side by side + Hoppa över, then a card overlay for text or voice.
// Lorem ipsum content, no backend. Mirrors how `SubmitClaimChatScreen` is built
// (hForm, ClaimChatScrollCoordinator, docked input with BackgroundBlurView, reveal text, result pills).

@MainActor
final class ClaimInputPrototypeStep: ObservableObject, Identifiable {
    enum Kind {
        /// Single-select pills + Bekräfta (like today's chat).
        case select
        /// The redesigned description step: Skriv · Spela in · Hoppa över.
        case description
        /// Closing message, no input.
        case closing
    }

    enum Answer: Equatable {
        case pill(String)
        case text(String)
        case voice([CGFloat])
        case skipped
    }

    let id: String
    let scriptIndex: Int
    let kind: Kind
    let text: String
    let options: [String]

    @Published var answer: Answer?
    @Published var selectedOption: String?
    @Published var isLoaderAnimating: Bool
    @Published var animateText: Bool
    @Published var showLoadingAnimation = true

    var isRegrettable: Bool { kind != .closing }

    init(
        template: ClaimInputPrototypeCopy.StepTemplate,
        scriptIndex: Int,
        answer: Answer? = nil,
        animateText: Bool
    ) {
        self.id = UUID().uuidString
        self.scriptIndex = scriptIndex
        self.kind = template.kind
        self.text = template.text
        self.options = template.options
        self.answer = answer
        self.selectedOption = {
            if case let .pill(value) = answer { return value }
            return nil
        }()
        self.animateText = animateText
        self.isLoaderAnimating = animateText
    }
}

@MainActor
final class ClaimInputPrototypeViewModel: ObservableObject {
    enum InputMode: Equatable {
        /// Hedvig is still "typing" or the step is done – nothing docked.
        case hidden
        /// 1.x – Skriv · Spela in · Hoppa över docked on frosted glass.
        case choose
        /// 2.x – text card above the keyboard.
        case text
        /// 3.x – voice card, behaves like today's recorder.
        case voice
        /// Single-select pills + Bekräfta, like today's chat.
        case select
    }

    struct ScrollTarget: Equatable {
        let id: String
        let anchor: UnitPoint
    }

    /// Debug entry state – lets the example app open straight into one of the Figma states.
    enum StartState: String {
        case resting
        case text
        case voice
        case savedText
        case savedVoice
        /// Plays the interactive path automatically: reveal → Skriv → type → Spara.
        case autoplayText
        /// Resting, then scrolls to the top of the chat (Figma 1.3 – arrow above the docked input).
        case autoplayScroll
        /// Voice card in its sending state (Figma 3.6), never completes.
        case sendingVoice
    }

    // MARK: Published UI state
    @Published var steps: [ClaimInputPrototypeStep] = [] {
        didSet { scrollCoordinator.isInputScrolledOffScreen = false }
    }
    @Published var inputMode: InputMode = .hidden
    @Published var draftText = ""
    @Published var isSaving = false
    @Published var progress: Float? = 0
    @Published var scrollTarget: ScrollTarget = .init(id: "", anchor: .bottom)
    @Published var lastStepContentHeight: CGFloat = 0
    @Published var currentStepInputHeight: CGFloat = 0 {
        didSet {
            if currentStepInputHeight != oldValue {
                scrollCoordinator.checkForScrollOffset()
            }
        }
    }

    let scrollCoordinator = ClaimChatScrollCoordinator()
    let voiceRecorder = VoiceRecorder()
    var currentVerticalSizeClass: UserInterfaceSizeClass?
    var totalStepsHeight: CGFloat = 0
    var stepHeights: [String: CGFloat] = [:] {
        didSet { recalculateStepHeights() }
    }

    private let startState: StartState
    private var pendingTask: Task<Void, Never>?
    /// The chat's UIScrollView, kept so the coordinator can be re-attached after the text card closes.
    weak var scrollView: UIScrollView?

    /// The step currently waiting for an answer.
    var currentStep: ClaimInputPrototypeStep? {
        steps.last(where: { $0.answer == nil && $0.kind != .closing })
    }

    /// Same rule as `SubmitClaimChatViewModel.shouldHideCurrentInput`, but the prototype keeps the
    /// input docked and shows the "jump back to the question" arrow above it instead (Figma 1.3).
    var isQuestionScrolledAway: Bool {
        scrollCoordinator.isInputScrolledOffScreen && currentVerticalSizeClass == .regular
            && !scrollCoordinator.shouldMergeInputWithContent
    }

    init(startState: StartState = .resting) {
        self.startState = startState
        scrollCoordinator.configure(
            totalStepsHeight: { [weak self] in self?.totalStepsHeight ?? 0 },
            currentStepInputHeight: { [weak self] in
                if self?.steps.count ?? 0 <= 1 { return 0 }
                return self?.currentStepInputHeight ?? 0
            }
        )
        start()
    }

    // MARK: Height bookkeeping (copied from SubmitClaimChatViewModel)
    func calculatePaddingHeight() -> CGFloat {
        let height =
            scrollCoordinator.scrollViewHeight - scrollCoordinator.scrollViewBottomInset + scrollCoordinator.topPadding
            - lastStepContentHeight
        return max(height, currentStepInputHeight + scrollCoordinator.topPadding)
    }

    private func recalculateStepHeights() {
        Task {
            try? await Task.sleep(seconds: ClaimChatConstants.Timing.layoutUpdate)
            scrollCoordinator.checkForScrollOffset()
        }
        totalStepsHeight = stepHeights.values.reduce(0, +)
        if let id = steps.last?.id {
            lastStepContentHeight = stepHeights[id] ?? 0
        }
    }

    // MARK: Flow
    func start() {
        // Two already answered steps, then the description step is "typed" by Hedvig.
        steps = Copy.script.prefix(Copy.descriptionIndex).enumerated()
            .map { index, template in
                ClaimInputPrototypeStep(
                    template: template,
                    scriptIndex: index,
                    answer: template.presetAnswer,
                    animateText: false
                )
            }
        progress = Copy.progress(forStep: Copy.descriptionIndex)

        switch startState {
        case .resting:
            appendAfterDelay(scriptIndex: Copy.descriptionIndex)
        case .autoplayText:
            pendingTask = Task {
                try? await Task.sleep(seconds: ClaimChatConstants.Timing.standardAnimation)
                append(scriptIndex: Copy.descriptionIndex, animated: true)
                try? await Task.sleep(seconds: 6)
                beginText()
                try? await Task.sleep(seconds: 1.5)
                // "Type" the answer character by character so recordings read naturally.
                for character in Copy.sampleAnswer {
                    guard !Task.isCancelled else { return }
                    draftText.append(character)
                    try? await Task.sleep(seconds: 0.05)
                }
                try? await Task.sleep(seconds: 1.2)
                saveText()
            }
        case .autoplayScroll:
            // Deep into the chat: description + two follow-ups answered, third follow-up waiting.
            jump(to: .savedText)
            for _ in 0..<2 {
                guard let step = currentStep else { break }
                step.answer = .text(Copy.sampleAnswer)
                advance(after: step, animated: false)
            }
            pendingTask = Task {
                try? await Task.sleep(seconds: 2.5)
                scrollCoordinator.scrollView?.setContentOffset(.zero, animated: true)
            }
        default:
            jump(to: startState)
        }
    }

    func reset() {
        pendingTask?.cancel()
        reattachScrollCoordinator()
        UIApplication.dismissKeyboard()
        voiceRecorder.startOver()
        withAnimation {
            inputMode = .hidden
            steps.removeAll()
        }
        stepHeights = [:]
        draftText = ""
        isSaving = false
        start()
    }

    /// Debug shortcut: skip the reveal animation and land in a given state.
    private func jump(to state: StartState) {
        let previousStepId = steps.last?.id ?? ""
        guard let description = append(scriptIndex: Copy.descriptionIndex, animated: false) else { return }
        var modeAfterScroll: InputMode = .choose
        switch state {
        case .resting, .autoplayText, .autoplayScroll:
            inputMode = .choose
        case .text:
            draftText = Copy.sampleAnswer
            inputMode = .choose
            modeAfterScroll = .text
        case .voice, .sendingVoice:
            inputMode = .choose
            modeAfterScroll = .voice
        case .savedText:
            description.answer = .text(Copy.sampleAnswer)
            advance(after: description, animated: false)
        case .savedVoice:
            description.answer = .voice(Copy.fakeWaveform)
            advance(after: description, animated: false)
        }
        // The view isn't on screen yet, so re-issue the scroll once it is (same as after a reveal).
        // The scroll coordinator dismisses the keyboard on every scroll, so the cards open after it.
        scrollTarget = .init(id: "", anchor: .bottom)
        Task {
            try? await Task.sleep(seconds: ClaimChatConstants.Timing.shortDelay)
            scrollTarget = .init(id: previousStepId, anchor: .top)
            if modeAfterScroll != .choose {
                try? await Task.sleep(seconds: ClaimChatConstants.Timing.shortDelay)
                if modeAfterScroll == .voice { voiceRecorder.startOver() }
                withAnimation { inputMode = modeAfterScroll }
                if state == .sendingVoice {
                    try? await Task.sleep(seconds: ClaimChatConstants.Timing.shortDelay)
                    voiceRecorder.isSending = true
                }
            }
        }
    }

    /// Called when the reveal animation of a Hedvig message is done (mirrors `state.showInput = true`).
    func revealFinished(for step: ClaimInputPrototypeStep) {
        guard step.answer == nil, inputMode == .hidden, step.id == currentStep?.id else { return }
        switch step.kind {
        case .description:
            withAnimation(.easeInOut(duration: 0.5)) { inputMode = .choose }
        case .select:
            withAnimation(.easeInOut(duration: 0.5)) { inputMode = .select }
        case .closing:
            break
        }
    }

    func beginText() {
        // The shipping coordinator dismisses the keyboard on every scroll-offset change (its text step
        // never shows the keyboard on this screen). Detach it while the card is open so the keyboard stays up.
        scrollCoordinator.scrollView = nil
        // Figma 2.3: the question scrolls up so it stays visible above the card + keyboard.
        if let step = currentStep {
            scrollTarget = .init(id: step.id, anchor: .top)
        }
        pendingTask = Task {
            try? await Task.sleep(seconds: Copy.scrollBeforeCardDelay)
            guard !Task.isCancelled else { return }
            withAnimation { inputMode = .text }
        }
    }

    func beginVoice() {
        voiceRecorder.startOver()
        withAnimation { inputMode = .voice }
    }

    /// Re-attaches the scroll coordinator after the text card has closed.
    func reattachScrollCoordinator() {
        guard scrollCoordinator.scrollView == nil, let scrollView else { return }
        scrollCoordinator.scrollView = scrollView
    }

    func cancelInput() {
        reattachScrollCoordinator()
        UIApplication.dismissKeyboard()
        voiceRecorder.stopRecording()
        voiceRecorder.stopPlayback()
        withAnimation { inputMode = .choose }
    }

    func saveText() {
        let text = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isSaving else { return }
        reattachScrollCoordinator()
        UIApplication.dismissKeyboard()
        isSaving = true
        pendingTask = Task {
            try? await Task.sleep(seconds: Copy.fakeNetworkDelay)
            guard !Task.isCancelled else { return }
            isSaving = false
            complete(with: .text(text))
        }
    }

    /// Hooked into `VoiceSendButton.onTap` – a fake upload.
    func sendVoice() async throws {
        try await Task.sleep(seconds: Copy.fakeNetworkDelay)
        var levels = voiceRecorder.audioLevels
        if (levels.max() ?? 0) < 0.05 {
            levels = Copy.fakeWaveform
        }
        voiceRecorder.isSending = false
        voiceRecorder.stopPlayback()
        complete(with: .voice(levels))
    }

    func skip() {
        complete(with: .skipped)
    }

    /// Select steps: confirm the selected pill (mirrors SubmitClaimSingleSelectView → submitResponse).
    func confirmSelection() {
        guard let step = currentStep, step.kind == .select, let selected = step.selectedOption else { return }
        complete(with: .pill(selected))
    }

    /// Ändra: drop everything after the step and ask it again (mirrors regret).
    func regret(_ step: ClaimInputPrototypeStep) {
        guard let index = steps.firstIndex(where: { $0.id == step.id }), step.isRegrettable else { return }
        pendingTask?.cancel()
        isSaving = false
        reattachScrollCoordinator()
        UIApplication.dismissKeyboard()
        voiceRecorder.startOver()
        draftText = {
            if case let .text(text) = step.answer { return text }
            return ""
        }()
        withAnimation {
            for removed in steps[(index + 1)...] {
                stepHeights[removed.id] = nil
            }
            steps.removeSubrange((index + 1)...)
            step.answer = nil
            step.selectedOption = nil
            inputMode = step.kind == .description ? .choose : .select
        }
        progress = Copy.progress(forStep: step.scriptIndex)
        scrollTarget = .init(id: step.id, anchor: .top)
    }

    private func complete(with answer: ClaimInputPrototypeStep.Answer) {
        guard let step = currentStep else { return }
        withAnimation {
            step.answer = answer
            inputMode = .hidden
        }
        progress = Copy.progress(forStep: step.scriptIndex + 1)
        appendAfterDelay(scriptIndex: step.scriptIndex + 1)
    }

    private func appendAfterDelay(scriptIndex: Int) {
        pendingTask = Task {
            try? await Task.sleep(seconds: ClaimChatConstants.Timing.standardAnimation)
            guard !Task.isCancelled else { return }
            append(scriptIndex: scriptIndex, animated: true)
        }
    }

    /// Appends the next scripted step (used by the debug jumps).
    private func advance(after step: ClaimInputPrototypeStep, animated: Bool) {
        let next = append(scriptIndex: step.scriptIndex + 1, animated: animated)
        if !animated, let next, next.kind == .select {
            inputMode = .select
        }
    }

    @discardableResult
    private func append(scriptIndex: Int, animated: Bool) -> ClaimInputPrototypeStep? {
        guard scriptIndex < Copy.script.count else { return nil }
        let step = ClaimInputPrototypeStep(
            template: Copy.script[scriptIndex],
            scriptIndex: scriptIndex,
            animateText: animated
        )
        stepHeights[step.id] = 0
        let previousStepId = steps.last?.id ?? ""
        steps.append(step)
        // The shipping chat anchors to the previous step's answer ("result_…"). The prototype anchors to the
        // previous step itself so the question, the member's answer and the new question all stay visible.
        scrollTarget = .init(id: previousStepId, anchor: .top)
        return step
    }
}

// MARK: - Copy (UI chrome in Swedish per the Figma copy table, messages as lorem ipsum)
enum ClaimInputPrototypeCopy {
    struct StepTemplate {
        let kind: ClaimInputPrototypeStep.Kind
        let text: String
        var options: [String] = []
        /// Pre-filled answer for the steps that are already done when the prototype starts.
        var presetAnswer: ClaimInputPrototypeStep.Answer? = nil
    }

    // Reused Lokalise keys: CHAT_UPLOAD_PRESEND (Skicka), general_cancel_button (Avbryt),
    // CHAT_INPUT_PLACEHOLDER (Skriv här...), GENERAL.EDIT (Ändra), CLAIM_CHAT_SKIP_STEP (Hoppa över).
    // The strings below have no key yet – new Lokalise keys needed if the design ships.
    static let navigationTitle = "Claim"
    static let write = "Skriv"
    static let record = "Spela in"
    static let textFieldLabel = "Beskriv vad som hänt"
    static let voiceTitle = "Berätta vad som hänt"
    static let sending = "Skickar…"
    static let sampleAnswer = "Lorem ipsum dolor sit amet, consectetur adipiscing elit"

    /// The whole chat, in order. Every question uses the new Skriv · Spela in · Hoppa över input.
    /// Index `descriptionIndex` is the step Hedvig is "typing" when the prototype starts.
    static let script: [StepTemplate] = [
        .init(
            kind: .description,
            text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit?",
            presetAnswer: .text("Consectetur adipiscing elit, sed do eiusmod tempor")
        ),
        .init(
            kind: .description,
            text: "Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua?",
            presetAnswer: .voice(fakeWaveform)
        ),
        .init(
            kind: .description,
            text: """
                Lorem ipsum dolor sit amet, consectetur adipiscing elit sed do eiusmod.

                Tempor incididunt ut labore:
                - Lorem ipsum?
                - Dolor sit amet?
                - Consectetur adipiscing?
                """
        ),
        .init(
            kind: .description,
            text: "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip?"
        ),
        .init(
            kind: .description,
            text:
                "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur?"
        ),
        .init(
            kind: .description,
            text: """
                Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt.

                Mollit anim id est laborum:
                - Sed ut perspiciatis?
                - Unde omnis iste natus?
                """
        ),
        .init(
            kind: .closing,
            text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt."
        ),
    ]

    static let descriptionIndex = 2

    static func progress(forStep index: Int) -> Float {
        Float(index) / Float(script.count - 1)
    }

    static let fakeNetworkDelay: Float = 1.2
    /// Scroll animation (~0.35 s) + the coordinator's 200 ms offset throttle, so the keyboard isn't dismissed.
    static let scrollBeforeCardDelay: Float = 0.6

    static let fakeWaveform: [CGFloat] = (0..<60)
        .map { index in
            let wave = (sin(Double(index) / 4) + 1) / 2
            return CGFloat(0.15 + wave * 0.75)
        }
}

private typealias Copy = ClaimInputPrototypeCopy
