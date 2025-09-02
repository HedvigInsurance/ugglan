import SwiftUI
import hCore

public class PriceFieldViewModel: ObservableObject {
    let newNetPremium: MonetaryAmount?
    let newGrossPremium: MonetaryAmount?
    let currentNetPremium: MonetaryAmount?
    let title: String?
    let subTitle: String?
    var infoButtonDisplayItems: [PriceBreakdownViewModel.DisplayItem]?
    @Published var isInfoViewPresented: PriceBreakdownViewModel?

    public init(
        newNetPremium: MonetaryAmount?,
        newGrossPremium: MonetaryAmount? = nil,
        currentNetPremium: MonetaryAmount?,
        title: String? = nil,
        subTitle: String? = nil,
        infoButtonDisplayItems: [PriceBreakdownViewModel.DisplayItem]? = nil
    ) {
        self.newNetPremium = newNetPremium
        self.newGrossPremium = newGrossPremium
        self.currentNetPremium = currentNetPremium
        self.title = title
        self.subTitle = subTitle
        self.infoButtonDisplayItems = infoButtonDisplayItems
    }

    func shouldShowCurrentPremium(
        _ showCurrentPremium: Bool? = true,
        strikeThroughPrice: StrikeThroughPriceType,
        multipleRows: Bool? = false
    ) -> Bool {
        let hasStrikeThrough = strikeThroughPrice != .none && !(multipleRows ?? false)
        let noStrikeThroughMultipleRow = strikeThroughPrice == .none && (multipleRows ?? false)
        return (hasStrikeThrough || noStrikeThroughMultipleRow) && newNetPremium != currentNetPremium
            && (showCurrentPremium ?? true)
    }

    func shouldStrikeThroughNewPremium(
        _ showNewPremium: Bool,
        strikeThroughPrice: StrikeThroughPriceType
    ) -> Bool {
        strikeThroughPrice == .crossNewPrice
    }

    func shouldShowPreviousPriceLabel(
        strikeThroughPrice: StrikeThroughPriceType
    ) -> Bool {
        if let currentNetPremium, let newNetPremium {
            return newNetPremium != currentNetPremium && strikeThroughPrice != .crossOldPrice
        }
        return false
    }
}
