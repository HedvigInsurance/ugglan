import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimInformationView: View {
    @ObservedObject var viewModel: SubmitClaimInformationStep

    var body: some View {
        hSection {
            hButton(
                .large,
                .primary,
                content: .init(title: viewModel.informationModel.buttonTitle)
            ) { [weak viewModel] in
                viewModel?.submitResponse()
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

struct SubmitClaimInformationResultView: View {
    @ObservedObject var viewModel: SubmitClaimInformationStep

    var body: some View {
        hText(viewModel.informationModel.buttonTitle)
            .foregroundColor(hTextColor.Opaque.primary)
            .hPillStyle(color: .grey, colorLevel: .two)
            .hFieldSize(.extraLarge)
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
            .accessibilityLabel(viewModel.informationModel.buttonTitle)
    }
}
