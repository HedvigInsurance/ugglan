import SwiftUI
import hCore
import hCoreUI

struct ConfirmTerminationScreen: View {
    @EnvironmentObject var terminationNavigationVm: TerminationFlowNavigationViewModel
    @EnvironmentObject var router: NavigationRouter
    init() {}

    var body: some View {
        GenericErrorView(
            title: L10n.General.areYouSure,
            description: terminationText,
            formPosition: .compact,
            attachContentToBottom: true
        )
        .hStateViewButtonConfig(
            .init(
                actionButtonAttachedToBottom:
                    .init(
                        buttonTitle: L10n.terminationFlowConfirmButton,
                        buttonAction: {
                            terminationNavigationVm.submitTermination()
                            router.dismiss()
                        }
                    ),
                dismissButton: .init(
                    buttonTitle: L10n.alertCancel,
                    buttonAction: {
                        router.dismiss()
                    }
                )
            )
        )
        .hExtraTopPadding
    }

    var terminationText: String {
        if terminationNavigationVm.isDeletion {
            return L10n.terminationFlowConfirmation
        }
        return L10n.terminationFlowConfirmationSubtitleTermination(
            terminationNavigationVm.selectedDate?.displayDateDDMMMYYYYFormat ?? ""
        )
    }
}

#Preview {
    ConfirmTerminationScreen()
        .environmentObject(TerminationFlowNavigationViewModel(configs: [], terminateInsuranceViewModel: nil))
}
