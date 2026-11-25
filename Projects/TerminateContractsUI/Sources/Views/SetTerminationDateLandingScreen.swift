import SwiftUI
import TerminateContractsCore
import hCore
import hCoreUI

struct SetTerminationDateLandingScreen: View {
    @State var vm = SetTerminationDateLandingScreenViewModel()
    let terminationNavigationVm: TerminationFlowNavigationViewModel

    init(
        terminationNavigationVm: TerminationFlowNavigationViewModel
    ) {
        self.terminationNavigationVm = terminationNavigationVm
    }

    private var isDeletion: Bool {
        terminationNavigationVm.isDeletion
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
                    if isDeletion {
                        displayDeletionDateField
                    } else {
                        VStack(spacing: .padding4) {
                            displayTerminationDateField
                            displayImportantInformation
                        }
                    }

                    hSection {
                        VStack(spacing: .padding16) {
                            hContinueButton {
                                terminationNavigationVm.router.push(TerminationFlowRouterActions.confirmation)
                            }
                            .disabled(
                                isDeletion
                                    ? false
                                    : vm.isCancelButtonDisabled(
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
    private var displayDeletionDateField: some View {
        hSection {
            VStack(spacing: 4) {
                LockedTerminationField(value: L10n.terminationFlowToday)

                InfoCard(
                    text: L10n.terminationFlowDeletionInfoCard,
                    type: .info
                )
            }
        }
        .sectionContainerStyle(.transparent)
    }

    @ViewBuilder
    private var displayTerminationDateField: some View {
        DropdownView(
            value: terminationNavigationVm.selectedDate?.displayDateDDMMMYYYYFormat
                ?? L10n.terminationFlowDateFieldPlaceholder,
            placeHolder: L10n.terminationFlowDateFieldText,
            onTap: { [weak terminationNavigationVm] in terminationNavigationVm?.isDatePickerPresented = true }
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

/// Termination date the member can't change, e.g. a deletion (today) or a withdrawal (date set by the backend).
struct LockedTerminationField: View {
    let value: String
    var placeholder: String = L10n.terminationFlowDateFieldText

    var body: some View {
        hFloatingField(
            value: value,
            placeholder: placeholder,
            onTap: {}
        )
        .hFieldTrailingView {
            hCoreUIAssets.lock.view
                .foregroundColor(hTextColor.Opaque.tertiary)
                .frame(width: 24, height: 24)
        }
        .hBackgroundOption(option: [.locked, .withoutDisabled])
        .disabled(true)
    }
}

@MainActor
@Observable
class SetTerminationDateLandingScreenViewModel {
    var hasAgreedToTerms: Bool = false

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
