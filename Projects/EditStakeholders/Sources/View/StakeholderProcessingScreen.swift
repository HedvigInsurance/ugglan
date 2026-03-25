import SwiftUI
import hCore
import hCoreUI

struct StakeholderProcessingScreen: View {
    var showSuccessScreen: Bool
    @EnvironmentObject private var editStakeholdersNavigation: EditStakeholdersNavigationViewModel
    @EnvironmentObject private var editStakeholdersViewModel: EditStakeholdersViewModel
    @ObservedObject private var intentViewModel: IntentViewModel
    private let router = Router()
    init(
        showSuccessScreen: Bool,
        intentVM: IntentViewModel
    ) {
        intentViewModel = intentVM
        self.showSuccessScreen = showSuccessScreen
    }

    var body: some View {
        let stakeholderType = editStakeholdersNavigation.stakeholderViewModel.config.stakeholderType
        ProcessingStateView(
            showSuccessScreen: showSuccessScreen,
            loadingViewText: stakeholderType.processingText,
            successViewTitle: stakeholderType.updatedTitle,
            successViewBody: stakeholderType.updatedLabel(
                intentViewModel.intent.activationDate.localDateToDate?
                    .displayDateDDMMMYYYYFormat ?? ""
            ),
            successViewButtonAction: nil,
            onAppearLoadingView: {
                editStakeholdersNavigation.showProgressScreenWithSuccess = false
                editStakeholdersNavigation.showProgressScreenWithoutSuccess = false
                editStakeholdersNavigation.editStakeholderConfig = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak editStakeholdersViewModel] in
                    editStakeholdersViewModel?.checkForAlert(excludingContractId: intentViewModel.contractId)
                }
                EditStakeholdersViewModel.updatedStakeholderForContractId.send(
                    intentViewModel.contractId
                )
            },
            state: $intentViewModel.viewState
        )
        .hSuccessBottomAttachedView {
            customBottomSuccessView
        }
        .hStateViewButtonConfig(errorButtons)
        .embededInNavigation(router: router, options: [.navigationBarHidden], tracking: self)
    }

    private var errorButtons: StateViewButtonConfig {
        .init(
            dismissButton: .init(
                buttonTitle: L10n.generalCancelButton,
                buttonAction: {
                    router.dismiss()
                }
            )
        )
    }

    private var customBottomSuccessView: some View {
        hSection {
            hButton(
                .large,
                .ghost,
                content: .init(title: L10n.generalDoneButton),
                {
                    editStakeholdersNavigation.showProgressScreenWithSuccess = false
                    editStakeholdersNavigation.showProgressScreenWithoutSuccess = false
                    editStakeholdersNavigation.editStakeholderConfig = nil
                    editStakeholdersViewModel.checkForAlert(excludingContractId: intentViewModel.contractId)
                    EditStakeholdersViewModel.updatedStakeholderForContractId.send(
                        intentViewModel.contractId
                    )
                }
            )
        }
        .sectionContainerStyle(.transparent)
    }
}

extension StakeholderProcessingScreen: TrackingViewNameProtocol {
    var nameForTracking: String {
        editStakeholdersNavigation.stakeholderViewModel.config.stakeholderType.trackingName(for: "ProcessingScreen")
    }
}

#Preview {
    Dependencies.shared.add(module: Module { DateService() })
    struct MockExistingStakeholders: ExistingStakeholders {
        func get(contractId: String, stakeholderType: StakeholderType) -> [Stakeholder] { [] }
    }
    return StakeholderProcessingScreen(
        showSuccessScreen: true,
        intentVM: .init()
    )
    .environmentObject(EditStakeholdersNavigationViewModel(config: .init(stakeholderType: .coInsured)))
    .environmentObject(EditStakeholdersViewModel(existingStakeholders: MockExistingStakeholders()))
}
