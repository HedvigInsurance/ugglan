import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimChatMesageView: View {
    @ObservedObject var viewModel: ClaimIntentStepHandler

    var body: some View {
        VStack(spacing: .padding8) {
            HStack {
                VStack(alignment: .leading, spacing: .padding8) {
                    TextAnimation(text: viewModel.claimIntent.currentStep.text)
                }

                .fixedSize(horizontal: false, vertical: true)
                Spacer()
                if viewModel.isRegrettable && !viewModel.isEnabled {
                    regretButton
                }
            }

            HStack {
                spacing(viewModel.sender == .member)
                viewModel.resultView()
                    .frame(
                        maxWidth: viewModel.maxWidth,
                        alignment: viewModel.alignment
                    )
                    .disabled(!viewModel.isEnabled)
                    .hButtonIsLoading(viewModel.isLoading)
                    .trackError(for: $viewModel.error)
                    .hStateViewButtonConfig(
                        .init(
                            actionButton: .init(
                                buttonAction: { [weak viewModel] in
                                    withAnimation {
                                        viewModel?.isEnabled = true
                                        viewModel?.error = nil
                                        viewModel?.isLoading = false
                                    }
                                })
                        )
                    )
                    .fixedSize(horizontal: false, vertical: true)
                    .id("result_\(viewModel.id)")
                spacing(viewModel.sender == .hedvig)
            }
        }
    }

    private var regretButton: some View {
        hCoreUIAssets.edit.view
            .onTapGesture {
                Task {
                    await viewModel.regret()
                }
            }
    }

    @ViewBuilder
    func spacing(_ addSpacing: Bool) -> some View {
        if addSpacing { Spacer() }
    }

    @ViewBuilder
    func senderStamp(step: ClaimIntentStepHandler) -> some View {
        if step.isLoading {
            loadingView
        } else {
            HStack {
                Circle()
                    .frame(width: 16, height: 16)
                    .foregroundColor(hSignalColor.Green.element)
                hText("Hedvig AI Assistant", style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)
            }
        }
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
}

struct TextAnimation: View {
    let text: String
    @State private var visibleCharacters: Int = 0
    @State private var showDot = true
    var body: some View {
        ZStack(alignment: .leading) {
            if showDot {
                Circle()
                    .fill(hSignalColor.Green.element)
                    .frame(width: 14, height: 14)
                    .transition(.scale.combined(with: .opacity))
            }
            if #available(iOS 18.0, *) {
                hText(text)
                    .textRenderer(AnimatedTextRenderer(visibleCharacters: visibleCharacters))
                    .onAppear {
                        animateText()
                    }
            } else {
                Text(String(text.prefix(visibleCharacters)))
                    .onAppear {
                        animateText()
                    }
            }
        }
    }

    private func animateText() {
        visibleCharacters = 0
        Task {
            try? await Task.sleep(seconds: 1)
            for index in 0...text.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.03) {
                    withAnimation(.easeIn(duration: 0.1)) {
                        showDot = false
                        visibleCharacters = index
                    }
                }
            }
        }
    }
}

@available(iOS 18.0, *)
struct AnimatedTextRenderer: TextRenderer {
    let visibleCharacters: Int

    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        var characterIndex = 0

        for line in layout {
            for run in line {
                for glyph in run {
                    var glyphContext = context

                    // Calculate opacity based on proximity to visibleCharacters
                    let opacity: Double
                    if characterIndex < visibleCharacters - 1 {
                        opacity = 1.0
                    } else if characterIndex == visibleCharacters - 1 {
                        // Animate the current character
                        opacity = 1.0
                    } else if characterIndex == visibleCharacters && characterIndex != 0 {
                        // Next character starting to fade in
                        opacity = 0.3
                    } else {
                        opacity = 0.0
                    }

                    glyphContext.opacity = opacity
                    glyphContext.draw(glyph)
                    characterIndex += 1
                }
            }
        }
    }
}

#Preview {
    TextAnimation(text: "TEXT WE WANT TO SEE ANIMATED ANIMATED ANIMATE ANIMTED")
}

extension ClaimIntentStepHandler {
    var maxWidth: CGFloat {
        switch claimIntent.currentStep.content {
        case .summary, .singleSelect:
            return .infinity
        default:
            return 300
        }
    }

    var alignment: Alignment {
        if sender == .hedvig {
            switch claimIntent.currentStep.content {
            default:
                return .leading
            }
        }
        return .trailing
    }
}

extension ClaimIntentStepHandler {
    func stepView() -> some View {
        VStack {
            if let viewModel = self as? SubmitClaimAudioStep {
                SubmitClaimAudioView(viewModel: viewModel)
            } else if let viewModel = self as? SubmitClaimSingleSelectStep {
                SubmitClaimSingleSelectView(viewModel: viewModel)
            } else if let viewModel = self as? SubmitClaimFormStep {
                SubmitClaimFormView(viewModel: viewModel)
            } else if let viewModel = self as? SubmitClaimSummaryStep {
                SubmitClaimSummaryView(viewModel: viewModel)
                //            } else if let viewModel = self as? SubmitClaimTaskStep {
                //                SubmitClaimTaskView(viewModel: viewModel)
            } else if let viewModel = self as? SubmitClaimFileUploadStep {
                SubmitClaimFileUploadView(viewModel: viewModel)
            } else if let viewModel = self as? SubmitClaimUnknownStep {
                SubmitClaimUnknownView(viewModel: viewModel)
            }
            if self.isSkippable {
                hButton(.large, .ghost, content: .init(title: "Skip")) { [weak self] in
                    Task {
                        await self?.skip()
                    }
                }
                .disabled(!self.isEnabled)
                .hButtonIsLoading(false)
            }
        }
        .disabled(!self.isEnabled)
    }

    @ViewBuilder
    func resultView() -> some View {
        if self.isStepExecuted {
            //        if let viewModel = self as? SubmitClaimAudioStep {
            //            SubmitClaimAudioView(viewModel: viewModel)
            //        } else
            if let viewModel = self as? SubmitClaimSingleSelectStep {
                SubmitClaimSingleSelectResultView(viewModel: viewModel)
            } else if let viewModel = self as? SubmitClaimFormStep {
                SubmitClaimFormResultView(viewModel: viewModel)
            }
            //        else if let viewModel = self as? SubmitClaimSummaryStep {
            //            SubmitClaimSummaryView(viewModel: viewModel)
            //        } else if let viewModel = self as? SubmitClaimTaskStep {
            //            SubmitClaimTaskView(viewModel: viewModel)
            //        } else if let viewModel = self as? SubmitClaimFileUploadStep {
            //            SubmitClaimFileUploadView(viewModel: viewModel)
            //        } else if let viewModel = self as? SubmitClaimUnknownStep {
            //            SubmitClaimUnknownView(viewModel: viewModel)
            //        }
        }
    }
}
