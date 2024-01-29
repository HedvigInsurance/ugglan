import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct MovingFlowProcessingView: View {
    @StateObject var vm = ProcessingViewModel()
    var body: some View {
        ProcessingView<MoveFlowStore, EmptyView>(
            MoveFlowStore.self,
            loading: .confirmMoveIntent,
            loadingViewText: L10n.changeAddressMakingChanges,
            successViewTitle: L10n.changeAddressSuccessTitle,
            successViewBody: L10n.changeAddressSuccessSubtitle(vm.store.state.movingFlowModel?.movingDate ?? ""),
            successViewButtonAction: {
                vm.store.send(.navigation(action: .dismissMovingFlow))
            },
            errorViewButtons:
                .init(
                    actionButton: .init(buttonAction: {
                        vm.store.send(.navigation(action: .goBack))
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
        Localization.Locale.currentLocale = .sv_SE
        return MovingFlowProcessingView()
    }
}
