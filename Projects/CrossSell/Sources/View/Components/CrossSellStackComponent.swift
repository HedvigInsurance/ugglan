import SwiftUI
import hCore
import hCoreUI

public struct CrossSellStackComponent: View {
    let crossSells: [CrossSell]
    let withHeader: Bool
    let headerTitle: String
    let discountAvailable: Bool
    public init(crossSells: [CrossSell], discountAvailable: Bool, withHeader: Bool, headerTitle: String? = nil) {
        self.crossSells = crossSells
        self.withHeader = withHeader
        self.discountAvailable = discountAvailable
        self.headerTitle =
            headerTitle ?? (discountAvailable ? L10n.insuranceOffersSubheading : L10n.InsuranceTab.CrossSells.title)
    }
    public var body: some View {
        let content = hSection {
            VStack(spacing: .padding4) {
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
                webActionURL: "",
                imageUrl: nil,
                buttonDescription: "button"
            ),
            .init(
                id: "id",
                title: "short btn",
                description: "short",
                buttonTitle: "Save 15%",
                webActionURL: "",
                imageUrl: nil,
                buttonDescription: "button"
            ),
        ],
        discountAvailable: true,
        withHeader: true
    )
}
