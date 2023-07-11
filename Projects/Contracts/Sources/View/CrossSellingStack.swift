import Foundation
import SwiftUI
import hCore
import hCoreUI

struct CrossSellingStack: View {
    var body: some View {
        PresentableStoreLens(
            ContractStore.self,
            getter: { state in
                state.crossSells.filter { crossSell in
                    !state.signedCrossSells.contains(crossSell)
                }
            }
        ) { crossSells in
            if !crossSells.isEmpty {
                hSection(
                    header:
                        VStack(spacing: 16) {
                            HStack(alignment: .center, spacing: 8) {
                                CrossSellingUnseenCircle()
                                hText(L10n.InsuranceTab.CrossSells.title)
                                    .foregroundColor(hTextColorNew.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            Divider()
                        }
                ) {
                    ForEach(crossSells, id: \.title) { crossSell in
                        VStack {
                            CrossSellingItem(crossSell: crossSell)
                        }
                        .padding(.bottom, 16)
                        .padding(.top, 8)
                        .transition(.slide)
                    }
                }
                .sectionContainerStyle(.transparent)
                .transition(.slide)
            }
        }
        .presentableStoreLensAnimation(.spring())
    }
}
