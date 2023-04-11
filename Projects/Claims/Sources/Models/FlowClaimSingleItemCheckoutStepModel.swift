import Foundation
import hGraphQL

public struct FlowClaimSingleItemCheckoutStepModel: FlowClaimStepModel {
    let id: String
    let deductible: ClaimFlowMoneyModel
    let depreciation: ClaimFlowMoneyModel
    let payoutAmount: ClaimFlowMoneyModel
    let price: ClaimFlowMoneyModel
    var payoutMethod: [AvailableCheckoutMethods] = []

    init(
        with data: OctopusGraphQL.FlowClaimSingleItemCheckoutStepFragment
    ) {
        self.id = data.id
        self.deductible = .init(with: data.deductible.fragments.moneyFragment)
        self.depreciation = .init(with: data.depreciation.fragments.moneyFragment)
        self.payoutAmount = .init(with: data.payoutAmount.fragments.moneyFragment)
        self.price = .init(with: data.price.fragments.moneyFragment)

        for element in data.availableCheckoutMethods {
            let amount = OctopusGraphQL.FlowClaimAutomaticAutogiroPayoutFragment.Amount(
                amount: element.amount.fragments.moneyFragment.amount,
                currencyCode: element.amount.fragments.moneyFragment.currencyCode
            )
            let fragment = OctopusGraphQL.FlowClaimAutomaticAutogiroPayoutFragment(
                id: element.id,
                amount: amount,
                displayName: element.displayName
            )
            self.payoutMethod.append(
                AvailableCheckoutMethods(method: ClaimAutomaticAutogiroPayoutModel(with: fragment))
            )
        }
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
}

struct AvailableCheckoutMethods: Codable, Equatable {
    var method: ClaimAutomaticAutogiroPayoutModel?
}

struct ClaimAutomaticAutogiroPayoutModel: Codable, Equatable {
    let id: String
    let amount: ClaimFlowMoneyModel
    let displayName: String

    init(
        with data: OctopusGraphQL.FlowClaimAutomaticAutogiroPayoutFragment
    ) {
        self.id = data.id
        self.displayName = data.displayName
        self.amount = .init(with: data.amount.fragments.moneyFragment)
    }
}
