import SwiftUI
import hCore
import hCoreUI

struct MovingFlowConfirmScreen: View {
    let navigationVm: MovingFlowNavigationViewModel
    let router: NavigationRouter

    var body: some View {
        QuoteSummaryScreen(
            quoteSummary: navigationVm.createQuoteSummary(),
            onDocumentTap: { [weak navigationVm] in navigationVm?.document = $0 }
        ) { [weak navigationVm, weak router] in
            guard let navigationVm else { return }
            if navigationVm.movingFlowConfirmViewModel == nil {
                navigationVm.movingFlowConfirmViewModel = .init()
            }
            Task { [weak navigationVm] in
                guard let navigationVm,
                    let movingFlowConfirmViewModel = navigationVm.movingFlowConfirmViewModel
                else { return }
                router?.push(MovingFlowRouterWithHiddenBackButtonActions.processing)
                await movingFlowConfirmViewModel.confirmMoveIntent(
                    intentId: navigationVm.moveConfigurationModel?.id ?? "",
                    currentHomeQuoteId: navigationVm.selectedHomeQuote?.id ?? "",
                    removedAddons: navigationVm.removedAddonIds
                )
            }
        }
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

#Preview {
    let quoteSummary = QuoteSummary(
        contracts: [],
        activationDate: Date(),
        totalPrice: .comparison(
            old: .sek(399),
            new: .sek(399)
        )
    )
    Localization.Locale.currentLocale.send(.en_SE)
    return QuoteSummaryScreen(quoteSummary: quoteSummary, onDocumentTap: { _ in }) {}
}
