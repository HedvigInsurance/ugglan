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
                .scrollToBottom(
                    proxy: proxy,
                    id: viewModel.allSteps.last?.claimIntent.currentStep.id,
                    count: viewModel.allSteps.count
                )
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

    fileprivate func scrollToBottom<T: Hashable>(proxy: ScrollViewProxy, id: T?, count: Int) -> some View {
        self
            .task(id: id) {
                try? await Task.sleep(seconds: 0.05)
                withAnimation { proxy.scrollTo("BOTTOM", anchor: .bottom) }
            }
            .onAppear {
                proxy.scrollTo("BOTTOM", anchor: .bottom)
            }
            .onChange(of: count) { _ in
                withAnimation { proxy.scrollTo("BOTTOM", anchor: .bottom) }
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
    @Published var allSteps: [ClaimIntentStepHandler] = []
    private let service: ClaimIntentService = ClaimIntentService()
    private let input: StartClaimInput
    let goToClaimDetails: GoToClaimDetails
    let openChat: () -> Void
    let router = Router()

    init(
        input: StartClaimInput,
        goToClaimDetails: @escaping GoToClaimDetails,
        openChat: @escaping () -> Void
    ) {
        self.input = input
        self.goToClaimDetails = goToClaimDetails
        self.openChat = openChat
        Task {
            try? await startClaimIntent(input: input)
        }
    }

    func startClaimIntent(input: StartClaimInput) async throws {
        guard let claimIntent = try await service.startClaimIntent(input: input) else {
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
            let handler = getStep(for: claimIntent)
            self.allSteps.append(handler)
        case let .regret(currentClaimIntent, newclaimIntent):
            let handler = getStep(for: newclaimIntent)
            if let indexToRemove = allSteps.firstIndex(where: { $0.id == currentClaimIntent.currentStep.id }) {
                allSteps.removeSubrange((indexToRemove)..<allSteps.count)
            }
            self.allSteps.append(handler)
        case let .outcome(model):
            router.push(model)
        }
    }

    private func getStep(for claimIntent: ClaimIntent) -> ClaimIntentStepHandler {
        ClaimIntentStepHandlerFactory.createHandler(
            for: claimIntent,
            service: service
        ) { [weak self] claimEvent in
            withAnimation {
                self?.processClaimIntent(claimEvent)
            }
        }
    }
}
