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
                    alertVm.alertModel = .init(
                        message: viewModel.error?.localizedDescription ?? "",
                        action: {
                            viewModel.startClaimIntent()
                        },
                        onClose: {
                            viewModel.router.dismiss()
                        }
                    )
                }
            }
    }

    private var scrollContent: some View {
        ScrollViewReader { proxy in
            mainContent
                .onChange(of: viewModel.scrollTarget) { scrollTarget in
                    withAnimation {
                        proxy.scrollTo(scrollTarget.id, anchor: scrollTarget.anchor)
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

                        if verticalSizeClass == .regular && !viewModel.shouldMergeInputWithContent {
                            Color.clear.frame(
                                height: viewModel.calculatePaddingHeight()
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
                    viewModel.scrollViewBottomInset = scrollView.safeAreaInsets.bottom
                    if scrollView != viewModel.scrollView {
                        viewModel.scrollView = scrollView
                    }
                }
                .hFormAttachToBottom {
                    if verticalSizeClass == .compact || viewModel.shouldMergeInputWithContent {
                        currentStepView
                    }
                }
            }
            .ignoresSafeArea(
                .keyboard,
                edges: viewModel.shouldMergeInputWithContent || viewModel.outcome != nil ? [] : .all
            )
            if verticalSizeClass == .regular && !viewModel.shouldMergeInputWithContent {
                currentStepView
            }
        }
    }

    private var currentStepView: some View {
        ZStack {
            if let currentStep = viewModel.currentStep {
                if viewModel.isInputScrolledOffScreen && verticalSizeClass == .regular
                    && !viewModel.shouldMergeInputWithContent
                {
                    ScrollToBottomButton(scrollAction: scrollToBottom)
                } else {
                    CurrentStepView(step: currentStep, alertVm: alertVm)
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
            }
        }
        .environmentObject(viewModel)
        .animation(.default, value: viewModel.currentStep?.id)
        .animation(.easeInOut(duration: 0.5), value: viewModel.isInputScrolledOffScreen)
    }

    private func scrollToBottom() {
        viewModel.scrollToBottom()
    }
}

struct ScrollToBottomButton: View {
    let scrollAction: () -> Void

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
                scrollAction()
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
                    alertVm.alertModel = .init(
                        message: step.state.error?.localizedDescription ?? "",
                        action: {
                            step.submitResponse()
                        },
                        onClose: {
                            step.state.isEnabled = true
                        }
                    )
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
                            viewModel.stepHeights[step.id] = proxy.size.height
                        }
                        .onChange(of: proxy.size) { value in
                            viewModel.stepHeights[step.id] = value.height
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
                startInput: .init(
                    input: .init(sourceMessageId: nil),
                    goToClaimDetails: { _ in
                    },
                    openChat: {
                    }
                )
            )
        )
}

// MARK: - Main Model
@MainActor
final class SubmitClaimChatViewModel: NSObject, ObservableObject {
    // MARK: - Constants
    private let inputHeightThreshold: CGFloat = 0.6
    private let topPadding: CGFloat = 32
    private let minimumSpacing: CGFloat = 10

    @Published var error: Error? {
        didSet {
            showError = error != nil
        }
    }
    @Published var showError = false
    // MARK: - Published UI State
    @Published var allSteps: [ClaimIntentStepHandler] = [] {
        didSet {
            isInputScrolledOffScreen = false
        }
    }
    @Published var currentStep: ClaimIntentStepHandler?
    @Published var scrollTarget: ScrollTarget = .init(id: "", anchor: .bottom)

    var scrollViewBottomInset: CGFloat = 0
    var scrollViewHeight: CGFloat = 0
    var stepHeights: [String: CGFloat] = [:] {
        didSet {
            recalculateStepHeights()
        }
    }
    private var scrollCancellable: AnyCancellable?

    func scrollToBottom() {
        if let scrollView {
            let bottomOffset = CGPoint(
                x: 0,
                y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom + 40
            )
            scrollView.setContentOffset(bottomOffset, animated: true)
        }
    }

    func calculatePaddingHeight() -> CGFloat {
        let height = scrollViewHeight - scrollViewBottomInset + topPadding - lastStepContentHeight
        return max(
            height,
            currentStepInputHeight + minimumSpacing
        )
    }
    weak var scrollView: UIScrollView? {
        didSet {
            scrollCancellable = scrollView?.publisher(for: \.contentOffset)
                .throttle(for: .milliseconds(200), scheduler: DispatchQueue.main, latest: true)
                .removeDuplicates()
                .sink(receiveValue: { [weak self] value in
                    self?.checkForScrollOffset()
                })
        }
    }

    private func checkForScrollOffset() {
        guard let scrollView else { return }
        // if current step bottom input part is huge, just merge it with the form
        if self.currentStepInputHeight / scrollView.frame.size.height > self.inputHeightThreshold {
            self.shouldMergeInputWithContent = true
            return
        }
        self.shouldMergeInputWithContent = false
        let visibleHeight = scrollView.frame.size.height - self.currentStepInputHeight
        let totalContentHeight = self.totalStepsHeight - scrollView.contentOffset.y + 30
        self.isInputScrolledOffScreen = visibleHeight < totalContentHeight
    }

    var totalStepsHeight: CGFloat = 0
    @Published var lastStepContentHeight: CGFloat = 0
    @Published var currentStepInputHeight: CGFloat = 0
    @Published var shouldMergeInputWithContent = false

    @Published var isInputScrolledOffScreen = false
    @Published var outcome: ClaimIntentStepOutcome?

    // MARK: - Dependencies
    private let flowManager: ClaimIntentFlowManager
    let goToClaimDetails: GoToClaimDetails
    let openChat: () -> Void
    let router = Router()
    private let input: StartClaimInput
    // MARK: - Initialization
    init(
        startInput: SubmiClaimChatInput
    ) {
        self.flowManager = ClaimIntentFlowManager(service: ClaimIntentService())
        self.goToClaimDetails = startInput.goToClaimDetails
        self.openChat = startInput.openChat
        self.input = startInput.input
        super.init()
        self.showHonestyPledge()
    }

    // MARK: - UI Height Calculations
    private func recalculateStepHeights() {
        Task {
            try? await Task.sleep(seconds: 0.1)
            checkForScrollOffset()
        }
        totalStepsHeight = stepHeights.values.reduce(0, +)
        if let id = allSteps.last?.id {
            lastStepContentHeight = stepHeights[id] ?? 0
        }
    }

    func showHonestyPledge() {
        let honestyIntent = ClaimIntent(
            currentStep: .init(
                content: .honestyPledge,
                id: "honestyPledge",
                text:
                    "För att vi ska kunna hjälpa dig på bästa sätt ber vi dig berätta om din skada precis som det hände.\n\nVår försäkring bygger på tillit. Man tar den ersättning man har rätt till, varken mer eller mindre, och därför är din beskrivning avgörande för att vi ska kunna hantera ärendet korrekt och snabbt."
            ),
            id: "honestyPledge",
            isSkippable: false,
            isRegrettable: false
        )

        processClaimIntent(.goToNext(claimIntent: honestyIntent))
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
                try await Task.sleep(seconds: 0.5)
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
        stepHeights[handler.id] = 0
        let previousStepId = allSteps.last?.id ?? ""
        Task { @MainActor in
            if !self.allSteps.isEmpty {
                currentStep = nil
            }
            self.allSteps.append(handler)
            try await Task.sleep(seconds: 1)
            currentStep = handler
            scrollTarget = .init(id: "result_\(previousStepId)", anchor: .top)
        }
    }

    private func handleRegretStep(currentClaimIntent: ClaimIntent, newClaimIntent: ClaimIntent) {
        let handler = createStepHandler(for: newClaimIntent)

        if let indexToRemove = allSteps.firstIndex(where: { $0.id == currentClaimIntent.currentStep.id }) {
            for item in allSteps[indexToRemove..<allSteps.count] {
                stepHeights.removeValue(forKey: item.id)
            }
            allSteps.removeSubrange((indexToRemove)..<allSteps.count)
        }
        let stepIdToScrollTo = allSteps.last?.id ?? handler.id
        stepHeights[handler.id] = 0
        allSteps.append(handler)
        currentStep = handler
        scrollTarget = .init(id: stepIdToScrollTo, anchor: .top)
    }

    private func createStepHandler(for claimIntent: ClaimIntent) -> ClaimIntentStepHandler {
        flowManager.createStepHandler(for: claimIntent) { [weak self] claimEvent in
            self?.processClaimIntent(claimEvent)
        }
    }

    struct ScrollTarget: Equatable {
        let id: String
        let anchor: UnitPoint
    }
}
