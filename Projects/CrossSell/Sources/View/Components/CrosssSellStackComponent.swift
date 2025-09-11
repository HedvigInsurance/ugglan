import SwiftUI
import hCore
import hCoreUI

struct CrosssSellStackComponent: View {
    let crossSells: [CrossSell]
    let withHeader: Bool
    var body: some View {
        if withHeader {
            hSection {
                VStack(spacing: .padding16) {
                    ForEach(crossSells, id: \.title) { crossSell in
                        CrossSellingItem(crossSell: crossSell)
                            .transition(.slide)
                    }
                }
            }
            .withHeader(
                title: L10n.InsuranceTab.CrossSells.title
            )
            .sectionContainerStyle(.transparent)
            .transition(.slide)
        } else {
            hSection {
                VStack(spacing: .padding16) {
                    ForEach(crossSells, id: \.title) { crossSell in
                        CrossSellingItem(crossSell: crossSell)
                            .transition(.slide)
                    }
                }
            }
            .sectionContainerStyle(.transparent)
            .transition(.slide)
        }
    }
}
