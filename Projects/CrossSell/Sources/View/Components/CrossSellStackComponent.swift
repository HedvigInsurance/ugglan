import SwiftUI
import hCore
import hCoreUI

public struct CrossSellStackComponent: View {
    let crossSells: [CrossSell]
    let withHeader: Bool
    public init(crossSells: [CrossSell], withHeader: Bool) {
        self.crossSells = crossSells
        self.withHeader = withHeader
    }
    public var body: some View {
        let content = hSection {
            VStack(spacing: .padding4) {
                ForEach(crossSells, id: \.title) { crossSell in
                    CrossSellingItem(crossSell: crossSell)
                        .transition(.opacity)
                }
            }
        }
        Group {
            if withHeader {
                content.withHeader(title: L10n.InsuranceTab.CrossSells.title)
            } else {
                content
            }
        }
        .sectionContainerStyle(.transparent)
        .transition(.opacity)
    }
}

#Preview {
    CrossSellStackComponent(
        crossSells: [
            .init(
                id: "id",
                title: "title",
                description: "long description that goes long way",
                buttonTitle: "See price",
                webActionURL: "",
                imageUrl: nil,
                buttonDescription: "button"
            ),
            .init(
                id: "id",
                title: "short btn",
                description: "short",
                buttonTitle: "See price",
                webActionURL: "",
                imageUrl: nil,
                buttonDescription: "button"
            ),
        ],
        withHeader: true
    )
}
