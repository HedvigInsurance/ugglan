import EditCoInsuredShared
import SwiftUI
import hCore
import hCoreUI

struct CoInsuredProcessingScreen: View {
    @StateObject var vm = ProcessingViewModel()
    @ObservedObject var intentVm: IntentViewModel
    var showSuccessScreen: Bool
    @ObservedObject private var editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    @EnvironmentObject private var editCoInsuredViewModel: EditCoInsuredViewModel
    @StateObject var router = Router()
    init(
        showSuccessScreen: Bool,
        editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    ) {
        self.showSuccessScreen = showSuccessScreen
        self.editCoInsuredNavigation = editCoInsuredNavigation
        intentVm = editCoInsuredNavigation.intentViewModel
    }

    var body: some View {
        RouterHost(router: router, options: [.navigationBarHidden], tracking: self) {
            hProcessingView(
                showSuccessScreen: showSuccessScreen,
                EditCoInsuredStore.self,
                loading: .postCoInsured,
                loadingViewText: L10n.contractAddCoinsuredProcessing,
                successViewTitle: L10n.contractAddCoinsuredUpdatedTitle,
                successViewBody: L10n.contractAddCoinsuredUpdatedLabel(
                    intentVm.intent.activationDate.localDateToDate?.displayDateDDMMMYYYYFormat ?? ""
                ),
                onAppearLoadingView: {
                    editCoInsuredNavigation.showProgressScreenWithSuccess = false
                    editCoInsuredNavigation.showProgressScreenWithoutSuccess = false
                    editCoInsuredNavigation.editCoInsuredConfig = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak editCoInsuredViewModel] in
                        editCoInsuredViewModel?.checkForAlert()
                    }
                    EditCoInsuredViewModel.updatedCoInsuredForContractId.send(intentVm.contractId)

                },
                onErrorCancelAction: {
                    router.dismiss()
                }
            )
            .hSuccessBottomAttachedView {
                customBottomSuccessView
            }
        }
    }

    private var customBottomSuccessView: some View {
        hSection {
            hButton.LargeButton(type: .ghost) {
                editCoInsuredNavigation.showProgressScreenWithSuccess = false
                editCoInsuredNavigation.showProgressScreenWithoutSuccess = false
                editCoInsuredNavigation.editCoInsuredConfig = nil
                editCoInsuredViewModel.checkForAlert()
                EditCoInsuredViewModel.updatedCoInsuredForContractId.send(intentVm.contractId)
            } content: {
                hText(L10n.generalDoneButton)
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

extension CoInsuredProcessingScreen: TrackingViewNameProtocol {
    var nameForTracking: String {
        return .init(describing: CoInsuredProcessingScreen.self)
    }

}
class ProcessingViewModel: ObservableObject {
    @Published var progress: Float = 0
}

struct SuccessScreen_Previews: PreviewProvider {
    static var previews: some View {
        CoInsuredProcessingScreen(showSuccessScreen: true, editCoInsuredNavigation: .init(config: .init()))
    }
}
