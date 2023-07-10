import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct CrossSellMoreInfoSection: View {
    @PresentableStore var store: ContractStore
    let crossSell: CrossSell

    var body: some View {
        hSection(header: hText(L10n.CrossSell.Info.learnMoreTitle)) {
            if let info = crossSell.infos.first {
                hRow {
                    HStack(spacing: 16) {
                        Image(uiImage: hCoreUIAssets.insurance.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                        hText(L10n.CrossSell.Info.fullCoverageRow)
                    }
                }
                .onTap {
                    store.send(.crossSellingCoverageDetailNavigation(action: .detail(info: info)))
                }
            }
            hRow {
                HStack(spacing: 16) {
                    Image(uiImage: hCoreUIAssets.infoIcon.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                    hText(L10n.CrossSell.Info.commonQuestionsRow)
                }
            }
            .onTap {
                store.send(.crossSellingFAQListNavigation(action: .list))
            }
        }
    }
}
