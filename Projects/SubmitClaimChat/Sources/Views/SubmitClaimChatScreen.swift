import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimChatScreen: View {
    @EnvironmentObject var viewModel: SubmitClaimChatViewModel
    @StateObject var fileUploadVm = FilesUploadViewModel(model: .init())
    @EnvironmentObject var router: Router
    public init() {}

    public var body: some View {
        scrollContent
            .hideToolbarBackgroundIfAvailable()
    }

    private var scrollContent: some View {
        ScrollViewReader { proxy in
            mainContent
                .onChange(of: viewModel.currentStepId) { currentStepId in
                    withAnimation {
                        proxy.scrollTo(currentStepId, anchor: .top)
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
                            SubmitClaimChatMesageView(viewModel: step)
                                .padding(.vertical, .padding8)
                                .background {
                                    GeometryReader { [weak step] proxy2 in
                                        Color.clear
                                            .onAppear {
                                                viewModel.contentHeight[step?.id ?? ""] = proxy2.size.height
                                            }
                                            .onChange(of: proxy2.size) { value in
                                                viewModel.contentHeight[step?.id ?? ""] = value.height
                                            }
                                    }
                                }
                                .id(step.id)
                                .transition(.opacity.combined(with: .move(edge: .leading)).animation(.defaultSpring))
                        }
                    }
                    .padding(.horizontal, .padding12)
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                    Color.clear.frame(height: max(viewModel.scrollViewHeight - viewModel.stepsHeightSum, 0))
                    Color.clear.frame(height: viewModel.completedStepsHeight)
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
            }
            ZStack {
                if let currentStep = viewModel.currentStep {
                    currentStep
                        .stepView()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .animation(.defaultSpring, value: viewModel.currentStep?.id)
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
    // MARK: - Published UI State
    @Published var allSteps: [ClaimIntentStepHandler] = [] {
        didSet {
            updateHeightCalculations()
        }
    }
    @Published var currentStep: ClaimIntentStepHandler?
    @Published var currentStepId: String = ""

    @Published var scrollViewHeight: CGFloat = 0
    @Published var contentHeight: [String: CGFloat] = [:]
    @Published var stepsHeightSum: CGFloat = 0
    @Published var completedStepsHeight: CGFloat = 0

    // MARK: - Dependencies
    private let flowManager: ClaimIntentFlowManager
    let goToClaimDetails: GoToClaimDetails
    let openChat: () -> Void
    let router = Router()

    // MARK: - Initialization
    init(
        input: StartClaimInput,
        goToClaimDetails: @escaping GoToClaimDetails,
        openChat: @escaping () -> Void
    ) {
        self.flowManager = ClaimIntentFlowManager(service: ClaimIntentService())
        self.goToClaimDetails = goToClaimDetails
        self.openChat = openChat
        Task {
            try? await startClaimIntent(input: input)
        }
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
    func startClaimIntent(input: StartClaimInput) async throws {
        guard let claimIntent = try await flowManager.startClaimIntent(input: input) else {
            throw ClaimIntentError.invalidResponse
        }

        switch claimIntent {
        case let .intent(model):
            processClaimIntent(.goToNext(claimIntent: model))
        case let .outcome(model):
            processClaimIntent(.outcome(model: model))
        }
    }

    private func processClaimIntent(_ claimEvent: SubmitClaimEvent) {
        switch claimEvent {
        case let .goToNext(claimIntent):
            handleGoToNextStep(claimIntent: claimIntent)
        case let .regret(currentClaimIntent, newclaimIntent):
            handleRegretStep(currentClaimIntent: currentClaimIntent, newClaimIntent: newclaimIntent)
        case let .outcome(model):
            router.push(model)
        }
    }

    private func handleGoToNextStep(claimIntent: ClaimIntent) {
        let handler = createStepHandler(for: claimIntent)
        contentHeight[handler.id] = 0

        Task { @MainActor in
            if !self.allSteps.isEmpty {
                try await Task.sleep(seconds: 0.5)
                currentStep = nil
            }
            try await Task.sleep(seconds: 0.5)
            self.allSteps.append(handler)
            try await Task.sleep(seconds: 1)
            currentStep = handler
            currentStepId = handler.id
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

        contentHeight[handler.id] = 0
        allSteps.append(handler)
        currentStep = handler
        currentStepId = handler.id
    }

    private func createStepHandler(for claimIntent: ClaimIntent) -> ClaimIntentStepHandler {
        flowManager.createStepHandler(for: claimIntent) { [weak self] claimEvent in
            self?.processClaimIntent(claimEvent)
        }
    }
}
