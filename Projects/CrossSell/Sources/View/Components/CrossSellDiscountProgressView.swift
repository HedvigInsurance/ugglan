import SwiftUI
import hCoreUI

struct CrossSellDiscountProgressView: View {
    let numberOfInsurances: Int

    @ViewBuilder
    var body: some View {
        if numberOfInsurances > 0 {
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
                                getSubtitleLabel(for: column)
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
            case 1: return "1 insurance"
            case 2: return "2 insurances"
            default: return "3 or more"
            }
        }()
        return hText(text, style: .label)
    }

    private func getSubtitleLabel(for column: Int) -> some View {
        let text: String = {
            switch column {
            case 1: return "No discount"
            case 2: return "15% discount"
            default: return "15% discount"
            }
        }()
        return hText(text, style: .label)
            .foregroundColor(hTextColor.Opaque.secondary)
    }
}

#Preview {
    ScrollView {
        CrossSellDiscountProgressView(numberOfInsurances: 0)
        CrossSellDiscountProgressView(numberOfInsurances: 1)
        CrossSellDiscountProgressView(numberOfInsurances: 2)
        CrossSellDiscountProgressView(numberOfInsurances: 3)
        CrossSellDiscountProgressView(numberOfInsurances: 4)
        CrossSellDiscountProgressView(numberOfInsurances: 5)
    }
}
