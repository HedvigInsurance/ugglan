import SwiftUI
import TerminateContractsCore
import hCore
import hCoreUI

/// Lets the member choose between withdrawing (right of withdrawal, no survey) and a regular cancellation.
struct TerminationWithdrawalChoiceScreen: View {
    @Environment(TerminationFlowNavigationViewModel.self) var terminationNavigationVm
    @State private var selected: String?

    var body: some View {
        hForm {
            hSection {
                VStack(spacing: .padding4) {
                    ForEach(WithdrawalChoice.allCases) { choice in
                        hRadioField(
                            id: choice.id,
                            itemModel: .init(title: choice.title, subTitle: choice.subtitle),
                            leftView: nil,
                            selected: $selected
                        )
                        .hFieldSize(.medium)
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormTitle(
            title: .init(
                .small,
                .body2,
                L10n.terminationFlowChoiceTitle,
                alignment: .leading
            ),
            subTitle: .init(
                .small,
                .body2,
                L10n.terminationFlowChoiceSubtitle
            )
        )
        .hFormContentPosition(.bottom)
        .hFormAlwaysAttachToBottom {
            hSection {
                hContinueButton {
                    continueClicked()
                }
                .disabled(selectedChoice == nil)
                .hButtonIsLoading(terminationNavigationVm.fetchingSurvey)
                .accessibilityHint(
                    selectedChoice.map { L10n.voiceoverOptionSelected + $0.title }
                        ?? L10n.voiceoverPickerInfo(L10n.generalContinueButton)
                )
            }
            .sectionContainerStyle(.transparent)
        }
        .disabled(terminationNavigationVm.fetchingSurvey)
    }

    private var selectedChoice: WithdrawalChoice? {
        WithdrawalChoice(rawValue: selected ?? "")
    }

    private func continueClicked() {
        guard let selectedChoice else { return }
        Task { [weak terminationNavigationVm] in
            switch selectedChoice {
            case .withdrawal:
                await terminationNavigationVm?.startWithdrawal()
            case .cancellation:
                await terminationNavigationVm?.startTermination()
            }
        }
    }
}

private enum WithdrawalChoice: String, CaseIterable, Identifiable {
    case withdrawal
    case cancellation

    var id: String { rawValue }

    var title: String {
        switch self {
        case .withdrawal: return L10n.terminationFlowWithdrawalButton
        case .cancellation: return L10n.terminationButton
        }
    }

    var subtitle: String {
        switch self {
        case .withdrawal: return L10n.terminationFlowChoiceWithdrawalSubtitle
        case .cancellation: return L10n.terminationFlowChoiceCancellationSubtitle
        }
    }
}

#Preview {
    TerminationWithdrawalChoiceScreen()
        .environment(
            TerminationFlowNavigationViewModel(
                withdrawalChoiceFor: .init(
                    contractId: "contractId",
                    contractDisplayName: "Home insurance",
                    contractExposureName: "Street 1",
                    activeFrom: nil,
                    typeOfContract: nil,
                    supportsWithdrawal: true
                ),
                terminateInsuranceViewModel: nil
            )
        )
}
