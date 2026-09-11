import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
import hCore
import hCoreUI

/// Entry point used by the SubmitClaimChat example app.
public struct ClaimInputPrototypeRoot: View {
    @StateObject private var viewModel: ClaimInputPrototypeViewModel

    /// `startState` accepts "resting", "text", "voice", "savedText" or "savedVoice"
    /// (e.g. launch argument `-prototypeState voice` in the example scheme). Unknown values start at resting.
    public init(startState: String? = nil) {
        let state = startState.flatMap { ClaimInputPrototypeViewModel.StartState(rawValue: $0) } ?? .resting
        _viewModel = StateObject(wrappedValue: ClaimInputPrototypeViewModel(startState: state))
    }

    public var body: some View {
        ClaimInputPrototypeScreen(viewModel: viewModel)
            .navigationTitle(ClaimInputPrototypeCopy.navigationTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.reset()
                    } label: {
                        hCoreUIAssets.close.view
                            .frame(minWidth: 44, minHeight: 44)
                    }
                    .foregroundColor(hTextColor.Opaque.primary)
                    .accessibilityLabel(L10n.a11YClose)
                }
            }
            .embededInNavigation(options: [.extendedNavigationWidth], tracking: ClaimInputPrototypeTracking.root)
    }
}

enum ClaimInputPrototypeTracking: TrackingViewNameProtocol {
    case root

    var nameForTracking: String {
        "ClaimInputPrototype"
    }
}

/// Structure copied from `SubmitClaimChatScreen`: hForm + scroll coordinator + docked current input.
struct ClaimInputPrototypeScreen: View {
    @ObservedObject var viewModel: ClaimInputPrototypeViewModel
    @ObservedObject var scrollCoordinator: ClaimChatScrollCoordinator
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @AccessibilityFocusState private var isCurrentStepFocused: Bool

    init(viewModel: ClaimInputPrototypeViewModel) {
        self.viewModel = viewModel
        _scrollCoordinator = ObservedObject(wrappedValue: viewModel.scrollCoordinator)
    }

    var body: some View {
        scrollContent
            .onChange(of: verticalSizeClass) { value in
                viewModel.currentVerticalSizeClass = value
            }
            .onAppear {
                viewModel.currentVerticalSizeClass = verticalSizeClass
            }
            .addProgressBar(with: $viewModel.progress)
            .environmentObject(viewModel)
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
                        ForEach(viewModel.steps, id: \.id) { step in
                            ClaimInputPrototypeStepView(step: step)
                        }
                    }
                    .padding(.horizontal, .padding16)
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                    if verticalSizeClass == .regular && !scrollCoordinator.shouldMergeInputWithContent {
                        Color.clear.frame(height: viewModel.calculatePaddingHeight())
                    }
                }
                .hFormContentPosition(.top)
                .scrollIndicators(.hidden)
                .onAppear {
                    scrollCoordinator.scrollViewHeight = proxy.size.height
                }
                .hFormBottomBackgroundColor(.aiPoweredGradient)
                .onChange(of: proxy.size) { value in
                    scrollCoordinator.scrollViewHeight = value.height
                }
                .introspect(.scrollView, on: .iOS(.v13...)) { scrollView in
                    scrollCoordinator.scrollViewBottomInset = scrollView.safeAreaInsets.bottom
                    viewModel.scrollView = scrollView
                    // Stay detached while the text card (and keyboard) is open – see beginText().
                    if viewModel.inputMode != .text, scrollView != scrollCoordinator.scrollView {
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
                edges: scrollCoordinator.shouldMergeInputWithContent ? [] : .all
            )
            if verticalSizeClass == .regular && !scrollCoordinator.shouldMergeInputWithContent {
                currentStepView
            }
        }
    }

    private var currentStepView: some View {
        VStack(spacing: .padding8) {
            // Figma 1.3: the input stays docked while scrolling; the arrow above it jumps back to the question.
            if viewModel.isQuestionScrolledAway && viewModel.inputMode != .hidden {
                ScrollToBottomButton(scrollAction: scrollToBottom)
                    .padding(.top, .padding16)
            }
            if viewModel.inputMode != .hidden {
                inputContent
                    .padding(.top, viewModel.isQuestionScrolledAway ? 0 : .padding16)
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
                    .transition(.offset(x: 0, y: 1000))
                    .accessibilityFocused($isCurrentStepFocused)
            }
        }
        .padding(.bottom, .padding16)
        .background {
            // Frosted glass behind the docked inputs (1.x and follow-ups). The cards (2.x / 3.x) float on the page.
            if viewModel.inputMode == .choose || viewModel.inputMode == .select {
                BackgroundBlurView()
                    .clipShape(hRoundedRectangle(cornerRadius: .cornerRadiusL, corners: [.topLeft, .topRight]))
                    .ignoresSafeArea(.container, edges: .bottom)
            }
        }
        .animation(.default, value: viewModel.inputMode)
        .animation(.easeInOut(duration: 0.5), value: scrollCoordinator.isInputScrolledOffScreen)
    }

    @ViewBuilder
    private var inputContent: some View {
        switch viewModel.inputMode {
        case .hidden:
            EmptyView()
        case .choose:
            ClaimInputPrototypeChoiceView()
        case .text:
            ClaimInputPrototypeTextCard()
                .padding(.horizontal, .padding16)
        case .voice:
            ClaimInputPrototypeVoiceCard(voiceRecorder: viewModel.voiceRecorder)
                .padding(.horizontal, .padding16)
        case .select:
            if let step = viewModel.currentStep {
                ClaimInputPrototypeSelectView(step: step)
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

// MARK: - One step in the chat (mirrors StepView + SubmitClaimChatMessageView)
struct ClaimInputPrototypeStepView: View {
    @EnvironmentObject var viewModel: ClaimInputPrototypeViewModel
    @ObservedObject var step: ClaimInputPrototypeStep

    var body: some View {
        ClaimInputPrototypeMessageView(step: step)
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
                    insertion: step.animateText
                        ? .offset(x: 0, y: 100).combined(with: .opacity).animation(.default)
                        : .opacity.animation(.easeInOut(duration: 0)),
                    removal: .opacity.animation(.easeInOut(duration: 0.1))
                )
            )
    }
}

struct ClaimInputPrototypeMessageView: View {
    @EnvironmentObject var viewModel: ClaimInputPrototypeViewModel
    @ObservedObject var step: ClaimInputPrototypeStep

    var body: some View {
        VStack(spacing: .padding8) {
            // Figma: 24 pt Hedvig symbol to the left of the message, 8 pt gap.
            HStack(alignment: .top, spacing: .padding8) {
                if step.showLoadingAnimation {
                    ClaimChatLoadingAnimationView(isLoading: $step.isLoaderAnimating)
                        .frame(width: 24, height: 24)
                }
                RevealTextView(
                    text: step.text,
                    delay: 1,
                    animate: step.animateText,
                    onTextAnimationDone: {
                        step.isLoaderAnimating = false
                        viewModel.revealFinished(for: step)
                    }
                )
                .accessibilityAddTraits(.isHeader)
                .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }

            HStack {
                Spacer()
                VStack(alignment: .trailing, spacing: .padding6) {
                    ClaimInputPrototypeResultView(step: step)
                        .transition(.offset(x: 0, y: 100).combined(with: .opacity).animation(.default))
                    if step.answer != nil, step.isRegrettable {
                        hPill(
                            text: ClaimInputPrototypeCopy.edit,
                            color: .grey,
                            colorLevel: .two,
                            withBorder: false
                        )
                        .hFieldSize(.large)
                        .capsuleShape(true)
                        .hPillAttributes(attributes: [.withChevron])
                        .onTapGesture {
                            viewModel.regret(step)
                        }
                        .accessibilityAddTraits(.isButton)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: step.answer)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, step.answer == nil ? 0 : .padding16)
            .id("result_\(step.id)")
        }
    }
}

struct ClaimInputPrototypeResultView: View {
    @ObservedObject var step: ClaimInputPrototypeStep

    @ViewBuilder var body: some View {
        switch step.answer {
        case .skipped:
            hText(L10n.claimChatSkippedStep)
                .foregroundColor(hTextColor.Translucent.secondary)
                .hPillStyle(color: .grey, colorLevel: .two, withBorder: false)
                .hFieldSize(.large)
                .capsuleShape(true)
        case let .pill(title):
            hPill(text: title, color: .grey, colorLevel: .two, withBorder: false)
                .hFieldSize(.large)
                .capsuleShape(true)
        case let .text(text):
            hText(text)
                .foregroundColor(hTextColor.Opaque.primary)
                .hPillStyle(color: .grey, colorLevel: .two)
                .hFieldSize(.extraLarge)
                .padding(.leading, .padding48)
        case let .voice(levels):
            ClaimInputPrototypeVoiceMemoBubble(levels: levels)
                .padding(.leading, .padding48)
        case nil:
            EmptyView()
        }
    }
}

#Preview {
    ClaimInputPrototypeRoot()
}
