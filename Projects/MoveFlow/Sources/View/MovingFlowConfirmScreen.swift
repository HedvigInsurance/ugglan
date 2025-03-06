import Contracts
import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct MovingFlowConfirmScreen: View {
    let quoteSummaryViewModel: QuoteSummaryViewModel
    var body: some View {
        QuoteSummaryScreen(vm: quoteSummaryViewModel)
            .hAccessibilityWithoutCombinedElements
    }
}

@MainActor
public class MovingFlowConfirmViewModel: ObservableObject {

    @Inject private var service: MoveFlowClient
    @Published var viewState: ProcessingState = .loading

    @MainActor
    func confirmMoveIntent(intentId: String, currentHomeQuoteId: String, removedAddons: [String]) async {
        withAnimation {
            viewState = .loading
        }

        do {
            try await service.confirmMoveIntent(
                intentId: intentId,
                currentHomeQuoteId: currentHomeQuoteId,
                removedAddons: removedAddons
            )

            withAnimation {
                viewState = .success
            }
        } catch let exception {
            withAnimation {
                self.viewState = .error(errorMessage: exception.localizedDescription)
            }
        }
    }
}

struct MovingFlowConfirm_Previews: PreviewProvider {
    static var previews: some View {
        let model = QuoteSummaryViewModel(
            contract: [],
            isAddon: false
        ) {

        }
        Localization.Locale.currentLocale.send(.en_SE)
        return MovingFlowConfirmScreen(quoteSummaryViewModel: model)
    }
}
