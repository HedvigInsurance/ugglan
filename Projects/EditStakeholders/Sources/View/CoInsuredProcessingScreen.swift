import SwiftUI
import hCore
import hCoreUI

struct CoInsuredProcessingScreen: View {
    var showSuccessScreen: Bool
    @EnvironmentObject private var editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    @EnvironmentObject private var editCoInsuredViewModel: EditCoInsuredViewModel
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
        let stakeHolderType = editCoInsuredNavigation.coInsuredViewModel.config.stakeHolderType
        ProcessingStateView(
            showSuccessScreen: showSuccessScreen,
            loadingViewText: stakeHolderType.processingText,
            successViewTitle: stakeHolderType.updatedTitle,
            successViewBody: stakeHolderType.updatedLabel(
                intentViewModel.intent.activationDate.localDateToDate?
                    .displayDateDDMMMYYYYFormat ?? ""
            ),
            successViewButtonAction: nil,
            onAppearLoadingView: {
                editCoInsuredNavigation.showProgressScreenWithSuccess = false
                editCoInsuredNavigation.showProgressScreenWithoutSuccess = false
                editCoInsuredNavigation.editCoInsuredConfig = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak editCoInsuredViewModel] in
                    editCoInsuredViewModel?.checkForAlert(excludingContractId: intentViewModel.contractId)
                }
                EditCoInsuredViewModel.updatedCoInsuredForContractId.send(
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
                    editCoInsuredNavigation.showProgressScreenWithSuccess = false
                    editCoInsuredNavigation.showProgressScreenWithoutSuccess = false
                    editCoInsuredNavigation.editCoInsuredConfig = nil
                    editCoInsuredViewModel.checkForAlert(excludingContractId: intentViewModel.contractId)
                    EditCoInsuredViewModel.updatedCoInsuredForContractId.send(
                        intentViewModel.contractId
                    )
                }
            )
        }
        .sectionContainerStyle(.transparent)
    }
}

extension CoInsuredProcessingScreen: TrackingViewNameProtocol {
    var nameForTracking: String {
        .init(describing: CoInsuredProcessingScreen.self)
    }
}

#Preview {
    Dependencies.shared.add(module: Module { DateService() })
    struct MockExistingStakeHolders: ExistingStakeHolders {
        func get(contractId: String, stakeHolderType: StakeHolderType) -> [StakeHolder] { [] }
    }
    return CoInsuredProcessingScreen(
        showSuccessScreen: true,
        intentVM: .init()
    )
    .environmentObject(EditCoInsuredNavigationViewModel(config: .init(stakeHolderType: .coInsured)))
    .environmentObject(EditCoInsuredViewModel(existingStakeHolders: MockExistingStakeHolders()))
}
