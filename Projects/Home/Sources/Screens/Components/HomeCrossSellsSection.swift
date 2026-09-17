import CrossSell
import SwiftUI
import hCore

struct HomeCrossSellsSection: View {
    let crossSells: CrossSells?

    var body: some View {
        if let crossSells, !crossSells.others.isEmpty {
            CrossSellStackComponent(crossSells: crossSells.others)
        }
    }
}

#Preview {
    HomeCrossSellsSection(
        crossSells: .init(
            recommended: .insurance(
                .init(
                    id: "2",
                    title: "Accident Insurance",
                    description: "From 79 SEK/mo.",
                    buttonTitle: "See price",
                    webActionURL: "",
                    imageUrl: nil,
                    buttonDescription: ""
                )
            ),
            others: [
                .init(
                    id: "1",
                    title: "Pet Insurance",
                    description: "For your dog or cat",
                    buttonTitle: "See price",
                    webActionURL: "",
                    imageUrl: nil,
                    buttonDescription: ""
                )
            ]
        )
    )
}
