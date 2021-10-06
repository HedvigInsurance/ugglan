import Foundation
import SwiftUI
import hCore
import hCoreUI

struct CrossSellingStack: View {
    var body: some View {
        PresentableStoreLens(
            ContractStore.self,
            getter: { state in
                state.contractBundles.flatMap { $0.crossSells }
                    .filter { crossSell in
                        !state.signedCrossSells.contains(crossSell)
                    }
            }
        ) { crossSells in
            if !crossSells.isEmpty {
                hSection(
                    header: HStack(alignment: .center, spacing: 8) {
                        CrossSellingUnseenCircle()
                        hText(L10n.InsuranceTab.CrossSells.title, style: .title3)
                            .foregroundColor(hLabelColor.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                ) {
                    ForEach(crossSells, id: \.title) { crossSell in
                        CrossSellingItem(crossSell: crossSell).transition(.slide)
                    }
                }
                .transition(.slide)
            }
        }
        .presentableStoreLensAnimation(.spring())
    }
}
