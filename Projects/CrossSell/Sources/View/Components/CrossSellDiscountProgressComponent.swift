import SwiftUI
import hCore
import hCoreUI

struct CrossSellDiscountProgressComponent: View {
    private let numberOfInsurances: Int
    private let discountPercent: Int?

    init(crossSell: CrossSell) {
        self.numberOfInsurances = crossSell.numberOfEligibleContracts
        self.discountPercent = crossSell.discountPercent
    }

    @ViewBuilder
    var body: some View {
        if let discountPercent = discountPercent, numberOfInsurances > 0 {
            hSection {
                HStack(alignment: .top, spacing: .padding6) {
                    ForEach(1..<4) { column in
                        VStack(spacing: 4) {
                            Rectangle()
                                .fill(getBarColor(for: column <= numberOfInsurances))
                                .frame(height: 8)
                                .cornerRadius(.cornerRadiusS)
                            VStack(spacing: 0) {
                                getTitleLabel(for: column)
                                getSubtitleLabel(for: column, discountPercent: discountPercent)
                            }
                        }
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }

    @hColorBuilder
    private func getBarColor(for filled: Bool) -> some hColor {
        if filled {
            hSignalColor.Green.element
        } else {
            hSurfaceColor.Opaque.secondary
        }
    }

    private func getTitleLabel(for column: Int) -> some View {
        let text: String = {
            switch column {
            case 1:
                return L10n.bundleDiscountProgressSegmentTitleOneInsurance
            case 2:
                return L10n.bundleDiscountProgressSegmentTitleTwoInsurances
            default:
                return L10n.bundleDiscountProgressSegmentTitleThreeOrMore
            }
        }()
        return hText(text, style: .label)
    }

    private func getSubtitleLabel(for column: Int, discountPercent: Int) -> some View {
        let text: String = {
            switch column {
            case 1:
                return L10n.bundleDiscountProgressSegmentSubtitleNoDiscount
            default:
                return L10n.bundleDiscountProgressSegmentSubtitleCurrentAppliedDiscount("\(discountPercent)%")
            }
        }()
        return hText(text, style: .label)
            .foregroundColor(hTextColor.Opaque.secondary)
    }
}

#Preview {
    ScrollView {
        let crossSell0 = CrossSell(
            id: "id",
            title: "title",
            description: "description",
            imageUrl: nil,
            buttonDescription: "",
            discountPercent: nil,
            numberOfEligibleContracts: 0
        )
        let crossSell1 = CrossSell(
            id: "id",
            title: "title",
            description: "description",
            imageUrl: nil,
            buttonDescription: "",
            discountPercent: 15,
            numberOfEligibleContracts: 1
        )
        let crossSell2 = CrossSell(
            id: "id",
            title: "title",
            description: "description",
            imageUrl: nil,
            buttonDescription: "",
            discountPercent: 15,
            numberOfEligibleContracts: 2
        )
        let crossSell3 = CrossSell(
            id: "id",
            title: "title",
            description: "description",
            imageUrl: nil,
            buttonDescription: "",
            discountPercent: 15,
            numberOfEligibleContracts: 3
        )
        let crossSell4 = CrossSell(
            id: "id",
            title: "title",
            description: "description",
            imageUrl: nil,
            buttonDescription: "",
            discountPercent: 15,
            numberOfEligibleContracts: 4
        )
        let crossSell5 = CrossSell(
            id: "id",
            title: "title",
            description: "description",
            imageUrl: nil,
            buttonDescription: "",
            discountPercent: 15,
            numberOfEligibleContracts: 5
        )
        CrossSellDiscountProgressComponent(crossSell: crossSell0)
        CrossSellDiscountProgressComponent(crossSell: crossSell1)
        CrossSellDiscountProgressComponent(crossSell: crossSell2)
        CrossSellDiscountProgressComponent(crossSell: crossSell3)
        CrossSellDiscountProgressComponent(crossSell: crossSell4)
        CrossSellDiscountProgressComponent(crossSell: crossSell5)
    }
}
