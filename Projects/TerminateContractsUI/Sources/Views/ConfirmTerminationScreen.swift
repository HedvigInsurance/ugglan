import SwiftUI
import TerminateContractsCore
import hCore
import hCoreUI

struct ConfirmTerminationScreen: View {
    @Environment(TerminationFlowNavigationViewModel.self) var terminationNavigationVm
    @Environment(NavigationRouter.self) var router
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
                        buttonTitle: confirmButtonTitle,
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
        .hStateViewContentBottomAttachedView {
            if terminationNavigationVm.isWithdrawal, let notification = terminationNavigationVm.notification {
                TerminationNotificationCard(notification: notification)
            }
        }
        .hExtraTopPadding
    }

    var confirmButtonTitle: String {
        terminationNavigationVm.isWithdrawal
            ? L10n.terminationFlowWithdrawalConfirmButton : L10n.terminationFlowConfirmButton
    }

    var terminationText: String {
        if terminationNavigationVm.isDeletion {
            return L10n.terminationFlowConfirmation
        }

        if let selectedDate = terminationNavigationVm.selectedDate, Calendar.current.isDateInToday(selectedDate) {
            return L10n.terminationFlowConfirmationSubtitleToday(selectedDate.displayDateDDMMMYYYYFormat)
        }

        return L10n.terminationFlowConfirmationSubtitleTermination(
            terminationNavigationVm.selectedDate?.displayDateDDMMMYYYYFormat ?? ""
        )
    }
}

#Preview {
    ConfirmTerminationScreen()
        .environment(TerminationFlowNavigationViewModel(configs: [], terminateInsuranceViewModel: nil))
}
