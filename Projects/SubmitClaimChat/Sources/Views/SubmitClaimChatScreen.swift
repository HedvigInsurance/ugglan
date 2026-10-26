import Combine
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore
import hCoreUI

public struct SubmitClaimChatScreen: View {
    @Environment(SubmitClaimChatViewModel.self) var viewModel
    @Environment(ClaimChatScrollCoordinator.self) var scrollCoordinator
    @State var fileUploadVm = FilesUploadViewModel(model: .init())
    @EnvironmentObject var router: NavigationRouter
    @Environment(\.verticalSizeClass) var verticalSizeClass

    public init() {}

    public var body: some View {
        @Bindable var viewModel = viewModel
        scrollContent
            .submitClaimChatScreenAlert(viewModel.alertVm)
            .animation(.defaultSpring, value: viewModel.outcome)
            .onChange(of: verticalSizeClass) { _, value in
                viewModel.currentVerticalSizeClass = value
            }
            .onAppear {
                viewModel.currentVerticalSizeClass = verticalSizeClass
            }
            .onChange(of: viewModel.showError) { [weak viewModel] _, value in
                if value {
                    viewModel?.alertVm.alertModel = .init(
                        type: .error,
                        message: viewModel?.error?.localizedDescription ?? "",
                        action: { [weak viewModel] in
                            viewModel?.startClaimIntent()
                        },
                        // Stored on alertVm, which viewModel owns: must not capture the screen.
                        onClose: { [weak router = router] in
                            Task {
                                await delay(0.1)
                                router?.dismiss()
                            }
                        }
                    )
                }
            }
            .addProgressBar(with: $viewModel.progress)
    }

    private var scrollContent: some View {
        ScrollViewReader { proxy in
            mainContent
                .onChange(of: viewModel.scrollTarget) { _, scrollTarget in
                    withAnimation {
                        proxy.scrollTo(scrollTarget.id, anchor: scrollTarget.anchor)
                    }
                }
        }
    }

    private var mainContent: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { proxy in
                hForm {
                    VStack(alignment: .leading, spacing: 0) {
                        aiDisclaimerView
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(viewModel.allSteps, id: \.id) { step in
                                StepView(step: step)
                            }
                        }
                        .padding(.horizontal, .padding16)
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.shouldShowAIDisclaimer)

                    if verticalSizeClass == .regular && !scrollCoordinator.shouldMergeInputWithContent {
                        Color.clear.frame(
                            height: viewModel.calculatePaddingHeight()
                        )
                    }
                }
                .hFormContentPosition(.top)
                .environment(viewModel)
                .scrollIndicators(.hidden)
                .onAppear {
                    scrollCoordinator.scrollViewHeight = proxy.size.height
                }
                .hFormBottomBackgroundColor(.aiPoweredGradient)
                .onChange(of: proxy.size) { _, value in
                    scrollCoordinator.scrollViewHeight = value.height
                }
                .introspect(.scrollView, on: .iOS(.v13...)) { scrollView in
                    scrollCoordinator.scrollViewBottomInset = scrollView.safeAreaInsets.bottom
                    if scrollView != scrollCoordinator.scrollView {
                        scrollCoordinator.scrollView = scrollView
                    }
                }
                .hFormAttachToBottom {
                    if verticalSizeClass == .compact || scrollCoordinator.shouldMergeInputWithContent {
                        currentStepView
                    }
                }
            }
            .ignoresSafeArea(
                .keyboard,
                edges: scrollCoordinator.shouldMergeInputWithContent || viewModel.outcome != nil ? [] : .all
            )
            if verticalSizeClass == .regular && !scrollCoordinator.shouldMergeInputWithContent {
                currentStepView
            }
            floatingCardView
        }
        .environment(viewModel.alertVm)
    }

    @ViewBuilder
    private var aiDisclaimerView: some View {
        if viewModel.shouldShowAIDisclaimer {
            ClaimChatAIDisclaimerView()
        }
    }

    private var floatingCardView: some View {
        ZStack(alignment: .bottom) {
            if let currentStep = viewModel.currentStep {
                ClaimChatFloatingCardView(step: currentStep)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.defaultSpring, value: viewModel.currentStep?.id)
    }

    private var currentStepView: some View {
        ZStack(alignment: .bottom) {
            if let currentStep = viewModel.currentStep {
                ClaimChatDockedInputView(step: currentStep)
            }
        }
        .padding(.bottom, .padding16)
        .environment(viewModel)
        .background {
            if let currentStep = viewModel.currentStep {
                HiddenWhileFloatingCard(step: currentStep) {
                    ClaimChatInputBlurBackground(isOffScreen: viewModel.shouldHideCurrentInput)
                }
            } else {
                ClaimChatInputBlurBackground(isOffScreen: viewModel.shouldHideCurrentInput)
            }
        }
        .animation(.default, value: viewModel.currentStep?.id)
        .animation(.easeInOut(duration: 0.5), value: scrollCoordinator.isInputScrolledOffScreen)
    }
}

private struct ClaimChatDockedInputView: View {
    @Environment(SubmitClaimChatViewModel.self) var viewModel
    @Environment(ClaimChatScrollCoordinator.self) var scrollCoordinator
    let step: ClaimIntentStepHandler
    @AccessibilityFocusState private var isCurrentStepFocused: Bool

    var body: some View {
        HiddenWhileFloatingCard(step: step) {
            if viewModel.shouldHideCurrentInput {
                ScrollToBottomButton(scrollAction: scrollToBottom)
            }
            if !viewModel.shouldHideCurrentInput {
                ScrollView {
                    CurrentStepView(step: step)
                        .padding(.top, .padding16)
                        .background {
                            GeometryReader { proxy in
                                Color.clear
                                    .onAppear {
                                        viewModel.currentStepInputHeight = proxy.size.height
                                    }
                                    .onChange(of: proxy.size) { _, value in
                                        viewModel.currentStepInputHeight = value.height
                                    }
                            }
                        }
                }
                .frame(maxHeight: viewModel.currentStepInputHeight)
                .scrollBounceBehavior(.basedOnSize)
                .transition(.offset(x: 0, y: 1000))
                .animation(.easeInOut(duration: 0.5), value: viewModel.shouldHideCurrentInput)
                .accessibilityFocused($isCurrentStepFocused)
                .dismissKeyboard()
            }
        }
    }

    private func scrollToBottom() {
        scrollCoordinator.scrollToBottom()
        Task {
            await delay(ClaimChatConstants.Timing.standardAnimation)
            isCurrentStepFocused = true
        }
    }
}

private struct HiddenWhileFloatingCard<Content: View>: View {
    let step: ClaimIntentStepHandler
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack(alignment: .bottom) {
            content()
        }
        .opacity(step.usesFloatingInputCard ? 0 : 1)
        .allowsHitTesting(!step.usesFloatingInputCard)
        .accessibilityHidden(step.usesFloatingInputCard)
        .animation(.defaultSpring, value: step.usesFloatingInputCard)
    }
}

private struct ClaimChatFloatingCardView: View {
    @Environment(SubmitClaimChatViewModel.self) var viewModel
    let step: ClaimIntentStepHandler
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        ZStack(alignment: .bottom) {
            if step.usesFloatingInputCard {
                ClaimInputCardView(viewModel: step, onTextFocus: { viewModel.scrollToStep(step) })
                    .padding(.horizontal, .padding16)
                    .padding(.vertical, verticalSizeClass == .regular ? .padding16 : .padding8)
                    .disabled(!step.state.isEnabled)
                    .geometryGroup()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .claimStepErrorAlert(for: step)
                    .onAppear {
                        viewModel.scrollToStep(step)
                    }
            }
        }
        .environment(viewModel)
        .animation(.defaultSpring, value: step.usesFloatingInputCard)
    }
}

struct ScrollToBottomButton: View {
    let scrollAction: () -> Void

    var body: some View {
        Button {
            scrollAction()
        } label: {
            hCoreUIAssets.arrowDown.view
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(hTextColor.Opaque.primary)
                .padding(.padding8)
                .background(hFillColor.Opaque.negative)
                .clipShape(Circle())
                .contentShape(Circle())
                .hCardShadow()
        }
        .accessibilityLabel(L10n.voiceoverDoubleClickTo + " " + L10n.a11YScrollDown)
        .accessibilityAddTraits(.isButton)
        .onTapGesture {
            scrollAction()
        }
        .accessibilityAddTraits(.isButton)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

private struct ClaimChatInputBlurBackground: View {
    let isOffScreen: Bool

    var body: some View {
        BackgroundBlurView()
            .clipShape(hRoundedRectangle(cornerRadius: .cornerRadiusL, corners: [.topLeft, .topRight]))
            .ignoresSafeArea(.container, edges: .bottom)
            .offset(x: 0, y: isOffScreen ? 1000 : 0)
    }
}

private struct CurrentStepView: View {
    let step: ClaimIntentStepHandler

    var body: some View {
        VStack {
            if step.state.showInput {
                ClaimStepView(viewModel: step)
                    .transition(.offset(x: 0, y: 1000))
                    .claimStepErrorAlert(for: step)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: step.state.showInput)
    }
}

private struct ClaimStepErrorAlertModifier: ViewModifier {
    let step: ClaimIntentStepHandler
    @Environment(SubmitClaimChatScreenAlertViewModel.self) var alertVm
    @EnvironmentObject var router: NavigationRouter

    func body(content: Content) -> some View {
        content
            .onChange(of: step.state.showError) { [weak step, weak router] _, value in
                if value {
                    alertVm.alertModel = .init(
                        type: .error,
                        message: step?.state.error?.localizedDescription ?? "",
                        // Stored on alertVm: neither closure may capture this view.
                        action: {
                            step?.submitResponse()
                        },
                        onClose: {
                            if let claimError = step?.state.error as? ClaimIntentError {
                                switch claimError {
                                case .unknownStep, .unknownField:
                                    Task { [weak router] in
                                        await delay(0.1)
                                        router?.dismiss()
                                    }
                                default:
                                    step?.state.isEnabled = true
                                    step?.state.isLoading = false
                                }
                            } else {
                                step?.state.isEnabled = true
                                step?.state.isLoading = false
                            }
                        }
                    )
                }
            }
    }
}

extension View {
    func claimStepErrorAlert(for step: ClaimIntentStepHandler) -> some View {
        modifier(ClaimStepErrorAlertModifier(step: step))
    }
}

struct StepView: View {
    @Environment(SubmitClaimChatViewModel.self) var viewModel
    let step: ClaimIntentStepHandler
    @AccessibilityFocusState var isAccessibilityFocused: String?

    var body: some View {
        SubmitClaimChatMessageView(viewModel: step)
            .padding(.top, .padding16)
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            viewModel.stepHeights[step.id] = proxy.size.height
                        }
                        .onChange(of: proxy.size) { _, value in
                            viewModel.stepHeights[step.id] = value.height
                        }
                }
            }
            .onChange(of: step.state.isLoaderAnimating) {
                if let indexOfCurrentStep = viewModel.allSteps.firstIndex(where: { $0.id == step.id }),
                    indexOfCurrentStep > 0
                {
                    viewModel.allSteps[indexOfCurrentStep - 1].state.isLoaderAnimating = false
                }
            }
            .id(step.id)
            .transition(
                .asymmetric(
                    insertion: step.state.animateText
                        ? .offset(x: 0, y: 100).combined(with: .opacity).animation(.default)
                        : .opacity.animation(.easeInOut(duration: 0)),
                    removal: .opacity.animation(.easeInOut(duration: 0.1))
                )

            )
            .accessibilityFocused($isAccessibilityFocused, equals: step.id)
            .onChange(of: viewModel.currentStepId) { _, id in
                isAccessibilityFocused = id
            }
    }
}

extension SubmitClaimChatScreen: TrackingViewNameProtocol {
    public var nameForTracking: String {
        .init(describing: self)
    }
}

#Preview {
    let demoService = ClaimIntentClientDemo()
    Dependencies.shared.add(module: Module { () -> ClaimIntentClient in demoService })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    let viewModel = SubmitClaimChatViewModel(
        startInput: .init(
            input: .init(type: .regular(hasInProgress: true)),
            openChat: {
            }
        )
    )
    return SubmitClaimChatScreen()
        .embededInNavigation(tracking: "")
        .environment(viewModel)
        .environment(viewModel.scrollCoordinator)
}

// MARK: - Main Model
@MainActor
@Observable
final class SubmitClaimChatViewModel {
    var error: Error? {
        didSet {
            showError = error != nil
        }
    }
    var showError = false
    // MARK: - Published UI State
    var allSteps: [ClaimIntentStepHandler] = [] {
        didSet {
            scrollCoordinator.isInputScrolledOffScreen = false
            recalculateStepHeights()
        }
    }
    var currentStep: ClaimIntentStepHandler?
    var currentStepId: String?
    var scrollTarget: ScrollTarget = .init(id: "", anchor: .bottom)
    let alertVm = SubmitClaimChatScreenAlertViewModel()
    let scrollCoordinator = ClaimChatScrollCoordinator()
    @ObservationIgnored private var previousTitle: String?
    var title: String {
        if let newTitle = currentStep?.claimIntent.displayName {
            previousTitle = newTitle
            return newTitle
        } else {
            return previousTitle ?? L10n.claimChatTitle
        }
    }
    @ObservationIgnored var stepHeights: [String: CGFloat] = [:] {
        didSet {
            recalculateStepHeights()
        }
    }

    func calculatePaddingHeight() -> CGFloat {
        let height =
            scrollCoordinator.scrollViewHeight - scrollCoordinator.scrollViewBottomInset + scrollCoordinator.topPadding
            - lastStepContentHeight
        return max(
            height,
            currentStepInputHeight + scrollCoordinator.topPadding
        )
    }

    @ObservationIgnored var totalStepsHeight: CGFloat = 0
    var lastStepContentHeight: CGFloat = 0
    var currentStepInputHeight: CGFloat = 0 {
        didSet {
            if currentStepInputHeight != oldValue {
                scrollCoordinator.checkForScrollOffset()
            }
        }
    }

    var outcome: ClaimIntentStepOutcome?
    var progress: Float?
    @ObservationIgnored var currentVerticalSizeClass: UserInterfaceSizeClass?

    var shouldShowAIDisclaimer: Bool {
        allSteps.count < 2
    }

    /// Determines if the current input should be hidden based on scroll position, size class, and merge state
    var shouldHideCurrentInput: Bool {
        scrollCoordinator.isInputScrolledOffScreen && currentVerticalSizeClass == .regular
            && !scrollCoordinator.shouldMergeInputWithContent
    }
    // MARK: - Dependencies
    private let flowManager: ClaimIntentFlowManager
    let openChat: () -> Void
    let router = NavigationRouter()
    private let input: StartClaimInput
    // MARK: - Initialization
    init(
        startInput: SubmitClaimChatInput
    ) {
        self.flowManager = ClaimIntentFlowManager(service: ClaimIntentService())
        self.openChat = startInput.openChat
        self.input = startInput.input

        // Configure scroll coordinator with dependencies
        scrollCoordinator.configure(
            totalStepsHeight: { [weak self] in
                self?.totalStepsHeight ?? 0
            },
            currentStepInputHeight: { [weak self] in
                if self?.allSteps.count ?? 0 <= 1 {
                    return 0
                }
                return self?.currentStepInputHeight ?? 0
            }
        )

        startClaimIntent()
    }

    // MARK: - UI Height Calculations
    private func recalculateStepHeights() {
        Task {
            await delay(ClaimChatConstants.Timing.layoutUpdate)
            scrollCoordinator.checkForScrollOffset()
        }
        // stepHeights can hold entries for steps no longer in allSteps, so sum over allSteps instead
        totalStepsHeight = allSteps.reduce(0) { $0 + (stepHeights[$1.id] ?? 0) }

        if let id = allSteps.last?.id {
            lastStepContentHeight = stepHeights[id] ?? 0
        }
    }

    // MARK: - Business Logic
    func startClaimIntent() {
        self.error = nil
        Task {
            do {
                guard let claimIntent = try await flowManager.startClaimIntent(input: input) else {
                    throw ClaimIntentError.invalidResponse
                }
                switch claimIntent {
                case let .intent(model):
                    processClaimIntent(.goToNext(claimIntent: model))
                case let .outcome(model):
                    processClaimIntent(.outcome(model: model))
                }
            } catch {
                await delay(ClaimChatConstants.Timing.shortDelay)
                self.error = error
            }
        }
    }

    private func processClaimIntent(_ claimEvent: SubmitClaimEvent) {
        switch claimEvent {
        case let .removeStep(id):
            withAnimation {
                self.removeSteps(where: { $0.id == id })
                self.stepHeights[id] = nil
            }
        case let .goToNext(claimIntent):
            handleGoToNextStep(claimIntent: claimIntent)
        case let .regret(currentClaimIntent, newClaimIntent):
            handleRegretStep(currentClaimIntent: currentClaimIntent, newClaimIntent: newClaimIntent)
        case let .outcome(model):
            router.push(model)
            withAnimation {
                self.removeSteps(where: { _ in true })
                self.currentStep = nil
                self.progress = nil
            }
        }
    }

    private func removeSteps(where shouldRemove: (ClaimIntentStepHandler) -> Bool) {
        for step in allSteps where shouldRemove(step) {
            step.cancelOngoingWork()
        }
        allSteps.removeAll(where: shouldRemove)
    }

    private func handleGoToNextStep(claimIntent: ClaimIntent) {
        let history = claimIntent.previousSteps
        if !history.isEmpty {
            for item in history {
                let handler = createStepHandler(for: item)
                if handler is SubmitClaimTaskStep { continue }
                allSteps.append(handler)
                handler.state.isLoaderAnimating = false
                handler.state.showInput = false
                handler.state.showResults = true
                handler.state.isStepExecuted = true
                handler.state.animateText = false
                if let audioStep = handler as? SubmitClaimAudioStep {
                    audioStep.state.isSkipped = audioStep.audioFileURL == nil && audioStep.textInput == ""
                }
            }
        }
        let handler = createStepHandler(for: claimIntent)
        if let currentStep = currentStep {
            if currentStep is SubmitClaimTaskStep && !(handler is SubmitClaimTaskStep) {
                handler.state.showLoadingAnimation = false
            }
        }

        stepHeights[handler.id] = 0
        let previousStepId = allSteps.filter({ !($0 is SubmitClaimTaskStep) }).last?.id ?? ""

        switch claimIntent.currentStep.content {
        case .deflect, .deflectMessage:
            self.progress = nil
        default:
            self.progress = claimIntent.progress
        }
        Task { @MainActor in
            if let currentStep = currentStep {
                if currentStep is SubmitClaimTaskStep && handler is SubmitClaimTaskStep {
                    removeSteps { step in
                        step.id == currentStep.id
                    }
                }
            }
            if !self.allSteps.isEmpty {
                currentStep = nil
            }
            self.allSteps.append(handler)
            await delay(ClaimChatConstants.Timing.standardAnimation)
            currentStep = handler
            scrollTarget = .init(id: topScrollTargetId(fallback: "result_\(previousStepId)"), anchor: .top)
            currentStepId = handler.id
        }
    }

    private func handleRegretStep(currentClaimIntent: ClaimIntent, newClaimIntent: ClaimIntent) {
        let handler = createStepHandler(for: newClaimIntent)
        self.progress = newClaimIntent.progress
        Task { @MainActor in
            if let indexToRemove = allSteps.firstIndex(where: { $0.id == currentClaimIntent.currentStep.id }) {
                if indexToRemove > 0 {
                    let stepIdToScrollTo = allSteps[indexToRemove - 1].id
                    scrollTarget = .init(id: "result_\(stepIdToScrollTo)", anchor: .top)
                    await delay(ClaimChatConstants.Timing.regretScrollDelay)
                }
                for item in allSteps[indexToRemove..<allSteps.count] {
                    stepHeights.removeValue(forKey: item.id)
                    item.cancelOngoingWork()
                }
                allSteps.removeSubrange((indexToRemove)..<allSteps.count)
            }
            handler.state.animateText = false
            handler.state.isLoaderAnimating = false
            if let lastStep = allSteps.last, lastStep is SubmitClaimTaskStep {
                handler.state.showLoadingAnimation = false
            }
            stepHeights[handler.id] = 0
            allSteps.append(handler)
            currentStep = handler
            await delay(ClaimChatConstants.Timing.minimalDelay)
            if allSteps.count == 1 {
                scrollTarget = .init(id: topScrollTargetId(fallback: handler.id), anchor: .top)
            }
            currentStepId = handler.id
        }
    }

    /// Scrolling to the top of the conversation means the AI disclaimer whenever it is
    /// visible, so it does not end up hidden above the scroll position when it appears.
    private func topScrollTargetId(fallback: String) -> String {
        shouldShowAIDisclaimer ? ClaimChatConstants.aiDisclaimerViewId : fallback
    }

    func scrollToStep(_ step: ClaimIntentStepHandler) {
        guard let index = allSteps.firstIndex(where: { $0.id == step.id }) else { return }
        let anchorStep = index > 0 && allSteps[index - 1] is SubmitClaimTaskStep ? allSteps[index - 1] : step
        scrollTarget = .init(id: anchorStep.id, anchor: .top)
    }

    private func createStepHandler(for claimIntent: ClaimIntent) -> ClaimIntentStepHandler {
        flowManager.createStepHandler(
            for: claimIntent,
            alertVm: alertVm,
            mainHandler: { [weak self] claimEvent in
                self?.processClaimIntent(claimEvent)
            }
        )
    }

    struct ScrollTarget: Equatable {
        let id: String
        let anchor: UnitPoint
        private let requestId = UUID()

        init(id: String, anchor: UnitPoint) {
            self.id = id
            self.anchor = anchor
        }
    }
}
