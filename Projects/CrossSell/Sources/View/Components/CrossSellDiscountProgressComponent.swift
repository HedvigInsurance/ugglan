import SwiftUI
import hCore
import hCoreUI

struct CrossSellDiscountProgressComponent: View {
    private let numberOfInsurances: Int
    private let discountPercent: Int?

    @State private var animationProgress: CGFloat = 0

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
                            ZStack {
                                Rectangle()
                                    .fill(getBarColor(for: column <= numberOfInsurances))
                                if (column == numberOfInsurances + 1) {
                                    GeometryReader { geo in
                                        Rectangle()
                                            .fill(hSignalColor.Green.element)
                                            .mask(alignment: .leading) {
                                                Rectangle()
                                                    .frame(width: geo.size.width * animationProgress)
                                            }
                                    }
                                }
                            }
                            .frame(height: 8)
                            .cornerRadius(.cornerRadiusS)

                            VStack(spacing: 0) {
                                getTitleLabel(for: column)
                                getSubtitleLabel(for: column, discountPercent: discountPercent)
                            }
                        }
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityHint(L10n.a11YNumberOfEligibleInsurances(numberOfInsurances))
            }
            .sectionContainerStyle(.transparent)
            .onAppear {
                animatePotentialDiscount()
            }
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

    private func animatePotentialDiscount() {
        if #available(iOS 17.0, *) {
            Task {
                try? await Task.sleep(nanoseconds: UInt64(500_000_000))
                for _ in 0..<3 {
                    withAnimation(.spring(duration: 1.5)) {
                        animationProgress = 1
                    }
                    try? await Task.sleep(nanoseconds: UInt64(2_000_000_000))
                    animationProgress = 0
                }
            }
        }
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
