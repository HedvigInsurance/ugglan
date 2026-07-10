import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimInformationResultView: View {
    @ObservedObject var viewModel: SubmitClaimInformationStep

    var body: some View {
        InfoCard(
            text: viewModel.informationModel.notice,
            type: viewModel.informationModel.severity == .critical ? .error : .info
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityNotice)
    }

    // Convey the severity to VoiceOver users, since the card color alone doesn't
    private var accessibilityNotice: String {
        let model = viewModel.informationModel
        return model.severity == .critical
            ? L10n.terminationFlowImportantInformationTitle + ": " + model.notice
            : model.notice
    }
}

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
            .hButtonIsLoading(viewModel.state.isLoading)
            .accessibilityHint(L10n.generalContinueButton)
        }
        .sectionContainerStyle(.transparent)
    }
}

#Preview{
    let demo = ClaimIntentClientDemo()
    Dependencies.shared.add(module: Module { () -> ClaimIntentClient in demo })
    let criticalStep = SubmitClaimInformationStep(
        claimIntent: .init(
            currentStep: .init(
                content: .information(
                    model: .init(
                        notice:
                            "Since your home is currently uninhabitable and you have nowhere to stay, please contact "
                            + "us immediately or seek temporary emergency accommodation.",
                        severity: .critical,
                        buttonTitle: "I understand"
                    )
                ),
                id: "step-id-critical",
                text: nil
            ),
            id: "intent-id",
            isSkippable: false,
            isRegrettable: false,
            progress: 0.8
        ),
        service: ClaimIntentService()
    ) { _ in
    }
    let infoStep = SubmitClaimInformationStep(
        claimIntent: .init(
            currentStep: .init(
                content: .information(
                    model: .init(
                        notice: "Your claim will be handled within 24 hours.",
                        severity: .info,
                        buttonTitle: "I understand"
                    )
                ),
                id: "step-id-info",
                text: nil
            ),
            id: "intent-id",
            isSkippable: false,
            isRegrettable: false,
            progress: 0.8
        ),
        service: ClaimIntentService()
    ) { _ in
    }
    return VStack(spacing: .padding16) {
        SubmitClaimInformationResultView(viewModel: criticalStep)
        SubmitClaimInformationResultView(viewModel: infoStep)
        SubmitClaimInformationView(viewModel: infoStep)
    }
    .padding(.horizontal, .padding16)
}
