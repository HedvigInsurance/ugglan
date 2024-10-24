import Contracts
import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct MovingFlowConfirm: View {
    @PresentableStore var store: MoveFlowStore
    @EnvironmentObject var movingFlowNavigationVm: MovingFlowNavigationViewModel
    @EnvironmentObject var router: Router

    var body: some View {
        PresentableStoreLens(
            MoveFlowStore.self,
            getter: { state in
                state.movingFlowModel
            }
        ) { movingFlowModel in
            if let movingFlowModel {
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
                        store.send(.confirmMoveIntent)
                        router.push(MovingFlowRouterWithHiddenBackButtonActions.processing)
                    }
                )
                QuoteSummaryScreen(vm: vm)
            }
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

struct MovingFlowConfirm_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> MoveFlowClient in MoveFlowClientDemo() })
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
        Localization.Locale.currentLocale.send(.en_SE)
        return MovingFlowConfirm()
            .onAppear {
                let store: MoveFlowStore = globalPresentableStoreContainer.get()
                let MovingFlowModel = MovingFlowModel(
                    id: "id",
                    isApartmentAvailableforStudent: true,
                    maxApartmentNumberCoInsured: 5,
                    maxApartmentSquareMeters: 300,
                    maxHouseNumberCoInsured: 5,
                    maxHouseSquareMeters: 1000,
                    minMovingDate: "2024-10-01",
                    maxMovingDate: "2025-10-01",
                    suggestedNumberCoInsured: 3,
                    currentHomeAddresses: [],
                    potentialHomeQuotes: [],
                    quotes: [],
                    faqs: [],
                    extraBuildingTypes: []
                )
                store.send(.setMoveIntent(with: MovingFlowModel))
            }
            .environmentObject(Router())
            .environmentObject(MovingFlowNavigationViewModel())
    }
}
