import SwiftUI
import hCore
import hCoreUI

public typealias GoToClaimDetails = (String) -> Void

public struct SubmitClaimChatScreen: View {
    @StateObject var viewModel: SubmitClaimChatViewModel
    @StateObject var fileUploadVm = FilesUploadViewModel(model: .init())
    @EnvironmentObject var router: Router
    let input: StartClaimInput
    let goToClaimDetails: GoToClaimDetails
    public init(
        input: StartClaimInput,
        goToClaimDetails: @escaping GoToClaimDetails
    ) {
        self.input = input
        self.goToClaimDetails = goToClaimDetails
        _viewModel = StateObject(
            wrappedValue: .init(input: input, goToClaimDetails: goToClaimDetails)
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
            VStack(alignment: .leading, spacing: .padding16) {
                ForEach(viewModel.allSteps, id: \.id) { step in
                    SubmitClaimChatMesageView(viewModel: step)
                }
                Color.clear.frame(height: 50).id("BOTTOM")
            }
            .padding(.horizontal, .padding12)
            .padding(.vertical, .padding8)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .hFormContentPosition(.top)
        .hFormBottomBackgroundColor(.aiPoweredGradient)
        .environmentObject(viewModel)
        .hideScrollIndicators()
    }
}

extension SubmitClaimChatScreen: TrackingViewNameProtocol {
    public var nameForTracking: String { "" }
}

extension View {
    @ViewBuilder
    func hideScrollIndicators() -> some View {
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
    return SubmitClaimChatScreen(input: .init(sourceMessageId: nil, devFlow: false), goToClaimDetails: { _ in })
}

// MARK: - Main Model
@MainActor
final class SubmitClaimChatViewModel: ObservableObject {
    @Published var allSteps: [ClaimIntentStepHandler] = []
    let goToClaimDetails: GoToClaimDetails
    private let service: ClaimIntentService = ClaimIntentService()
    private let input: StartClaimInput

    init(input: StartClaimInput, goToClaimDetails: @escaping GoToClaimDetails) {
        self.input = input
        self.goToClaimDetails = goToClaimDetails
        Task {
            try? await startClaimIntent(input: input)
        }
    }

    func startClaimIntent(input: StartClaimInput) async throws {
        guard let claimIntent = try await service.startClaimIntent(input: input) else {
            throw ClaimIntentError.invalidResponse
        }
        processClaimIntent(claimIntent, isRegret: false)
    }

    private func processClaimIntent(_ claimIntent: ClaimIntent, isRegret: Bool) {
        let handler = getStep(for: claimIntent)
        if isRegret {
            if let indexToRemove = allSteps.firstIndex(where: { $0.isRegretted }) {
                allSteps.removeSubrange((indexToRemove)..<allSteps.count)
            }
        }
        self.allSteps.append(handler)
    }

    private func getStep(for claimIntent: ClaimIntent) -> ClaimIntentStepHandler {
        ClaimIntentStepHandlerFactory.createHandler(
            for: claimIntent,
            service: service
        ) { [weak self] newClaimIntent, isRegret in
            withAnimation {
                self?.processClaimIntent(newClaimIntent, isRegret: isRegret)
            }
        }
    }
}
