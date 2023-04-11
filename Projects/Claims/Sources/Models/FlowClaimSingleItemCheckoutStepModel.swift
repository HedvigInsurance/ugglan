import Foundation
import hGraphQL

public struct FlowClaimSingleItemCheckoutStepModel: FlowClaimStepModel {
    let id: String
    let deductible: ClaimFlowMoneyModel
    let depreciation: ClaimFlowMoneyModel
    let payoutAmount: ClaimFlowMoneyModel
    let price: ClaimFlowMoneyModel
    init(
        with data: OctopusGraphQL.FlowClaimSingleItemCheckoutStepFragment
    ) {
        self.id = data.id
        self.deductible = .init(with: data.deductible.fragments.moneyFragment)
        self.depreciation = .init(with: data.depreciation.fragments.moneyFragment)
        self.payoutAmount = .init(with: data.payoutAmount.fragments.moneyFragment)
        self.price = .init(with: data.price.fragments.moneyFragment)
    }

    public func returnSingleItemCheckoutInfo() -> OctopusGraphQL.FlowClaimSingleItemCheckoutInput {

        let automaticAutogiroInput = OctopusGraphQL.FlowClaimAutomaticAutogiroPayoutInput(
            amount: payoutAmount.amount
        )

        return OctopusGraphQL.FlowClaimSingleItemCheckoutInput(
            automaticAutogiro: automaticAutogiroInput
        )
    }
}

struct ClaimFlowMoneyModel: Codable, Equatable {
    let amount: Double
    let currencyCode: String

    init(
        with data: OctopusGraphQL.MoneyFragment
    ) {
        self.amount = data.amount
        self.currencyCode = data.currencyCode.rawValue
    }

    func getAmountWithCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ""
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.currencyCode = self.currencyCode
        formatter.currencySymbol = self.currencyCode
        return formatter.string(for: amount) ?? ""
    }
}
