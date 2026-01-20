import Combine
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
        Group {
            if vm.isDeletion == nil {
                HStack {
                    DotsActivityIndicator(.standard)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.top)
                .useDarkColor
            } else {
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
                            vm.titleText
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
                                        terminationNavigationVm?.router.push(TerminationFlowRouterActions.summary)
                                    }
                                    .disabled(
                                        vm.isCancelButtonDisabled(
                                            terminationDate: terminationNavigationVm.terminationDateStepModel?.date
                                        )
                                    )
                                }
                            }
                            .sectionContainerStyle(.transparent)
                        }
                        .padding(.vertical, .padding16)
                    }
            }
        }
    }

    @ViewBuilder
    private var displayTerminationDateField: some View {
        if let isDeletion = vm.isDeletion {
            if isDeletion {
                hSection {
                    VStack(spacing: 4) {
                        hFloatingField(
                            value: L10n.terminationFlowToday,
                            placeholder: L10n.terminationFlowDateFieldText,
                            onTap: {}
                        )
                        .hFieldTrailingView {
                            hCoreUIAssets.lock.view
                                .frame(width: 24, height: 24)
                        }
                        .hBackgroundOption(option: [.locked, .withoutDisabled])
                        .disabled(true)

                        InfoCard(
                            text:
                                L10n.terminationFlowDeletionInfoCard,
                            type: .info
                        )
                    }
                }
                .sectionContainerStyle(.transparent)
            } else {
                DropdownView(
                    value: terminationNavigationVm.terminationDateStepModel?.date?.displayDateDDMMMYYYYFormat
                        ?? L10n.terminationFlowDateFieldPlaceholder,
                    placeHolder: L10n.terminationFlowDateFieldText,
                    onTap: { [weak terminationNavigationVm] in
                        terminationNavigationVm?.isDatePickerPresented = true
                    }
                )
                .hFieldSize(.medium)
            }
        }
    }

    @ViewBuilder
    private var displayImportantInformation: some View {
        if terminationNavigationVm.terminationDateStepModel?.date != nil {
            ImportantInformationView(
                title: L10n.terminationFlowImportantInformationTitle,
                subtitle: L10n.terminationFlowImportantInformationText,
                confirmationMessage: L10n.terminationFlowIUnderstandText,
                isConfirmed: $vm.hasAgreedToTerms
            )
        }
    }
}

@MainActor
class SetTerminationDateLandingScreenViewModel: ObservableObject {
    @Published var isDeletion: Bool?
    @Published var hasAgreedToTerms: Bool = false
    @Published var titleText: String = ""
    private var terminationNavigationVm: TerminationFlowNavigationViewModel?
    private var cancellables = Set<AnyCancellable>()

    init(terminationNavigationVm: TerminationFlowNavigationViewModel) {
        self.terminationNavigationVm = terminationNavigationVm
        checkDeletion(for: terminationNavigationVm)
        if isDeletion == true {
            terminationNavigationVm.fetchNotification(isDeletion: true)
        }
        observeNavigationVMChanges(terminationNavigationVm)
    }

    private func observeNavigationVMChanges(_ navigationVm: TerminationFlowNavigationViewModel) {
        navigationVm.$terminationDeleteStepModel
            .combineLatest(navigationVm.$terminationDateStepModel)
            .sink { [weak self] _, _ in
                self?.checkDeletion(for: navigationVm)
                if self?.isDeletion == true {
                    navigationVm.fetchNotification(isDeletion: true)
                }
            }
            .store(in: &cancellables)
    }
    func isCancelButtonDisabled(terminationDate: Date?) -> Bool {
        let hasSetTerminationDate = terminationDate != nil
        return !(isDeletion ?? false) && (!hasSetTerminationDate || !hasAgreedToTerms)
    }

    private func checkDeletion(for terminationNavigationVm: TerminationFlowNavigationViewModel) {
        isDeletion = {
            if terminationNavigationVm.terminationDeleteStepModel != nil {
                return true
            }
            if terminationNavigationVm.terminationDateStepModel != nil {
                return false
            }
            return nil
        }()

        withAnimation {
            self.isDeletion = isDeletion
            self.titleText =
                isDeletion ?? false ? L10n.terminationFlowConfirmInformation : L10n.terminationDateText
        }
    }

    deinit {
        Task { [weak self] in
            await self?.terminationNavigationVm?.fetchNotificationTask?.cancel()
        }
    }
}

#Preview {
    SetTerminationDateLandingScreen(
        terminationNavigationVm: .init(configs: [], terminateInsuranceViewModel: nil)
    )
}
