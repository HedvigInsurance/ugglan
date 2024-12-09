import SwiftUI
import hCore
import hCoreUI

struct ConfirmTerminationScreen: View {
    @EnvironmentObject var terminationNavigationVm: TerminationFlowNavigationViewModel

    init() {}

    var body: some View {
        GenericErrorView(
            title: L10n.General.areYouSure,
            description: terminationText,
            attachContentToTheBottom: true
        )
        .hErrorViewButtonConfig(
            .init(
                actionButtonAttachedToBottom:
                    .init(
                        buttonTitle: L10n.terminationFlowConfirmButton,
                        buttonAction: {
                            terminationNavigationVm.sendConfirmTermination()
                        }
                    ),
                dismissButton: .init(
                    buttonTitle: L10n.generalCloseButton,
                    buttonAction: {
                        terminationNavigationVm.isConfirmTerminationPresented = false
                    }
                )
            )
        )
        .hExtraTopPadding
        .hDisableScroll
    }

    var terminationText: String {
        if terminationNavigationVm.isDeletion {
            return L10n.terminationFlowConfirmation
        }
        return L10n.terminationFlowConfirmationSubtitleTermination(
            terminationNavigationVm.terminationDateStepModel?.date?.displayDateDDMMMYYYYFormat ?? ""
        )
    }
}

struct TerminationDeleteScreen_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmTerminationScreen()
    }
}
