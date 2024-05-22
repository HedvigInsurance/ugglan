import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct MovingFlowProcessingView: View {
    @StateObject var vm = ProcessingViewModel()
    var onSuccessButtonAction: () -> Void
    var onErrorButtonAction: () -> Void

    var body: some View {
        ProcessingView<MoveFlowStore>(
            MoveFlowStore.self,
            loading: .confirmMoveIntent,
            loadingViewText: L10n.changeAddressMakingChanges,
            successViewTitle: L10n.changeAddressSuccessTitle,
            successViewBody: L10n.changeAddressSuccessSubtitle(vm.store.state.movingFlowModel?.movingDate ?? ""),
            successViewButtonAction: {
                onSuccessButtonAction()
            },
            errorViewButtons:
                .init(
                    actionButton: .init(buttonAction: {
                        onErrorButtonAction()
                    }),
                    dismissButton: nil
                )
        )
    }
}

class ProcessingViewModel: ObservableObject {
    @PresentableStore var store: MoveFlowStore

}

struct SuccessScreen_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale.value = .sv_SE
        return MovingFlowProcessingView(onSuccessButtonAction: {}, onErrorButtonAction: {})
    }
}
