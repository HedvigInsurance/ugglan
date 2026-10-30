import SwiftUI
import hCoreUI

public struct CrossSellStackComponent: View {
    let crossSells: [CrossSell]
    @State private var shownTracker: CrossSellShownTracker

    /// Offers that make up a surface of their own, visited for as long as the list is on screen.
    public init(crossSells: [CrossSell]) {
        self.init(crossSells: crossSells, shownTracker: CrossSellShownTracker())
    }

    /// Offers that share a visit with the rest of the sheet they are on.
    init(crossSells: [CrossSell], shownTracker: CrossSellShownTracker) {
        self.crossSells = crossSells
        _shownTracker = State(initialValue: shownTracker)
    }

    public var body: some View {
        hSection {
            VStack(spacing: .padding4) {
                ForEach(crossSells) { crossSell in
                    CrossSellingItem(crossSell: crossSell)
                        .onCrossSellShown { shownTracker.offerWasShown(crossSell) }
                        .transition(.opacity)
                }
            }
        }
        .sectionContainerStyle(.transparent)
        .transition(.opacity)
        .onDisappear { shownTracker.endVisit() }
    }
}

#Preview {
    CrossSellStackComponent(
        crossSells: [
            .init(
                id: "id1",
                source: .home,
                title: "title",
                description: "long description that goes long way",
                buttonTitle: "See price",
                webActionURL: "",
                imageUrl: nil,
                buttonDescription: "button"
            ),
            .init(
                id: "id2",
                source: .home,
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
