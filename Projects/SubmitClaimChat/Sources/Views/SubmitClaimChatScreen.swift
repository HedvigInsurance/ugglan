import Combine
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore
import hCoreUI

public struct SubmitClaimChatScreen: View {
    @EnvironmentObject var viewModel: SubmitClaimChatViewModel
    @StateObject var fileUploadVm = FilesUploadViewModel(model: .init())
    @EnvironmentObject var router: Router
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @StateObject var alertVm = SubmitClaimChatScreenAlertViewModel()

    public init() {}

    public var body: some View {
        scrollContent
            .hideToolbarBackgroundIfAvailable()
            .submitClaimChatScreenAlert(alertVm)
            .animation(.defaultSpring, value: viewModel.outcome)
            .onChange(of: viewModel.showError) { value in
                if value {
                    alertVm.alertIsPresented = .global(model: viewModel)
                }
            }
    }

    private var scrollContent: some View {
        ScrollViewReader { proxy in
            mainContent
                .onChange(of: viewModel.scrollTo) { scrollToStepId in
                    withAnimation {
                        proxy.scrollTo(scrollToStepId, anchor: .top)
                    }
                }
                .onChange(of: viewModel.outcome) { _ in
                    proxy.scrollTo("outcome", anchor: .top)
                }
        }
    }

    private var mainContent: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { proxy in
                hForm {
                    if let outcome = viewModel.outcome {
                        SubmitClaimOutcomeScreen(outcome: outcome)
                            .transition(.move(edge: .bottom))
                            .id("outcome")
                    } else {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(viewModel.allSteps, id: \.id) { step in
                                StepView(step: step)
                            }
                        }
                        .padding(.horizontal, .padding16)
                        .frame(maxWidth: .infinity, alignment: .topLeading)

                        if verticalSizeClass == .regular && !viewModel.mergeWithContent {
                            Color.clear.frame(
                                height: max(
                                    viewModel.scrollViewHeight - viewModel.scrollViewSafeArea + 32
                                        - viewModel.lastStepHeight,
                                    0
                                )
                            )
                        }
                    }
                }
                .hFormContentPosition(.top)
                .hFormBottomBackgroundColor(.aiPoweredGradient)
                .environmentObject(viewModel)
                .hideScrollIndicators()
                .onAppear {
                    viewModel.scrollViewHeight = proxy.size.height
                }
                .onChange(of: proxy.size) { value in
                    viewModel.scrollViewHeight = value.height
                }
                .introspect(.scrollView, on: .iOS(.v13...)) { scrollView in
                    viewModel.scrollViewSafeArea = scrollView.safeAreaInsets.bottom
                    if scrollView != viewModel.scrollView {
                        viewModel.scrollView = scrollView
                    }
                }
                .hFormAttachToBottom {
                    if verticalSizeClass == .compact || viewModel.mergeWithContent {
                        currentStepView
                    }
                }
            }
            .ignoresSafeArea(.keyboard, edges: viewModel.mergeWithContent ? [] : .all)
            if verticalSizeClass == .regular && !viewModel.mergeWithContent {
                currentStepView
            }
        }
    }

    private var currentStepView: some View {
        ZStack {
            if let currentStep = viewModel.currentStep {
                if viewModel.isCurrentStepScrolledOffScreen && verticalSizeClass == .regular
                    && !viewModel.mergeWithContent
                {
                    ScrollDownButton(stepId: currentStep.id, scrollAction: scrollToCurrentStep)
                } else {
                    CurrentStepView(step: currentStep, alertVm: alertVm)
                        .background {
                            GeometryReader { proxy in
                                Color.clear
                                    .onAppear {
                                        viewModel.currentStepHeight = proxy.size.height
                                    }
                                    .onChange(of: proxy.size) { value in
                                        viewModel.currentStepHeight = value.height
                                    }
                            }
                        }
                }
            }
        }
        .animation(.default, value: viewModel.currentStep?.id)
        .animation(.easeInOut(duration: 0.5), value: viewModel.isCurrentStepScrolledOffScreen)
    }

    private func scrollToCurrentStep(stepId: String) {
        viewModel.scrollTo = stepId
        Task {
            try? await Task.sleep(seconds: 0.1)
            viewModel.scrollTo = "nil"
        }
    }
}

struct ScrollDownButton: View {
    let stepId: String
    let scrollAction: (String) -> Void

    var body: some View {
        hCoreUIAssets.arrowDown.view
            .resizable()
            .frame(width: 24, height: 24)
            .padding(.padding8)
            .background(hFillColor.Opaque.negative)
            .clipShape(Circle())
            .contentShape(Circle())
            .hShadow(type: .custom(opacity: 0.05, radius: 5, xOffset: 0, yOffset: 4), show: true)
            .hShadow(type: .custom(opacity: 0.1, radius: 1, xOffset: 0, yOffset: 2), show: true)
            .onTapGesture {
                scrollAction(stepId)
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

private struct CurrentStepView: View {
    @ObservedObject var step: ClaimIntentStepHandler
    @ObservedObject var alertVm: SubmitClaimChatScreenAlertViewModel

    var body: some View {
        ClaimStepView(viewModel: step)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .onChange(of: step.state.showError) { value in
                if value {
                    alertVm.alertIsPresented = .step(model: step)
                }
            }
    }
}

struct StepView: View {
    @EnvironmentObject var viewModel: SubmitClaimChatViewModel
    @ObservedObject var step: ClaimIntentStepHandler

    var body: some View {
        SubmitClaimChatMesageView(viewModel: step)
            .padding(.vertical, .padding8)
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            viewModel.contentHeight[step.id] = proxy.size.height
                        }
                        .onChange(of: proxy.size) { value in
                            viewModel.contentHeight[step.id] = value.height
                        }
                }
            }
            .id(step.id)
    }
}

extension SubmitClaimChatScreen: TrackingViewNameProtocol {
    public var nameForTracking: String {
        .init(describing: self)
    }
}

extension View {
    @ViewBuilder
    fileprivate func hideToolbarBackgroundIfAvailable() -> some View {
        if #available(iOS 16.0, *) {
            self.toolbarBackground(.hidden, for: .navigationBar)
        } else {
            self
        }
    }

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
    Dependencies.shared.add(module: Module { () -> ClaimIntentClient in ClaimIntentClientDemo() })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return SubmitClaimChatScreen()
        .embededInNavigation(tracking: "")
        .environmentObject(
            SubmitClaimChatViewModel(
                input: .init(sourceMessageId: nil),
                goToClaimDetails: { _ in
                },
                openChat: {
                }
            )
        )
}

// MARK: - Main Model
@MainActor
final class SubmitClaimChatViewModel: NSObject, ObservableObject {
    @Published var error: Error? {
        didSet {
            showError = error != nil
        }
    }
    @Published var showError = false
    // MARK: - Published UI State
    @Published var allSteps: [ClaimIntentStepHandler] = [] {
        didSet {
            isCurrentStepScrolledOffScreen = false
        }
    }
    @Published var currentStep: ClaimIntentStepHandler?
    @Published var scrollTo: String = ""

    var scrollViewSafeArea: CGFloat = 0
    var scrollViewHeight: CGFloat = 0
    var contentHeight: [String: CGFloat] = [:] {
        didSet {
            updateHeightCalculations()
        }
    }
    private var scrollCancellable: AnyCancellable?

    var scrollView: UIScrollView? {
        didSet {
            scrollCancellable = scrollView?.publisher(for: \.contentOffset)
                .throttle(for: .milliseconds(200), scheduler: DispatchQueue.main, latest: true)
                .removeDuplicates()
                .sink(receiveValue: { [weak self] value in
                    guard let self, let scrollView = self.scrollView else { return }
                    // if current step bottom input part is huge, just merge it with the form
                    if self.currentStepHeight / scrollView.frame.size.height > 0.6 {
                        self.mergeWithContent = true
                        return
                    }
                    self.mergeWithContent = false
                    let visibleHeight = scrollView.frame.size.height - self.currentStepHeight
                    let totalContentHeight = self.stepsHeightSum - scrollView.contentOffset.y + 30
                    self.isCurrentStepScrolledOffScreen = visibleHeight < totalContentHeight
                })
        }
    }

    var stepsHeightSum: CGFloat = 0
    @Published var lastStepHeight: CGFloat = 0
    @Published var currentStepHeight: CGFloat = 0
    @Published var mergeWithContent = false

    @Published var isCurrentStepScrolledOffScreen = false
    @Published var outcome: ClaimIntentStepOutcome?

    // MARK: - Dependencies
    private let flowManager: ClaimIntentFlowManager
    let goToClaimDetails: GoToClaimDetails
    let openChat: () -> Void
    let router = Router()
    private let input: StartClaimInput
    // MARK: - Initialization
    init(
        input: StartClaimInput,
        goToClaimDetails: @escaping GoToClaimDetails,
        openChat: @escaping () -> Void
    ) {
        self.flowManager = ClaimIntentFlowManager(service: ClaimIntentService())
        self.goToClaimDetails = goToClaimDetails
        self.openChat = openChat
        self.input = input
        super.init()
        self.startClaimIntent()
    }

    // MARK: - UI Height Calculations
    private func updateHeightCalculations() {
        stepsHeightSum = contentHeight.values.reduce(0, +)
        if let id = allSteps.last?.id {
            lastStepHeight = contentHeight[id] ?? 0
        }
    }

    // MARK: - Business Logic
    func startClaimIntent() {
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
                self.error = error
            }
        }
    }

    private func processClaimIntent(_ claimEvent: SubmitClaimEvent) {
        switch claimEvent {
        case let .goToNext(claimIntent):
            handleGoToNextStep(claimIntent: claimIntent)
        case let .regret(currentClaimIntent, newclaimIntent):
            handleRegretStep(currentClaimIntent: currentClaimIntent, newClaimIntent: newclaimIntent)
        case let .outcome(model):
            self.allSteps.removeAll()
            self.currentStep = nil
            Task {
                try? await Task.sleep(seconds: 0.5)
                self.outcome = model
            }
        }
    }

    private func handleGoToNextStep(claimIntent: ClaimIntent) {
        let handler = createStepHandler(for: claimIntent)
        contentHeight[handler.id] = 0
        let previousStepId = allSteps.last?.id ?? ""
        Task { @MainActor in
            if !self.allSteps.isEmpty {
                currentStep = nil
            }
            self.allSteps.append(handler)
            try await Task.sleep(seconds: 1)
            currentStep = handler
            scrollTo = "result_\(previousStepId)"
        }
    }

    private func handleRegretStep(currentClaimIntent: ClaimIntent, newClaimIntent: ClaimIntent) {
        let handler = createStepHandler(for: newClaimIntent)

        if let indexToRemove = allSteps.firstIndex(where: { $0.id == currentClaimIntent.currentStep.id }) {
            for item in allSteps[indexToRemove..<allSteps.count] {
                contentHeight.removeValue(forKey: item.id)
            }
            allSteps.removeSubrange((indexToRemove)..<allSteps.count)
        }
        let stepIdToScrollTo = allSteps.last?.id ?? handler.id
        contentHeight[handler.id] = 0
        allSteps.append(handler)
        currentStep = handler
        scrollTo = stepIdToScrollTo
    }

    private func createStepHandler(for claimIntent: ClaimIntent) -> ClaimIntentStepHandler {
        flowManager.createStepHandler(for: claimIntent) { [weak self] claimEvent in
            self?.processClaimIntent(claimEvent)
        }
    }
}
