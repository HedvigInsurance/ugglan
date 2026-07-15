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
        hSection {
            InfoCard(
                text: viewModel.informationModel.notice,
                type: viewModel.informationModel.severity.notificationType
            )
        }
        .sectionContainerStyle(.transparent)
    }
}

extension ClaimIntentStepContentInformationSeverity {
    var notificationType: NotificationType {
        switch self {
        case .info:
            return .neutral
        case .critical:
            return .error
        }
    }
}
