import Foundation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct CrossSellMoreInfoSection: View {
    @PresentableStore var store: ContractStore
    let info: CrossSellInfo

    var body: some View {
        hSection(header: hText("Learn more")) {
            hRow {
                HStack(spacing: 16) {
                    Image(uiImage: hCoreUIAssets.insurance.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                    hText("Full Coverage")
                }
            }
            .onTap {
                store.send(.crossSellingCoverageDetailNavigation(action: .detail))
            }
            hRow {
                HStack(spacing: 16) {
                    Image(uiImage: hCoreUIAssets.infoLarge.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                    hText("Common questions")
                }
            }
            .onTap {
                store.send(.crossSellingFAQListNavigation(action: .list))
            }
        }
    }
}
