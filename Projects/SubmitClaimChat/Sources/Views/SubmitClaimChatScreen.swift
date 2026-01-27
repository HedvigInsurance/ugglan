import Combine
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore
import hCoreUI

public struct SubmitClaimChatScreen: View {
    @EnvironmentObject var viewModel: SubmitClaimChatViewModel
    @EnvironmentObject var scrollCoordinator: ClaimChatScrollCoordinator
    @StateObject var fileUploadVm = FilesUploadViewModel(model: .init())
    @EnvironmentObject var router: Router
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @AccessibilityFocusState private var isCurrentStepFocused: Bool

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
                        onClose: {
                            Task { [weak router] in
                                try? await Task.sleep(seconds: 0.1)
                                router?.dismiss()
                            }
                        }
                    )
                }
            }
            .navigationBarProgress($viewModel.progress)
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
                .hFormBottomBackgroundColor(.aiPoweredGradient)
                .environmentObject(viewModel)
                .hideScrollIndicators()
                .onAppear {
                    scrollCoordinator.scrollViewHeight = proxy.size.height
                }
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
        }
        .environmentObject(viewModel.alertVm)
    }

    private var currentStepView: some View {
        ZStack(alignment: .bottom) {
            if let currentStep = viewModel.currentStep {
                if viewModel.shouldHideCurrentInput {
                    ScrollToBottomButton(scrollAction: scrollToBottom)
                }
                CurrentStepView(step: currentStep)
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
                    .offset(
                        x: 0,
                        y: viewModel.shouldHideCurrentInput ? 1000 : 0
                    )
                    .accessibilityFocused($isCurrentStepFocused)
                    .disabled(viewModel.shouldHideCurrentInput)
            }
        }
        .padding(.bottom, .padding8)
        .environmentObject(viewModel)
        .animation(.default, value: viewModel.currentStep?.id)
        .animation(.easeInOut(duration: 0.5), value: scrollCoordinator.isInputScrolledOffScreen)
        .background {
            if viewModel.shouldHideCurrentInput {
                Color.clear
            } else {
                BackgroundBlurView()
                    .ignoresSafeArea(.container, edges: .bottom)
            }
        }
    }

    private func scrollToBottom() {
        scrollCoordinator.scrollToBottom()
        Task {
            try? await Task.sleep(seconds: ClaimChatConstants.Timing.standardAnimation)
            isCurrentStepFocused = true
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

private struct CurrentStepView: View {
    @ObservedObject var step: ClaimIntentStepHandler
    @EnvironmentObject var alertVm: SubmitClaimChatScreenAlertViewModel
    @EnvironmentObject var router: Router
    var body: some View {
        if step.state.showInput {
            ClaimStepView(viewModel: step)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .onChange(of: step.state.showError) { value in
                    if value {
                        alertVm.alertModel = .init(
                            type: .error,
                            message: step.state.error?.localizedDescription ?? "",
                            action: {
                                step.submitResponse()
                            },
                            onClose: {
                                if let claimError = step.state.error as? ClaimIntentError {
                                    switch claimError {
                                    case .unknownStep, .unknownField:
                                        Task { [weak router] in
                                            try? await Task.sleep(seconds: 0.1)
                                            router?.dismiss()
                                        }
                                    default:
                                        step.state.isEnabled = true
                                    }
                                } else {
                                    step.state.isEnabled = true
                                }
                            }
                        )
                    }
                }
        }
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
            input: .init(sourceMessageId: nil),
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
    @Published var progress: Double?
    var currentVerticalSizeClass: UserInterfaceSizeClass?

    /// Determines if the current input should be hidden based on scroll position, size class, and merge state
    var shouldHideCurrentInput: Bool {
        scrollCoordinator.isInputScrolledOffScreen && currentVerticalSizeClass == .regular
            && !scrollCoordinator.shouldMergeInputWithContent
    }

    // MARK: - Dependencies
    private let flowManager: ClaimIntentFlowManager
    let openChat: () -> Void
    let router = Router()
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
            totalStepsHeight: { [weak self] in self?.totalStepsHeight ?? 0 },
            currentStepInputHeight: { [weak self] in self?.currentStepInputHeight ?? 0 }
        )

        startClaimIntent()
    }

    // MARK: - UI Height Calculations
    private func recalculateStepHeights() {
        Task {
            try? await Task.sleep(seconds: ClaimChatConstants.Timing.layoutUpdate)
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
                try await Task.sleep(seconds: ClaimChatConstants.Timing.shortDelay)
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
        case let .regret(currentClaimIntent, newclaimIntent):
            handleRegretStep(currentClaimIntent: currentClaimIntent, newClaimIntent: newclaimIntent)
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
        let handler = createStepHandler(for: claimIntent)
        stepHeights[handler.id] = 0
        let previousStepId = allSteps.last?.id ?? ""

        if case .deflect = claimIntent.currentStep.content {
            self.progress = nil
        } else {
            self.progress = claimIntent.progress
        }
        Task { @MainActor in
            if !self.allSteps.isEmpty {
                currentStep = nil
            }
            self.allSteps.append(handler)
            try await Task.sleep(seconds: ClaimChatConstants.Timing.standardAnimation)
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
                currentStep?.state.showInput = false
                if indexToRemove > 0 {
                    let stepIdToScrollTo = allSteps[indexToRemove - 1].id
                    scrollTarget = .init(id: "result_\(stepIdToScrollTo)", anchor: .top)
                    try await Task.sleep(seconds: ClaimChatConstants.Timing.regretScrollDelay)
                }
                for item in allSteps[indexToRemove..<allSteps.count] {
                    stepHeights.removeValue(forKey: item.id)
                }
                allSteps.removeSubrange((indexToRemove)..<allSteps.count)
            }
            handler.state.animateText = false
            stepHeights[handler.id] = 0
            allSteps.append(handler)
            currentStep = handler
            if allSteps.count == 1 {
                scrollTarget = .init(id: handler.id, anchor: .top)
            }
            try? await Task.sleep(seconds: ClaimChatConstants.Timing.minimalDelay)
            currentStepId = handler.id
        }
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
    }
}
