import SwiftUI
import hCore

public struct PriceFieldModel: Identifiable, Equatable {
    public let id = UUID().uuidString
    let initialValue: MonetaryAmount?
    let newValue: MonetaryAmount
    let title: String?
    let subTitle: String?
    let infoButtonModel: PriceFieldInfoModel?
    let useSecondaryColor: Bool

    public init(
        initialValue: MonetaryAmount?,
        newValue: MonetaryAmount,
        title: String? = nil,
        subTitle: String? = nil,
        infoButtonModel: PriceFieldInfoModel? = nil,
        useSecondaryColor: Bool = false
    ) {
        self.initialValue = initialValue
        self.newValue = newValue
        self.title = title
        self.subTitle = subTitle
        self.infoButtonModel = infoButtonModel
        self.useSecondaryColor = useSecondaryColor
    }

    func shouldShowPreviousPriceLabel() -> Bool {
        if let initialValue {
            return newValue != initialValue
        }
        return false
    }

    public struct PriceFieldInfoModel: Identifiable, Equatable {
        public let id = UUID().uuidString
        let initialValue: MonetaryAmount?
        let newValue: MonetaryAmount
        let infoButtonDisplayItems: [DisplayItem]

        public init(initialValue: MonetaryAmount?, newValue: MonetaryAmount, infoButtonDisplayItems: [DisplayItem]) {
            self.initialValue = initialValue
            self.newValue = newValue
            self.infoButtonDisplayItems = infoButtonDisplayItems
        }
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
}
