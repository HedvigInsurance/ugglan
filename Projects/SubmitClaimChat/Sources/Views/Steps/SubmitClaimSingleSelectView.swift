import SwiftUI
import TagKit
import hCore
import hCoreUI

struct SubmitClaimSingleSelectView: View {
    @ObservedObject var viewModel: SubmitClaimSingleSelectStep

    public var body: some View {
        hSection {
            Group {
                switch viewModel.model.style {
                case .pill: pillInputView
                case .binary: binaryInputView
                }
            }
        }
        .sectionContainerStyle(.transparent)
    }

    private var pillInputView: some View {
        TagList(tags: viewModel.model.options.map { $0.id }) { optionId in
            let option = viewModel.model.options.first(where: { $0.id == optionId })!

            hPill(
                text: option.title,
                color: .grey,
                colorLevel: .two,
                withBorder: false
            )
            .hFieldSize(.capsuleShape)
            .transition(
                .scale.animation(
                    .spring(response: 0.55, dampingFraction: 0.725, blendDuration: 1)
                        .delay(Double.random(in: 0.3...0.6))
                )
            )
            .onTapGesture { selectOption(id: option.id) }
            .optionAccessibility(label: option.title)
        }
    }

    private var binaryInputView: some View {
        HStack(spacing: 8) {
            ForEach(viewModel.model.options) { option in
                hButton(
                    .small,
                    .ghost,
                    content: .init(title: option.title)
                ) { selectOption(id: option.id) }
                .hButtonTakeFullWidth(true)
                .hPillStyle(color: .grey, colorLevel: .two)
                .hFieldSize(.capsuleShape)
                .optionAccessibility(label: option.title)
            }
        }
        .padding(.horizontal, 32)
    }

    private func selectOption(id: String) {
        ImpactGenerator.soft()
        viewModel.selectedOptionId = id
        viewModel.submitResponse()
    }
}

extension View {
    fileprivate func optionAccessibility(label: String) -> some View {
        self.accessibilityLabel(label)
            .accessibilityHint(L10n.voiceoverDoubleClickTo + " " + L10n.voiceoverOptionSelected)
            .accessibilityAddTraits(.isButton)
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
            .accessibilityLabel(option.title)
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
            isRegrettable: false
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
            isRegrettable: false
        ),
        service: .init(),
        mainHandler: { _ in }
    )
    return VStack {
        Spacer()
        SubmitClaimSingleSelectView(viewModel: viewModel)
    }
}
