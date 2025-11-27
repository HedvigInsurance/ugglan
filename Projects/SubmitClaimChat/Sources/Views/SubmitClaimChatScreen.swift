import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimChatScreen: View {
    @EnvironmentObject var viewModel: SubmitClaimChatViewModel
    @StateObject var fileUploadVm = FilesUploadViewModel(model: .init())
    @EnvironmentObject var router: Router
    @Namespace var animationNamespace
    public init() {}

    public var body: some View {
        scrollContent
        //            .hideToolbarBackgroundIfAvailable()
    }

    private var scrollContent: some View {
        ScrollViewReader { proxy in
            mainContent
                .onChange(of: viewModel.currentStepId) { currentStepId in
                    //                    withAnimation {
                    proxy.scrollTo(currentStepId, anchor: .top)
                    //                    }
                }
        }
    }

    private var mainContent: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { proxy in
                hForm {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(viewModel.allSteps, id: \.id) { step in
                            SubmitClaimChatMesageView(viewModel: step, animationNamespace: animationNamespace)
                                .padding(.vertical, .padding8)
                                .background {
                                    GeometryReader { [weak step] proxy2 in
                                        Color.clear
                                            .onAppear {
                                                viewModel.contentHeight[step?.id ?? ""] = proxy2.size.height
                                                print("Height is 3 \(step?.id ?? "") \(proxy2.size.height)")
                                            }
                                            .onChange(of: proxy2.size) { value in
                                                viewModel.contentHeight[step?.id ?? ""] = value.height
                                                print("Height is 3 \(step?.id ?? "") \(value.height)")
                                            }
                                    }
                                }
                                .transition(.opacity.combined(with: .move(edge: .leading)).animation(.defaultSpring))
                        }
                    }
                    .padding(.horizontal, .padding12)
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                    Color.clear.frame(height: max(viewModel.height - viewModel.stepsHeightSum, 0)).id("BOTTOM")
                    Color.clear.frame(height: viewModel.completedStepsHeight).id("BOTTOM2")
                }
                .hFormContentPosition(.top)
                .hFormBottomBackgroundColor(.aiPoweredGradient)
                .environmentObject(viewModel)
                .hideScrollIndicators()
                .onAppear {
                    viewModel.height = proxy.size.height
                }
                .onChange(of: proxy.size) { value in
                    viewModel.height = value.height
                }
            }
            if let currentStep = viewModel.currentStep {
                currentStep
                    .stepView(namespace: animationNamespace)
                    .transition(.move(edge: .bottom))
            }
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
    @Published var allSteps: [ClaimIntentStepHandler] = [] {
        didSet {
            setHeight()
        }
    }
    @Published var currentStep: ClaimIntentStepHandler?
    @Published var currentStepId: String = ""
    private let service: ClaimIntentService = ClaimIntentService()
    private let input: StartClaimInput
    let goToClaimDetails: GoToClaimDetails
    let openChat: () -> Void
    let router = Router()
    @Published var height: CGFloat = 0
    @Published var contentHeight: [String: CGFloat] = [:]

    private func setHeight() {
        stepsHeightSum = contentHeight.reduce(0, { $0 + $1.value })
        completedStepsHeight = allSteps.filter({ !$0.isEnabled }).map({ $0.id })
            .reduce(0) { partialResult, id in
                let valueToAdd = contentHeight[id] ?? 0
                return partialResult + valueToAdd
            }
        //        print("HEIGHT IS 5 \(stepsHeightSum) \(completedStepsHeight) \(contentHeight)")
    }
    @Published var stepsHeightSum: CGFloat = 0
    @Published var completedStepsHeight: CGFloat = 0
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
            contentHeight[handler.id] = 0

            Task {
                if !self.allSteps.isEmpty {
                    try await Task.sleep(seconds: 2)
                    withAnimation {
                        currentStep = nil
                    }
                }
                try await Task.sleep(seconds: 1)
                withAnimation {
                    self.allSteps.append(handler)
                }
                //                setHeight()
                try await Task.sleep(seconds: 1)
                withAnimation {
                    currentStep = handler
                }
            }
        //            Task {
        //                try await Task.sleep(seconds: 1.5)
        //                withAnimation {
        //                    currentStepId = handler.id
        //                }
        //            }
        case let .regret(currentClaimIntent, newclaimIntent):
            let handler = getStep(for: newclaimIntent)
            if let indexToRemove = allSteps.firstIndex(where: { $0.id == currentClaimIntent.currentStep.id }) {
                for item in allSteps[indexToRemove..<allSteps.count] {
                    contentHeight.removeValue(forKey: item.id)
                }
                allSteps.removeSubrange((indexToRemove)..<allSteps.count)
            }
            contentHeight[handler.id] = 0
            self.allSteps.append(handler)
            currentStep = handler
            currentStepId = handler.id
        case let .outcome(model):
            router.push(model)
        }
    }

    private func getStep(for claimIntent: ClaimIntent) -> ClaimIntentStepHandler {
        ClaimIntentStepHandlerFactory.createHandler(
            for: claimIntent,
            service: service
        ) { [weak self] claimEvent in
            self?.processClaimIntent(claimEvent)
        }
    }
}
