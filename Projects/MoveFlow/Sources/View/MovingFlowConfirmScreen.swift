import Contracts
import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct MovingFlowConfirmScreen: View {
    @StateObject var movingFlowConfirmVm = MovingFlowConfirmViewModel()
    @EnvironmentObject var movingFlowNavigationVm: MovingFlowNavigationViewModel
    @EnvironmentObject var router: Router

    var body: some View {
        if let movingFlowModel = movingFlowNavigationVm.movingFlowVm {
            let contractInfo = getQuotes(from: movingFlowModel)
                .map({ quote in
                    QuoteSummaryViewModel.ContractInfo(
                        id: quote.id,
                        displayName: quote.displayName,
                        exposureName: quote.exposureName ?? "",
                        newPremium: quote.premium,
                        currentPremium: quote.premium,
                        documents: quote.documents.map({
                            .init(displayName: $0.displayName, url: $0.url, type: .unknown)
                        }),
                        onDocumentTap: { document in
                            movingFlowNavigationVm.document = document
                        },
                        displayItems: quote.displayItems.map({ .init(title: $0.displayTitle, value: $0.displayValue) }
                        ),
                        insuranceLimits: quote.insurableLimits,
                        typeOfContract: quote.contractType,
                        onInfoClick: quote.quoteInfo != nil
                            ? {
                                movingFlowNavigationVm.isInfoViewPresented = quote.quoteInfo
                            } : nil
                    )
                })

            let vm = QuoteSummaryViewModel(
                contract: contractInfo,
                total: movingFlowModel.total,
                onConfirmClick: {
                    Task {
                        await movingFlowConfirmVm.confirmMoveIntent(
                            intentId: movingFlowNavigationVm.movingFlowVm?.id ?? "",
                            homeQuoteId: movingFlowNavigationVm.movingFlowVm?.homeQuote?.id ?? ""
                        )
                    }
                    router.push(MovingFlowRouterWithHiddenBackButtonActions.processing(vm: movingFlowConfirmVm))
                }
            )
            QuoteSummaryScreen(vm: vm)
        }
    }

    private func getQuotes(from data: MovingFlowModel) -> [MovingFlowQuote] {
        var allQuotes = data.quotes
        if let homeQuote = data.homeQuote {
            allQuotes.insert(homeQuote, at: 0)
        }
        return allQuotes
    }
}

@MainActor
public class MovingFlowConfirmViewModel: ObservableObject, Hashable {
    nonisolated public static func == (lhs: MovingFlowConfirmViewModel, rhs: MovingFlowConfirmViewModel) -> Bool {
        return true
    }

    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    @Inject private var service: MoveFlowClient
    @Published var viewState: ProcessingState = .loading

    @MainActor
    func confirmMoveIntent(intentId: String, homeQuoteId: String) async {
        withAnimation {
            viewState = .loading
        }

        do {
            try await service.confirmMoveIntent(intentId: intentId, homeQuoteId: homeQuoteId)

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
        Dependencies.shared.add(module: Module { () -> MoveFlowClient in MoveFlowClientDemo() })
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
        Localization.Locale.currentLocale.send(.en_SE)
        return MovingFlowConfirmScreen()
            .environmentObject(Router())
            .environmentObject(MovingFlowNavigationViewModel())
    }
}
