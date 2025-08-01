import SwiftUI
import hCore
import hCoreUI

struct CoInsuredProcessingScreen: View {
    @StateObject var vm = ProcessingViewModel()
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
        ProcessingStateView(
            showSuccessScreen: showSuccessScreen,
            loadingViewText: L10n.contractAddCoinsuredProcessing,
            successViewTitle: L10n.contractAddCoinsuredUpdatedTitle,
            successViewBody: L10n.contractAddCoinsuredUpdatedLabel(
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

@MainActor
class ProcessingViewModel: ObservableObject {
    @Published var progress: Float = 0
}

struct SuccessScreen_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
        let existingCoInsured = (any ExistingCoInsured).self
        return CoInsuredProcessingScreen(
            showSuccessScreen: true,
            intentVM: .init()
        )
        .environmentObject(EditCoInsuredNavigationViewModel(config: .init()))
        .environmentObject(EditCoInsuredViewModel(existingCoInsured: existingCoInsured as! ExistingCoInsured))
    }
}
