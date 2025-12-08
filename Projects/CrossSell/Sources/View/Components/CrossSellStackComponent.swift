import SwiftUI
import hCore
import hCoreUI

struct CrossSellStackComponent: View {
    let crossSells: [CrossSell]
    let withHeader: Bool
    let headerTitle: String
    let discountAvailable: Bool
    init(crossSells: [CrossSell], discountAvailable: Bool, withHeader: Bool) {
        self.crossSells = crossSells
        self.withHeader = withHeader
        self.discountAvailable = discountAvailable
        headerTitle = {
            if discountAvailable {
                return L10n.insuranceOffersSubheading
            } else {
                return L10n.InsuranceTab.CrossSells.title
            }
        }()
    }
    var body: some View {
        let content = hSection {
            VStack(spacing: .padding16) {
                ForEach(crossSells, id: \.title) { crossSell in
                    CrossSellingItem(crossSell: crossSell, discountAvailable: discountAvailable)
                        .transition(.slide)
                }
            }
        }
        Group {
            if withHeader {
                content.withHeader(title: headerTitle)
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
        discountAvailable: true,
        withHeader: true
    )
}
