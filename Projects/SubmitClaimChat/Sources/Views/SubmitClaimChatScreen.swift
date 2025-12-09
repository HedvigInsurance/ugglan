import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimChatScreen: View {
    @EnvironmentObject var viewModel: SubmitClaimChatViewModel
    @StateObject var fileUploadVm = FilesUploadViewModel(model: .init())
    @EnvironmentObject var router: Router
    @Environment(\.verticalSizeClass) var verticalSizeClass

    public init() {}

    public var body: some View {
        scrollContent
            .hideToolbarBackgroundIfAvailable()
            .modifier(SubmitClaimChatScreenAlertHelper(viewModel: viewModel))
            .animation(.defaultSpring, value: viewModel.outcome)
    }

    private var scrollContent: some View {
        ScrollViewReader { proxy in
            mainContent
                .onChange(of: viewModel.scrollToStepId) { scrollToStepId in
                    withAnimation {
                        proxy.scrollTo("result_\(scrollToStepId)", anchor: .top)
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
                        .padding(.horizontal, .padding12)
                        .frame(maxWidth: .infinity, alignment: .topLeading)

                        if verticalSizeClass == .regular {
                            Color.clear.frame(height: max(viewModel.scrollViewHeight - viewModel.stepsHeightSum, 0))
                            Color.clear.frame(height: viewModel.completedStepsHeight)
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
                .hFormAttachToBottom {
                    if verticalSizeClass == .compact {
                        currentStepView
                    }
                }
            }
            if verticalSizeClass == .regular {
                currentStepView
            }
        }
    }

    private var currentStepView: some View {
        ZStack {
            if let currentStep = viewModel.currentStep {
                ClaimStepView(viewModel: currentStep)
                    .modifier(AlertHelper(viewModel: currentStep))
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.default, value: viewModel.currentStep?.id)
    }
}

struct StepView: View {
    @EnvironmentObject var viewModel: SubmitClaimChatViewModel
    @ObservedObject var step: ClaimIntentStepHandler

    var body: some View {
        SubmitClaimChatMesageView(viewModel: step)
            .padding(.vertical, !(step is SubmitClaimTaskStep) ? .padding8 : 0)
            .background {
                GeometryReader { proxy2 in
                    Color.clear
                        .onAppear {
                            viewModel.contentHeight[step.id] = proxy2.size.height
                        }
                        .onChange(of: proxy2.size) { value in
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
            updateHeightCalculations()
        }
    }
    @Published var currentStep: ClaimIntentStepHandler?
    @Published var scrollToStepId: String = ""

    @Published var scrollViewHeight: CGFloat = 0
    @Published var contentHeight: [String: CGFloat] = [:]
    @Published var stepsHeightSum: CGFloat = 0
    @Published var completedStepsHeight: CGFloat = 0
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
        self.startClaimIntent()
    }

    // MARK: - UI Height Calculations
    private func updateHeightCalculations() {
        stepsHeightSum = contentHeight.values.reduce(0, +)
        completedStepsHeight =
            allSteps
            .filter { !$0.isEnabled }
            .reduce(0) { $0 + (contentHeight[$1.id] ?? 0) }
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
            scrollToStepId = previousStepId
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
        scrollToStepId = stepIdToScrollTo
    }

    private func createStepHandler(for claimIntent: ClaimIntent) -> ClaimIntentStepHandler {
        flowManager.createStepHandler(for: claimIntent) { [weak self] claimEvent in
            self?.processClaimIntent(claimEvent)
        }
    }
}
