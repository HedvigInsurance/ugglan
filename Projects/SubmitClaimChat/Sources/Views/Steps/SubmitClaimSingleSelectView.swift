import SwiftUI
import TagKit
import hCoreUI

struct SubmitClaimSingleSelectView: View {
    @ObservedObject var viewModel: SubmitClaimSingleSelectStep
    let animationNamespace: Namespace.ID
    public var body: some View {
        TagList(tags: viewModel.model.options.compactMap({ $0.id })) { tag in
            hPill(
                text: viewModel.model.options.first(where: { $0.id == tag })?.title ?? "",
                color: viewModel.selectedOption == tag ? .green : .grey
            )
            .onTapGesture {
                withAnimation {
                    viewModel.selectedOption = tag
                }
            }
            .matchedGeometryEffect(id: "pill.\(tag)", in: animationNamespace)
        }
        hContinueButton {
            Task {
                await viewModel.submitResponse()
            }
        }
        .disabled(viewModel.selectedOption == nil)
    }
}

struct SubmitClaimSingleSelectView2: View {
    @ObservedObject var viewModel: SubmitClaimSingleSelectStep
    let animationNamespace: Namespace.ID
    public var body: some View {
        if let tag = viewModel.selectedOption, let text = viewModel.model.options.first(where: { $0.id == tag })?.title
        {
            hPill(
                text: text,
                color: .grey
            )
            .matchedGeometryEffect(id: "pill.\(tag)", in: animationNamespace)
        }
    }
}
