import SwiftUI
import hCore
import hCoreUI

struct CrossSellStackComponent: View {
    let crossSells: [CrossSell]
    let withHeader: Bool
    var body: some View {
        let content = hSection {
            VStack(spacing: .padding16) {
                ForEach(crossSells, id: \.title) { crossSell in
                    CrossSellingItem(crossSell: crossSell)
                        .transition(.slide)
                }
            }
        }
        Group {
            if withHeader {
                content.withHeader(title: L10n.insuranceOffersSubheading)
            } else {
                content
            }
        }
        .sectionContainerStyle(.transparent)
        .transition(.slide)
    }
}

#Preview {
    CrossSellStackComponent(
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
        withHeader: true
    )
}
