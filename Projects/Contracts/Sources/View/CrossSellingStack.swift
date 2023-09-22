import Foundation
import SwiftUI
import hCore
import hCoreUI

struct CrossSellingStack: View {
    let withHeader: Bool
    var body: some View {
        PresentableStoreLens(
            ContractStore.self,
            getter: { state in
                state.crossSells
            }
        ) { crossSells in
            if !crossSells.isEmpty {
                hSection {
                    ForEach(crossSells, id: \.title) { crossSell in
                        VStack {
                            CrossSellingItem(crossSell: crossSell)
                        }
                        .padding(.bottom, 16)
                        .padding(.top, 8)
                        .transition(.slide)
                    }
                }
                .withHeader {
                    if withHeader {
                        VStack(spacing: 16) {
                            HStack(alignment: .center, spacing: 8) {
                                CrossSellingUnseenCircle()
                                hText(L10n.InsuranceTab.CrossSells.title)
                                    .padding(.leading, 2)
                                    .foregroundColor(hTextColorNew.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            Divider()
                                .overlay(hFillColorNew.translucentOne)
                                .frame(height: 1)
                        }
                    }
                }
                .sectionContainerStyle(.transparent)
                .transition(.slide)
            }
        }
        .presentableStoreLensAnimation(.spring())
    }
}
