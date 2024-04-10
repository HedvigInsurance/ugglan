import Foundation
import hCore
import hGraphQL

public struct FlowClaimSingleItemCheckoutStepModel: FlowClaimStepModel {
    let id: String
    let deductible: MonetaryAmount
    let depreciation: MonetaryAmount
    let payoutAmount: MonetaryAmount
    let price: MonetaryAmount
    let repairCostAmount: MonetaryAmount?
    let payoutMethods: [AvailableCheckoutMethod]
    var selectedPayoutMethod: AvailableCheckoutMethod?

    init(
        id: String,
        deductible: MonetaryAmount,
        depreciation: MonetaryAmount,
        payoutAmount: MonetaryAmount,
        price: MonetaryAmount,
        repairCostAmount: MonetaryAmount?,
        payoutMethods: [AvailableCheckoutMethod],
        selectedPayoutMethod: AvailableCheckoutMethod? = nil
    ) {
        self.id = id
        self.deductible = deductible
        self.depreciation = depreciation
        self.payoutAmount = payoutAmount
        self.price = price
        self.repairCostAmount = repairCostAmount
        self.payoutMethods = payoutMethods
        self.selectedPayoutMethod = selectedPayoutMethod
    }

    init(
        with data: OctopusGraphQL.FlowClaimSingleItemCheckoutStepFragment
    ) {
        self.id = data.id
        self.deductible = .init(fragment: data.deductible.fragments.moneyFragment)
        self.depreciation = .init(fragment: data.depreciation.fragments.moneyFragment)
        self.payoutAmount = .init(fragment: data.payoutAmount.fragments.moneyFragment)
        self.price = .init(fragment: data.price.fragments.moneyFragment)

        self.repairCostAmount = .init(optionalFragment: data.repairCostAmount?.fragments.moneyFragment)

        self.payoutMethods = data.availableCheckoutMethods.compactMap({
            let id = $0.id
            if $0.__typename == "FlowClaimAutomaticAutogiroPayout" {
                let fragment = $0.asFlowClaimAutomaticAutogiroPayout!.fragments.flowClaimAutomaticAutogiroPayoutFragment
                return AvailableCheckoutMethod(id: id, autogiro: ClaimAutomaticAutogiroPayoutModel(with: fragment))
            }
            return nil
        })
        self.selectedPayoutMethod = payoutMethods.first
    }

    public func returnSingleItemCheckoutInfo() -> OctopusGraphQL.FlowClaimSingleItemCheckoutInput? {
        return selectedPayoutMethod?.getCheckoutInput(forAmount: Double(payoutAmount.floatAmount))
    }
}

public struct AvailableCheckoutMethod: Codable, Equatable, Hashable {
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
                automaticAutogiro: GraphQLNullable(optionalValue: automaticAutogiroInput)
            )
        }
        return nil
    }
}

struct ClaimAutomaticAutogiroPayoutModel: Codable, Equatable, Hashable {
    let id: String
    let amount: MonetaryAmount
    let displayName: String

    init(
        id: String,
        amount: MonetaryAmount,
        displayName: String
    ) {
        self.id = id
        self.amount = amount
        self.displayName = displayName
    }

    init(
        with data: OctopusGraphQL.FlowClaimAutomaticAutogiroPayoutFragment
    ) {
        self.id = data.id
        self.displayName = data.displayName
        self.amount = .init(fragment: data.amount.fragments.moneyFragment)
    }
}
