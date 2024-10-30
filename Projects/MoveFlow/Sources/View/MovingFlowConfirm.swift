import Contracts
import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct MovingFlowConfirm: View {
    @EnvironmentObject var movingFlowConfirmVm: MovingFlowConfirmViewModel
    @EnvironmentObject var movingFlowNavigationVm: MovingFlowNavigationViewModel
    @EnvironmentObject var router: Router

    var body: some View {
        if let movingFlowModel = movingFlowNavigationVm.movingFlowVm {
            let contractInfo = getQuotes(from: movingFlowModel)
                .map({
                    QuoteSummaryViewModel.ContractInfo(
                        id: $0.id,
                        displayName: $0.displayName,
                        exposureName: $0.exposureName ?? "",
                        newPremium: $0.premium,
                        currentPremium: $0.premium,
                        documents: $0.documents.map({
                            .init(displayName: $0.displayName, url: $0.url, type: .unknown)
                        }),
                        onDocumentTap: { document in
                            movingFlowNavigationVm.document = document
                        },
                        displayItems: $0.displayItems.map({ .init(title: $0.displayTitle, value: $0.displayValue) }
                        ),
                        insuranceLimits: $0.insurableLimits,
                        typeOfContract: $0.contractType
                    )
                })

            let vm = QuoteSummaryViewModel(
                contract: contractInfo,
                total: movingFlowModel.total,
                FAQModel: (
                    title: L10n.changeAddressQa, subtitle: L10n.changeAddressFaqSubtitle,
                    questions: movingFlowModel.faqs.map({ .init(title: $0.title, description: $0.description) })
                ),
                onConfirmClick: {
                    Task {
                        await movingFlowConfirmVm.confirmMoveIntent(
                            intentId: movingFlowNavigationVm.movingFlowVm?.id ?? "",
                            homeQuoteId: movingFlowNavigationVm.movingFlowVm?.homeQuote?.id ?? ""
                        )
                    }
                    router.push(MovingFlowRouterWithHiddenBackButtonActions.processing)
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

public class MovingFlowConfirmViewModel: ObservableObject {
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
        return MovingFlowConfirm()
            .environmentObject(Router())
            .environmentObject(MovingFlowNavigationViewModel())
    }
}
