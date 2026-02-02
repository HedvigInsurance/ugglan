import SwiftUI
import TagKit
import hCore
import hCoreUI

struct SubmitClaimSingleSelectView: View {
    @ObservedObject var viewModel: SubmitClaimSingleSelectStep
    @State private var showOptions = false

    public var body: some View {
        hSection {
            VStack(spacing: .padding16) {
                switch viewModel.model.style {
                case .pill: pillInputView
                case .binary: binaryInputView
                }
                hButton(
                    .large,
                    .primary,
                    content: .init(title: L10n.generalConfirm)
                ) {
                    viewModel.submitResponse()
                }
                .opacity(showOptions ? 1 : 0)
                .animation(.easeInOut, value: showOptions)
                .disabled(viewModel.selectedOptionId == nil)
            }
        }
        .sectionContainerStyle(.transparent)
        .animation(.easeInOut, value: viewModel.selectedOptionId)
        .task {
            try? await Task.sleep(seconds: ClaimChatConstants.Timing.optionReveal)
            showOptions = true
        }
    }

    private var pillInputView: some View {
        TagList(tags: viewModel.model.options.map { $0.id }) { optionId in
            let option = viewModel.model.options.first(where: { $0.id == optionId })!
            if showOptions {
                hPill(
                    text: option.title,
                    color: viewModel.selectedOptionId == optionId ? .green : .grey,
                    colorLevel: .two,
                    withBorder: false
                )
                .hFieldSize(.capsuleShape)
                .transition(.submitClaimOptionAppear)
                .onTapGesture { selectOption(id: option.id) }
                .accessibilityAddTraits(.isButton)
                .optionAccessibility(label: option.title)
            }
        }
    }

    private var binaryInputView: some View {
        HStack(spacing: 8) {
            ForEach(viewModel.model.options) { option in
                if showOptions {
                    hButton(
                        .medium,
                        .ghost,
                        content: .init(title: option.title)
                    ) {
                        selectOption(id: option.id)
                    }
                    .hCustomButtonView {
                        hText(option.title, style: .body1)
                            .foregroundColor(pillColor(optionId: option.id).pillTextColor(level: .two))
                    }
                    .hWrapInPill(color: viewModel.selectedOptionId == option.id ? .green : .grey, colorLevel: .two)
                    .hButtonTakeFullWidth(true)
                    .optionAccessibility(label: option.title)
                    .transition(.submitClaimOptionAppear)
                    .accessibilityAddTraits(.isButton)
                    .optionAccessibility(label: option.title)
                }
            }
        }
    }

    private func pillColor(optionId: String) -> PillColor {
        if optionId == viewModel.selectedOptionId {
            return PillColor.green
        } else {
            return PillColor.grey
        }
    }

    private func selectOption(id: String) {
        ImpactGenerator.soft()
        viewModel.selectedOptionId = id
    }
}

extension View {
    fileprivate func optionAccessibility(label: String) -> some View {
        self.accessibilityLabel(label)
            .accessibilityHint(L10n.voiceoverDoubleClickTo + " " + L10n.voiceoverOptionSelected)
            .accessibilityAddTraits(.isButton)
    }
}

extension AnyTransition {
    fileprivate static var submitClaimOptionAppear: AnyTransition {
        .scale.animation(
            .spring(response: 0.55, dampingFraction: 0.725, blendDuration: 1)
                .delay(Double.random(in: 0.3...0.6))
        )
    }
}

struct SubmitClaimSingleSelectResultView: View {
    @ObservedObject var viewModel: SubmitClaimSingleSelectStep
    var body: some View {
        if let id = viewModel.selectedOptionId, let option = viewModel.model.options.first(where: { $0.id == id }) {
            hPill(
                text: option.title,
                color: .grey,
                colorLevel: .two,
                withBorder: false
            )
            .hFieldSize(.capsuleShape)
        }
    }
}

#Preview(".pill") {
    let viewModel = SubmitClaimSingleSelectStep(
        claimIntent: .init(
            currentStep: .init(
                content: .singleSelect(
                    model: .init(
                        defaultSelectedId: nil,
                        options: [
                            .init(id: "1", title: "Option 1"),
                            .init(id: "2", title: "Option 2"),
                            .init(id: "3", title: "Option 3"),
                            .init(id: "4", title: "Longer Option "),
                            .init(id: "5", title: "Short"),
                        ],
                        style: .pill
                    )
                ),
                id: "step1",
                text: "Select an option"
            ),
            id: "intent1",
            isSkippable: true,
            isRegrettable: false,
            progress: 0
        ),
        service: .init(),
        mainHandler: { _ in }
    )
    return VStack {
        Spacer()
        SubmitClaimSingleSelectView(viewModel: viewModel)
    }
}

#Preview(".binary") {
    let viewModel = SubmitClaimSingleSelectStep(
        claimIntent: .init(
            currentStep: .init(
                content: .singleSelect(
                    model: .init(
                        defaultSelectedId: nil,
                        options: [
                            .init(id: "yes", title: "Yes"),
                            .init(id: "no", title: "No"),
                        ],
                        style: .binary
                    )
                ),
                id: "step1",
                text: "Is this correct?"
            ),
            id: "intent1",
            isSkippable: false,
            isRegrettable: false,
            progress: 0
        ),
        service: .init(),
        mainHandler: { _ in }
    )
    return VStack {
        Spacer()
        SubmitClaimSingleSelectView(viewModel: viewModel)
    }
}
