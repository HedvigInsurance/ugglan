import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
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
        //            .hideToolbarBackgroundIfAvailable()
    }

    private var scrollContent: some View {
        ScrollViewReader { proxy in
            mainContent
                .onChange(of: viewModel.scrollToStepId) { scrollToStepId in
                    withAnimation {
                        proxy.scrollTo(scrollToStepId, anchor: .top)
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
                    .padding(.horizontal, .padding12)
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                    if verticalSizeClass == .regular {
                        //                        Color.blue.frame(height: max(viewModel.scrollViewHeight - viewModel.stepsHeightSum - viewModel.scrollViewSafeArea + 32, 0))
                        Color.blue.frame(
                            height: max(
                                viewModel.scrollViewHeight - viewModel.scrollViewSafeArea + 32
                                    - viewModel.lastStepHeight,
                                0
                            )
                        )

                        //                        Color.red.frame(height: viewModel.completedStepsHeight)
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
                    scrollView.delegate = viewModel
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
        .animation(.defaultSpring, value: viewModel.currentStep?.id)
    }

    private var currentStepView: some View {
        ZStack {
            if let currentStep = viewModel.currentStep {
                if viewModel.hideBottomPart {
                    hButton(
                        .medium,
                        .primary,
                        content: .init(title: "Scroll")
                    ) {
                        viewModel.scrollToStepId = currentStep.id
                        Task {
                            try? await Task.sleep(seconds: 0.1)
                            viewModel.scrollToStepId = "nil"
                        }
                    }
                } else {
                    ClaimStepView(viewModel: currentStep)
                        .modifier(AlertHelper(viewModel: currentStep))
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
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
                    Color.orange
                        .onAppear {
                            viewModel.contentHeight[step.id] = proxy2.size.height
                        }
                        .onChange(of: proxy2.size) { value in
                            viewModel.contentHeight[step.id] = value.height
                        }
                }
            }
            .id(step.id)
            .transition(.opacity.combined(with: .move(edge: .leading)).animation(.defaultSpring))
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
    // MARK: - Published UI State
    @Published var allSteps: [ClaimIntentStepHandler] = []
    @Published var currentStep: ClaimIntentStepHandler?
    @Published var scrollToStepId: String = ""

    var scrollViewSafeArea: CGFloat = 0
    var scrollViewHeight: CGFloat = 0
    var contentHeight: [String: CGFloat] = [:] {
        didSet {
            updateHeightCalculations()
        }
    }
    @Published var stepsHeightSum: CGFloat = 0
    @Published var lastStepHeight: CGFloat = 0
    @Published var hideBottomPart = false

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
        super.init()
        Task {
            try? await self.startClaimIntent(input: input)
        }
    }

    // MARK: - UI Height Calculations
    private func updateHeightCalculations() {
        stepsHeightSum = contentHeight.values.reduce(0, +)
        //        completedStepsHeight =
        //            allSteps
        //            .filter { !$0.isEnabled }
        //            .reduce(0) { $0 + (contentHeight[$1.id] ?? 0) }
        //        completedStepsHeight =
        if let id = allSteps.last?.id {
            lastStepHeight = contentHeight[id] ?? 0
        }
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
        let previousStepId = allSteps.last?.id ?? ""
        Task { @MainActor in
            if !self.allSteps.isEmpty {
                currentStep = nil
            }
            self.allSteps.append(handler)
            try await Task.sleep(seconds: 1)
            currentStep = handler
            scrollToStepId = "result_\(previousStepId)"
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

extension SubmitClaimChatViewModel: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(
            "SCROLL \(scrollView.contentSize.height) \(scrollView.frame.size.height) \(scrollView.contentOffset.y + scrollView.safeAreaInsets.top) \(lastStepHeight)"
        )

        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        let scrollOffset = scrollView.contentOffset.y
        let bottomOffset = contentHeight - scrollViewHeight - scrollOffset
        print("SCROLL \(bottomOffset)")
        hideBottomPart = bottomOffset > 100
        //        if bottomOffset > 100 {
        //            print("User scrolled more than 100pt from the bottom: \(bottomOffset)pt")
        //        }
    }
}
