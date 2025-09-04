import SwiftUI
import hCore

public struct PriceFieldModel: Identifiable, Equatable {
    public let id = UUID().uuidString
    let initialValue: MonetaryAmount?
    let newValue: MonetaryAmount
    let title: String?
    let subTitle: String?
    var infoButtonDisplayItems: [DisplayItem]

    public init(
        initialValue: MonetaryAmount?,
        newValue: MonetaryAmount,
        title: String? = nil,
        subTitle: String? = nil,
        infoButtonDisplayItems: [DisplayItem] = []
    ) {
        self.initialValue = initialValue
        self.newValue = newValue
        self.title = title
        self.subTitle = subTitle
        self.infoButtonDisplayItems = infoButtonDisplayItems
    }

    func shouldShowPreviousPriceLabel(
        strikeThroughPrice: StrikeThroughPriceType
    ) -> Bool {
        if let initialValue {
            return newValue != initialValue
        }
        return false
    }

    public struct DisplayItem: Equatable {
        let title: String
        let value: String

        public init(
            title: String,
            value: String
        ) {
            self.title = title
            self.value = value
        }
    }

    func withoutDisplayItems() -> PriceFieldModel {
        .init(initialValue: initialValue, newValue: newValue)
    }
}
