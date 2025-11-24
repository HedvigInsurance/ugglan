import SwiftUI
import hCore
import hCoreUI

struct CrosssSellStackComponent: View {
    let crossSells: [CrossSell]
    let showDiscount: Bool
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
                title: L10n.insuranceOffersSubheading
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

#Preview {
    CrosssSellStackComponent(
        crossSells: [
            .init(
                id: "id",
                title: "title",
                description: "long description that goes long way",
                buttonTitle: "Save 15%",
                imageUrl: nil,
                buttonDescription: "button"
            ),
            .init(
                id: "id",
                title: "short btn",
                description: "short",
                buttonTitle: "Save 15%",
                imageUrl: nil,
                buttonDescription: "button"
            ),
        ],
        showDiscount: true,
        withHeader: true
    )
}
