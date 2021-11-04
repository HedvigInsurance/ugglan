import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

enum DataCollectionInsuranceItem: Identifiable {
    case hedvig
    case external(insurance: DataCollectionInsurance)

    var id: String {
        switch self {
        case .hedvig:
            return "hedvig"
        case let .external(insurance):
            return insurance.displayName
        }
    }
}

struct DataCollectionComparisonList: View {
    @PresentableStore var store: DataCollectionStore

    var body: some View {
        PresentableStoreLens(
            DataCollectionStore.self,
            getter: { state in
                state.insurances
            }
        ) { insurances in
            if !insurances.isEmpty {
                hSection(
                    [
                        [DataCollectionInsuranceItem.hedvig],
                        insurances.map { insurance in
                            DataCollectionInsuranceItem.external(insurance: insurance)
                        },
                    ]
                    .flatMap { $0 }
                ) { item in
                    switch item {
                    case .hedvig:
                        hRow {
                            hCoreUIAssets.wordmark.view
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, alignment: .center)
                        }
                        .withCustomAccessory {
                            Spacer()
                            PresentableStoreLens(
                                OfferStore.self,
                                getter: { state in
                                    state.currentVariant?.bundle.bundleCost.monthlyNet
                                }
                            ) { netPremium in
                                if let netPremium = netPremium {
                                    hText("\(netPremium.formattedAmount)\(L10n.perMonth)")
                                        .foregroundColor(hLabelColor.secondary)
                                } else {
                                    ActivityIndicator(isAnimating: true)
                                }
                            }
                        }
                    case let .external(insurance):
                        hRow {
                            hText("\(insurance.displayName) - \(insurance.providerDisplayName)")
                                .foregroundColor(hLabelColor.secondary)
                        }
                        .withCustomAccessory {
                            Spacer()
                            hText("\(insurance.monthlyNetPremium.formattedAmount)\(L10n.perMonth)")
                                .foregroundColor(hLabelColor.secondary)
                        }
                    }
                }
                .withHeader {
                    hText(L10n.offerPriceComparisionHeader)
                }
            }
        }
        .onAppear {
            store.send(.fetchInfo)
        }
    }
}
