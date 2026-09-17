import Combine
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore
import hCoreUI

public struct SubmitClaimChatScreen: View {
    @EnvironmentObject var viewModel: SubmitClaimChatViewModel
    @EnvironmentObject var scrollCoordinator: ClaimChatScrollCoordinator
    @StateObject var fileUploadVm = FilesUploadViewModel(model: .init())
    @EnvironmentObject var router: NavigationRouter
    @Environment(\.verticalSizeClass) var verticalSizeClass

    public init() {}

    public var body: some View {
        scrollContent
            .submitClaimChatScreenAlert(viewModel.alertVm)
            .animation(.defaultSpring, value: viewModel.outcome)
            .onChange(of: verticalSizeClass) { value in
                viewModel.currentVerticalSizeClass = value
            }
            .onAppear {
                viewModel.currentVerticalSizeClass = verticalSizeClass
            }
            .onChange(of: viewModel.showError) { [weak viewModel] value in
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
                .onChange(of: viewModel.scrollTarget) { scrollTarget in
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
                        ForEach(viewModel.allSteps, id: \.id) { step in
                            StepView(step: step)
                        }
                    }
                    .padding(.horizontal, .padding16)
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                    if verticalSizeClass == .regular && !scrollCoordinator.shouldMergeInputWithContent {
                        Color.clear.frame(
                            height: viewModel.calculatePaddingHeight()
                        )
                    }
                }
                .hFormContentPosition(.top)
                .environmentObject(viewModel)
                .hideScrollIndicators()
                .onAppear {
                    scrollCoordinator.scrollViewHeight = proxy.size.height
                }
                .hFormBottomBackgroundColor(.aiPoweredGradient)
                .onChange(of: proxy.size) { value in
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
        .environmentObject(viewModel.alertVm)
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
        .environmentObject(viewModel)
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
    @EnvironmentObject var viewModel: SubmitClaimChatViewModel
    @EnvironmentObject var scrollCoordinator: ClaimChatScrollCoordinator
    @ObservedObject var step: ClaimIntentStepHandler
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
                                    .onChange(of: proxy.size) { value in
                                        viewModel.currentStepInputHeight = value.height
                                    }
                            }
                        }
                }
                .frame(maxHeight: viewModel.currentStepInputHeight)
                .addScrollBounce()
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
    @ObservedObject var step: ClaimIntentStepHandler
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
    @EnvironmentObject var viewModel: SubmitClaimChatViewModel
    @ObservedObject var step: ClaimIntentStepHandler
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        ZStack(alignment: .bottom) {
            if step.usesFloatingInputCard {
                ClaimInputCardView(viewModel: step, onTextFocus: { viewModel.scrollToStep(step) })
                    .padding(.horizontal, .padding16)
                    .padding(.vertical, verticalSizeClass == .regular ? .padding16 : .padding8)
                    .disabled(!step.state.isEnabled)
                    .geometryGroupIfAvailable()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .claimStepErrorAlert(for: step)
                    .onAppear {
                        viewModel.scrollToStep(step)
                    }
            }
        }
        .environmentObject(viewModel)
        .animation(.defaultSpring, value: step.usesFloatingInputCard)
    }
}

extension View {
    @ViewBuilder
    func addScrollBounce() -> some View {
        if #available(iOS 16.4, *) {
            self.scrollBounceBehavior(.basedOnSize)
        } else {
            self
        }
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
                .hShadow(type: .custom(opacity: 0.05, radius: 5, xOffset: 0, yOffset: 4), show: true)
                .hShadow(type: .custom(opacity: 0.1, radius: 1, xOffset: 0, yOffset: 2), show: true)
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
    @ObservedObject var step: ClaimIntentStepHandler

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
    @ObservedObject var step: ClaimIntentStepHandler
    @EnvironmentObject var alertVm: SubmitClaimChatScreenAlertViewModel
    @EnvironmentObject var router: NavigationRouter

    func body(content: Content) -> some View {
        content
            .onChange(of: step.state.showError) { value in
                if value {
                    alertVm.alertModel = .init(
                        type: .error,
                        message: step.state.error?.localizedDescription ?? "",
                        // Stored on alertVm: neither closure may capture this view.
                        action: { [weak step] in
                            step?.submitResponse()
                        },
                        onClose: { [weak step, weak router] in
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
    @EnvironmentObject var viewModel: SubmitClaimChatViewModel
    @ObservedObject var step: ClaimIntentStepHandler
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
                        .onChange(of: proxy.size) { value in
                            viewModel.stepHeights[step.id] = value.height
                        }
                }
            }
            .onChange(of: step.state.isLoaderAnimating) { isLoading in
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
            .onChange(of: viewModel.currentStepId) { id in
                isAccessibilityFocused = id
            }
    }
}

extension SubmitClaimChatScreen: TrackingViewNameProtocol {
    public var nameForTracking: String {
        .init(describing: self)
    }
}

extension View {
    @ViewBuilder
    fileprivate func hideScrollIndicators() -> some View {
        if #available(iOS 16.0, *) {
            self.scrollIndicators(.hidden)
        } else {
            self
        }
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
        .environmentObject(viewModel)
        .environmentObject(viewModel.scrollCoordinator)
}

// MARK: - Main Model
@MainActor
final class SubmitClaimChatViewModel: ObservableObject {
    @Published var error: Error? {
        didSet {
            showError = error != nil
        }
    }
    @Published var showError = false
    // MARK: - Published UI State
    @Published var allSteps: [ClaimIntentStepHandler] = [] {
        didSet {
            scrollCoordinator.isInputScrolledOffScreen = false
        }
    }
    @Published var currentStep: ClaimIntentStepHandler?
    @Published var currentStepId: String?
    @Published var scrollTarget: ScrollTarget = .init(id: "", anchor: .bottom)
    let alertVm = SubmitClaimChatScreenAlertViewModel()
    let scrollCoordinator = ClaimChatScrollCoordinator()
    private var previousTitle: String?
    var title: String {
        if let newTitle = currentStep?.claimIntent.displayName {
            previousTitle = newTitle
            return newTitle
        } else {
            return previousTitle ?? L10n.claimChatTitle
        }
    }
    var stepHeights: [String: CGFloat] = [:] {
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

    var totalStepsHeight: CGFloat = 0
    @Published var lastStepContentHeight: CGFloat = 0
    @Published var currentStepInputHeight: CGFloat = 0 {
        didSet {
            if currentStepInputHeight != oldValue {
                scrollCoordinator.checkForScrollOffset()
            }
        }
    }

    @Published var outcome: ClaimIntentStepOutcome?
    @Published var progress: Float?
    var currentVerticalSizeClass: UserInterfaceSizeClass?

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
        totalStepsHeight = stepHeights.values.reduce(0, +)
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
                self.allSteps.removeAll(where: { $0.id == id })
                self.stepHeights[id] = nil
            }
        case let .goToNext(claimIntent):
            handleGoToNextStep(claimIntent: claimIntent)
        case let .regret(currentClaimIntent, newClaimIntent):
            handleRegretStep(currentClaimIntent: currentClaimIntent, newClaimIntent: newClaimIntent)
        case let .outcome(model):
            router.push(model)
            withAnimation {
                self.allSteps.removeAll()
                self.currentStep = nil
                self.progress = nil
            }
        }
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
                    allSteps.removeAll { step in
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
            scrollTarget = .init(id: "result_\(previousStepId)", anchor: .top)
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
            if allSteps.count == 1 {
                scrollTarget = .init(id: handler.id, anchor: .top)
            }
            await delay(ClaimChatConstants.Timing.minimalDelay)
            currentStepId = handler.id
        }
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
