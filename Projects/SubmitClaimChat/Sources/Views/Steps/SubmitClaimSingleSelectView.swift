import SwiftUI
import TagKit
import hCoreUI

struct SubmitClaimSingleSelectView: View {
    @ObservedObject var viewModel: SubmitClaimSingleSelectStep
    public var body: some View {
        hSection {
            TagList(tags: viewModel.model.options.compactMap({ $0.id })) { tag in
                hPill(
                    text: viewModel.model.options.first(where: { $0.id == tag })?.title ?? "",
                    color: .grey
                )
                .onTapGesture {
                    withAnimation {
                        viewModel.selectedOption = tag
                        viewModel.submitResponse()
                    }
                }
            }
        }
        .sectionContainerStyle(.transparent)
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
        }
    }
}
