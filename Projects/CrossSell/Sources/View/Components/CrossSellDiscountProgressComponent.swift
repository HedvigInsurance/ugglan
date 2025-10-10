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
                                RoundedRectangle(cornerRadius: .cornerRadiusS)
                                    .fill(hSurfaceColor.Opaque.secondary)
                                if (column <= numberOfInsurances + 1) {
                                    AnimatedProgressView(orderOfExecution: column, pulse: column > numberOfInsurances)
                                }
                            }
                            .frame(height: 8)
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

@MainActor
private struct AnimatedProgressView: View {
    @State private var animationProgress: CGFloat = 0
    let orderOfExecution: Int
    let pulse: Bool
    var body: some View {
        GeometryReader { geo in
            if pulse {
                RoundedRectangle(cornerRadius: .cornerRadiusS)
                    .fill(hSignalColor.Green.element.opacity(animationProgress))
                    .scaleEffect(x: 1, y: 1 + animationProgress / 6)
            } else {
                RoundedRectangle(cornerRadius: .cornerRadiusS)
                    .fill(hSignalColor.Green.element.opacity(animationProgress))
                    .mask(alignment: .leading) {
                        Rectangle()
                            .frame(width: geo.size.width * animationProgress)
                    }
            }
        }
        .onAppear {
            animate()
        }
    }

    private func animate() {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(orderOfExecution * 1_000_000_000))
            withAnimation(.linear(duration: 1)) {
                animationProgress = 1
            }
            if pulse {
                try? await Task.sleep(nanoseconds: UInt64(1_000_000_000))
                withAnimation(.linear(duration: 1)) {
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
        //        CrossSellDiscountProgressComponent(crossSell: crossSell0)
        VStack(alignment: .leading) {
            hText("1 eligable insurance")
            CrossSellDiscountProgressComponent(crossSell: crossSell1)
            hText("2 eligable insurance")
            CrossSellDiscountProgressComponent(crossSell: crossSell2)
            hText("3 eligable insurance")
            CrossSellDiscountProgressComponent(crossSell: crossSell3)
            hText("4 eligable insurance")
            CrossSellDiscountProgressComponent(crossSell: crossSell4)
            hText("5 eligable insurance")
            CrossSellDiscountProgressComponent(crossSell: crossSell5)
        }
    }
}
