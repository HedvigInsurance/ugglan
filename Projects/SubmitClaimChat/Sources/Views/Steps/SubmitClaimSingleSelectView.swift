import SwiftUI
import TagKit
import hCore
import hCoreUI

struct SubmitClaimSingleSelectView: View {
    @ObservedObject var viewModel: SubmitClaimSingleSelectStep
    @State var showPills = false
    public var body: some View {
        hSection {
            TagList(tags: viewModel.model.options.compactMap({ $0.id })) { tag in
                if showPills {
                    let optionTitle = viewModel.model.options.first(where: { $0.id == tag })?.title ?? ""
                    hPill(
                        text: optionTitle,
                        color: .grey
                    )
                    .hFieldSize(.capsuleShape)
                    .transition(
                        .scale.animation(
                            .spring(response: 0.55, dampingFraction: 0.725, blendDuration: 1)
                                .delay(Double.random(in: 0.3...0.6))
                        )
                    )
                    .onTapGesture {
                        ImpactGenerator.soft()
                        viewModel.selectedOption = tag
                        viewModel.submitResponse()
                    }
                    .accessibilityLabel(optionTitle)
                    .accessibilityHint(L10n.voiceoverDoubleClickTo + " " + L10n.voiceoverOptionSelected)
                    .accessibilityAddTraits(.isButton)
                }
            }
        }
        .sectionContainerStyle(.transparent)
        .task {
            try? await Task.sleep(seconds: 0.2)
            showPills = true
        }
    }
}

struct SubmitClaimSingleSelectResultView: View {
    @ObservedObject var viewModel: SubmitClaimSingleSelectStep
    var body: some View {
        if let tag = viewModel.selectedOption, let text = viewModel.model.options.first(where: { $0.id == tag })?.title
        {
            hPill(
                text: text,
                color: .grey
            )
            .hFieldSize(.capsuleShape)
            .accessibilityLabel(text)
        }
    }
}
