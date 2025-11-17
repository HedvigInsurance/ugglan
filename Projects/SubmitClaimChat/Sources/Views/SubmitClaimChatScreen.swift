import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimChatScreen: View {
    @StateObject var viewModel: SubmitClaimChatViewModel
    @EnvironmentObject var router: Router
    let input: StartClaimInput

    public init(
        input: StartClaimInput,
        goToClaimDetails: @escaping (String) -> Void
    ) {
        self.input = input
        _viewModel = StateObject(
            wrappedValue: .init(input: input)
        )
    }

    public var body: some View {
        successView
    }

    private var successView: some View {
        Group {
            if #available(iOS 16.0, *) {
                scrollContent
                    .toolbarBackground(.hidden, for: .navigationBar)
            } else {
                scrollContent
            }
        }
        .colorScheme(.light)
    }

    private var scrollContent: some View {
        ScrollViewReader { proxy in
            mainContent
                .task(id: viewModel.allSteps.last?.claimIntent.currentStep.id) {
                    try? await Task.sleep(seconds: 0.05)
                    withAnimation { proxy.scrollTo("BOTTOM", anchor: .bottom) }
                }
                .onAppear {
                    proxy.scrollTo("BOTTOM", anchor: .bottom)
                }
                .onChange(of: viewModel.allSteps.count) { _ in
                    withAnimation { proxy.scrollTo("BOTTOM", anchor: .bottom) }
                }
        }
    }

    private var mainContent: some View {
        hForm {
            VStack(spacing: .padding16) {
                ForEach(viewModel.allSteps, id: \.claimIntent.currentStep.id) { step in
                    HStack {
                        spacing(step.sender == .member)
                        VStack(alignment: .leading, spacing: 0) {
                            SubmitClaimChatMesageView(step: step)
                            senderStamp(step: step)
                        }
                        spacing(step.sender == .hedvig)
                    }
                    .id(step.id)
                }
                Color.clear.frame(height: 1).id("BOTTOM")
            }
            .padding(.horizontal, .padding16)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .hFormContentPosition(.top)
        .hFormBottomBackgroundColor(.aiPoweredGradient)
        .environmentObject(viewModel)
    }

    private var loadingView: some View {
        HStack { DotsActivityIndicator(.standard) }
            .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
            .padding(.horizontal, .padding16)
            .background(hBackgroundColor.primary.opacity(0.01))
            .edgesIgnoringSafeArea(.top)
            .useDarkColor
            .transition(.opacity.combined(with: .opacity).animation(.easeInOut(duration: 0.2)))
    }

    @ViewBuilder
    func spacing(_ addSpacing: Bool) -> some View {
        if addSpacing { Spacer() }
    }

    @ViewBuilder
    func senderStamp(step: any ClaimIntentStepHandler) -> some View {
        if step.isLoading {
            loadingView
        } else if step.sender == .hedvig {
            HStack {
                Circle()
                    .frame(width: 16, height: 16)
                    .foregroundColor(hSignalColor.Green.element)
                hText("Hedvig AI Assistant", style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)
            }
            .padding(.leading, .padding16)
        }
    }
}

extension SubmitClaimChatScreen: TrackingViewNameProtocol {
    public var nameForTracking: String { "" }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> ClaimIntentClient in ClaimIntentClientDemo() })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return SubmitClaimChatScreen(input: .init(sourceMessageId: nil, devFlow: false), goToClaimDetails: { _ in })
}

// MARK: - Main Model
@MainActor
final class SubmitClaimChatViewModel: ObservableObject {
    @Published var currentStepHandler: (any ClaimIntentStepHandler)?
    @Published var allSteps: [any ClaimIntentStepHandler] = []

    private let service: ClaimIntentService = ClaimIntentService()
    private let input: StartClaimInput
    init(input: StartClaimInput) {
        self.input = input
        Task {
            try? await startClaimIntent(input: input)
        }
    }

    func startClaimIntent(input: StartClaimInput) async throws {
        guard let claimIntent = try await service.startClaimIntent(input: input) else {
            throw ClaimIntentError.invalidResponse
        }

        processClaimIntent(claimIntent)
    }

    private func processClaimIntent(_ claimIntent: ClaimIntent) {
        let handler = getNextStep(claimIntent)
        self.currentStepHandler = handler
        self.allSteps.append(handler)
        if let handler = handler as? SubmitClaimTaskStep {
            handleTaskStep(handler: handler)
        }
    }

    private func getNextStep(_ claimIntent: ClaimIntent) -> any ClaimIntentStepHandler {
        ClaimIntentStepHandlerFactory.createHandler(
            for: claimIntent,
            sender: .hedvig,
            service: service
        )
    }

    private func handleTaskStep(handler: SubmitClaimTaskStep) {
        Task {
            do {
                if handler.isTaskCompleted {
                    let claimIntent = try await handler.submitResponse()
                    withAnimation {
                        allSteps.removeAll(where: {
                            $0.claimIntent.currentStep.id == handler.claimIntent.currentStep.id
                        })
                        processClaimIntent(claimIntent)
                    }
                } else {
                    try await Task.sleep(seconds: 0.5)
                    let claimIntent = try await getNextStep(intentId: handler.claimIntent.id)
                    let newHandler = getNextStep(claimIntent)
                    if let newHandler = newHandler as? SubmitClaimTaskStep {
                        handleTaskStep(handler: newHandler)
                    } else {
                        processClaimIntent(claimIntent)
                    }
                }
            } catch let ex {
                let ss = ""
            }
        }
    }

    private func getNextStep(intentId: String) async throws -> ClaimIntent {
        try await service.getNextStep(claimIntentId: intentId)
    }

    func submitStep(handler: any ClaimIntentStepHandler) async throws {
        handler.isLoading = true
        let claimIntent = try await handler.submitResponse()
        handler.isLoading = false
        handler.isEnabled = false
        processClaimIntent(claimIntent)
    }
}
