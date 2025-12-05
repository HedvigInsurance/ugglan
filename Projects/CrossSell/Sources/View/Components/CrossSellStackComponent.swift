import SwiftUI
import hCore
import hCoreUI

struct CrossSellStackComponent: View {
    let crossSells: [CrossSell]
    let source: CrossSellSource
    let withHeader: Bool
    let headerTitle: String
    init(crossSells: [CrossSell], source: CrossSellSource, withHeader: Bool) {
        self.crossSells = crossSells
        self.source = source
        self.withHeader = withHeader
        headerTitle = {
            switch source {
            case .insurances:
                return L10n.insuranceOffersSubheading
            default:
                return L10n.InsuranceTab.CrossSells.title
            }
        }()
    }
    var body: some View {
        let content = hSection {
            VStack(spacing: .padding16) {
                ForEach(crossSells, id: \.title) { crossSell in
                    CrossSellingItem(crossSell: crossSell, source: source)
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
        source: .changeTier,
        withHeader: true
    )
}
