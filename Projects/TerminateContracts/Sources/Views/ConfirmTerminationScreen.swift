import SwiftUI
import hCore
import hCoreUI

struct ConfirmTerminationScreen: View {
    @State private var isHidden = false
    @EnvironmentObject var terminationNavigationVm: TerminationFlowNavigationViewModel
    @EnvironmentObject var confirmTerminationVm: ConfirmTerminationViewModel

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
                            if terminationNavigationVm.isDeletion {
                                terminationNavigationVm.sendConfirmDelete(
                                    context: terminationNavigationVm.currentContext ?? "",
                                    model: terminationNavigationVm.terminationDeleteStepModel
                                )
                            } else {
                                terminationNavigationVm.sendTerminationDate(
                                    inputDateToString: terminationNavigationVm.terminationDateStepModel?.date?
                                        .localDateString ?? "",
                                    context: terminationNavigationVm.currentContext ?? ""
                                )
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.isHidden = true
                            }
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
        .hide($isHidden)
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

class ConfirmTerminationViewModel: ObservableObject {
    @Inject private var service: TerminateContractsClient
}

struct TerminationDeleteScreen_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmTerminationScreen()
    }
}
