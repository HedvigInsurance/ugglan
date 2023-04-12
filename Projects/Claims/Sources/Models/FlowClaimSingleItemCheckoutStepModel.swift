import Foundation
import hGraphQL

public struct FlowClaimSingleItemCheckoutStepModel: FlowClaimStepModel {
    let id: String
    let deductible: ClaimFlowMoneyModel
    let depreciation: ClaimFlowMoneyModel
    let payoutAmount: ClaimFlowMoneyModel
    let price: ClaimFlowMoneyModel
    let payoutMethods: [AvailableCheckoutMethod]
    var selectedPayoutMethod: AvailableCheckoutMethod?

    init(
        with data: OctopusGraphQL.FlowClaimSingleItemCheckoutStepFragment
    ) {
        self.id = data.id
        self.deductible = .init(with: data.deductible.fragments.moneyFragment)
        self.depreciation = .init(with: data.depreciation.fragments.moneyFragment)
        self.payoutAmount = .init(with: data.payoutAmount.fragments.moneyFragment)
        self.price = .init(with: data.price.fragments.moneyFragment)

        self.payoutMethods = data.availableCheckoutMethods.compactMap({
            let id = $0.id
            if $0.__typename == "FlowClaimAutomaticAutogiroPayout" {
                let fragment = $0.fragments.flowClaimAutomaticAutogiroPayoutFragment
                return AvailableCheckoutMethod(id: id, autogiro: ClaimAutomaticAutogiroPayoutModel(with: fragment))
            }
            return nil
        })
        self.selectedPayoutMethod = payoutMethods.first
    }

    public func returnSingleItemCheckoutInfo() -> OctopusGraphQL.FlowClaimSingleItemCheckoutInput? {
        return selectedPayoutMethod?.getCheckoutInput(forAmount: payoutAmount.amount)

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

public struct AvailableCheckoutMethod: Codable, Equatable {
    var id: String
    var autogiro: ClaimAutomaticAutogiroPayoutModel?

    init(
        id: String,
        autogiro: ClaimAutomaticAutogiroPayoutModel? = nil
    ) {
        self.id = id
        self.autogiro = autogiro
    }

    func getDisplayName() -> String {
        if let autogiro {
            return autogiro.displayName
        }
        return "--"
    }

    func getCheckoutInput(forAmount amount: Double) -> OctopusGraphQL.FlowClaimSingleItemCheckoutInput? {
        if autogiro != nil {
            let automaticAutogiroInput = OctopusGraphQL.FlowClaimAutomaticAutogiroPayoutInput(
                amount: amount
            )

            return OctopusGraphQL.FlowClaimSingleItemCheckoutInput(
                automaticAutogiro: automaticAutogiroInput
            )
        }
        return nil
    }
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
