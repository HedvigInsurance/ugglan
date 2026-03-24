import SwiftUI
import hCore
import hCoreUI

struct SetTerminationDateLandingScreen: View {
    @ObservedObject var vm: SetTerminationDateLandingScreenViewModel
    @ObservedObject var terminationNavigationVm: TerminationFlowNavigationViewModel

    init(
        terminationNavigationVm: TerminationFlowNavigationViewModel
    ) {
        self.vm = .init(terminationNavigationVm: terminationNavigationVm)
        self.terminationNavigationVm = terminationNavigationVm
    }

    var body: some View {
        hForm {}
            .hFormTitle(
                title: .init(
                    .small,
                    .heading2,
                    L10n.terminationFlowCancellationTitle,
                    alignment: .leading
                ),
                subTitle: .init(
                    .small,
                    .heading2,
                    L10n.terminationDateText
                )
            )
            .hFormAttachToBottom {
                VStack(spacing: .padding16) {
                    VStack(spacing: .padding4) {
                        displayTerminationDateField
                        displayImportantInformation
                    }

                    hSection {
                        VStack(spacing: .padding16) {
                            hContinueButton {
                                [weak terminationNavigationVm] in
                                terminationNavigationVm?.router.push(TerminationFlowRouterActions.confirmation)
                            }
                            .disabled(
                                vm.isCancelButtonDisabled(
                                    terminationDate: terminationNavigationVm.selectedDate
                                )
                            )
                        }
                    }
                    .sectionContainerStyle(.transparent)
                }
                .padding(.vertical, .padding16)
            }
    }

    @ViewBuilder
    private var displayTerminationDateField: some View {
        DropdownView(
            value: terminationNavigationVm.selectedDate?.displayDateDDMMMYYYYFormat
                ?? L10n.terminationFlowDateFieldPlaceholder,
            placeHolder: L10n.terminationFlowDateFieldText,
            onTap: { [weak terminationNavigationVm] in
                terminationNavigationVm?.isDatePickerPresented = true
            }
        )
        .hFieldSize(.medium)
    }

    @ViewBuilder
    private var displayImportantInformation: some View {
        if terminationNavigationVm.selectedDate != nil {
            hSection {
                ImportantInformationView(
                    title: L10n.terminationFlowImportantInformationTitle,
                    subtitle: L10n.terminationFlowImportantInformationText,
                    confirmationMessage: L10n.terminationFlowIUnderstandText,
                    isConfirmed: $vm.hasAgreedToTerms
                )
            }
            .sectionContainerStyle(.transparent)
        }
    }
}

@MainActor
class SetTerminationDateLandingScreenViewModel: ObservableObject {
    @Published var hasAgreedToTerms: Bool = false

    init(terminationNavigationVm: TerminationFlowNavigationViewModel) {}

    func isCancelButtonDisabled(terminationDate: Date?) -> Bool {
        let hasSetTerminationDate = terminationDate != nil
        return !hasSetTerminationDate || !hasAgreedToTerms
    }
}

#Preview {
    SetTerminationDateLandingScreen(
        terminationNavigationVm: .init(configs: [], terminateInsuranceViewModel: nil)
    )
}
