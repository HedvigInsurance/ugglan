import SwiftUI
import hCore
import hCoreUI

public struct CrossSellStackComponent: View {
    let crossSells: [CrossSell]
    public init(crossSells: [CrossSell]) {
        self.crossSells = crossSells
    }
    public var body: some View {
        hSection {
            VStack(spacing: .padding4) {
                ForEach(crossSells, id: \.title) { crossSell in
                    CrossSellingItem(crossSell: crossSell)
                        .transition(.opacity)
                }
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
        ]
    )
}
