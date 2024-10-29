import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct MovingFlowProcessingView: View {
    @StateObject var vm = ProcessingViewModel()
    @EnvironmentObject var movingFlowNavigationVm: MovingFlowNavigationViewModel
    var onSuccessButtonAction: () -> Void
    var onErrorButtonAction: () -> Void

    var body: some View {
        ProcessingStateView(
            loadingViewText: L10n.changeAddressMakingChanges,
            successViewTitle: L10n.changeAddressSuccessTitle,
            successViewBody: L10n.changeAddressSuccessSubtitle(movingFlowNavigationVm.movingFlowVm?.movingDate ?? ""),
            successViewButtonAction: {
                onSuccessButtonAction()
            },
            errorViewButtons:
                .init(
                    actionButton: .init(buttonAction: {
                        onErrorButtonAction()
                    }),
                    dismissButton: nil
                ),
            state: $vm.viewState,
            duration: 6
        )
    }
}

class ProcessingViewModel: ObservableObject {
    @Published var viewState: ProcessingState = .loading
}

struct SuccessScreen_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale.send(.sv_SE)
        return MovingFlowProcessingView(onSuccessButtonAction: {}, onErrorButtonAction: {})
    }
}
