import Foundation
import PresentableStore
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
                    VStack(spacing: 16) {
                        ForEach(crossSells, id: \.title) { crossSell in
                            CrossSellingItem(crossSell: crossSell)
                                .transition(.slide)
                        }
                    }
                }
                .withHeader {
                    if withHeader {
                        HStack(alignment: .center, spacing: 8) {
                            CrossSellingUnseenCircle()
                            hText(L10n.InsuranceTab.CrossSells.title)
                                .padding(.leading, 2)
                                .foregroundColor(hTextColor.Opaque.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.bottom, .padding8)
                    }
                }
                .sectionContainerStyle(.transparent)
                .transition(.slide)
            }
        }
        .hPresentableStoreLensAnimation(.spring())
    }
}
