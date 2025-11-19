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
                    hasDiscountView
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

    @ViewBuilder
    private var hasDiscountView: some View {
        if showDiscount {
            HStack {
                ExpandingView(
                    mainContent: {
                        hCoreUIAssets.campaign.view.foregroundColor(hSignalColor.Green.element)
                            .frame(width: 17, height: 17)
                            .padding(.vertical, .padding8)
                            .rotate()
                    },
                    expandingContent: {
                        hText(L10n.insurancesCrossSellDiscountsAvailable, style: .label)
                            .foregroundColor(hSignalColor.Green.text)
                            .padding(.trailing, .padding4)
                    }
                ) { finalView in
                    AnyView(
                        finalView
                            .padding(.horizontal, .padding8)
                            .background(hHighlightColor.Green.fillOne)
                            .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusXXL))
                    )
                }
                Spacer()
            }
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
                imageUrl: nil,
                buttonDescription: "button"
            )
        ],
        showDiscount: true,
        withHeader: true
    )
}
