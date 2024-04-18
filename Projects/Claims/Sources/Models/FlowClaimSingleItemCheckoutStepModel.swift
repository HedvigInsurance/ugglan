import Foundation
import hCore
import hGraphQL

public struct FlowClaimSingleItemCheckoutStepModel: FlowClaimStepModel {
    let id: String
    let compensation: Compensation
    let payoutMethods: [AvailableCheckoutMethod]
    var selectedPayoutMethod: AvailableCheckoutMethod?

    init(
        id: String,
        payoutMethods: [AvailableCheckoutMethod],
        selectedPayoutMethod: AvailableCheckoutMethod? = nil,
        compensation: Compensation
    ) {
        self.id = id
        self.payoutMethods = payoutMethods
        self.selectedPayoutMethod = selectedPayoutMethod
        self.compensation = compensation
    }

    init(
        with data: OctopusGraphQL.FlowClaimSingleItemCheckoutStepFragment
    ) {
        self.id = data.id
        self.compensation = .init(with: data.compensation.fragments.flowClaimSingleItemCheckoutCompensationFragment)

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
        return selectedPayoutMethod?.getCheckoutInput(forAmount: Double(compensation.payoutAmount.floatAmount))
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

struct Compensation: Codable, Equatable, Hashable {
    let id: String
    let deductible: MonetaryAmount
    let payoutAmount: MonetaryAmount
    let repairCompensation: RepairCompensation?
    let valueCompensation: ValueCompensation?

    init(
        with data: OctopusGraphQL.FlowClaimSingleItemCheckoutCompensationFragment
    ) {
        self.id = data.id
        self.deductible = .init(fragment: data.deductible.fragments.moneyFragment)
        self.payoutAmount = .init(fragment: data.payoutAmount.fragments.moneyFragment)

        self.repairCompensation = .init(with: data.asFlowClaimSingleItemCheckoutRepairCompensation)
        self.valueCompensation = .init(with: data.asFlowClaimSingleItemCheckoutValueCompensation)
    }

    init(
        id: String,
        deductible: MonetaryAmount,
        payoutAmount: MonetaryAmount,
        repairCompensation: RepairCompensation?,
        valueCompensation: ValueCompensation?
    ) {
        self.id = id
        self.deductible = deductible
        self.payoutAmount = payoutAmount
        self.repairCompensation = repairCompensation
        self.valueCompensation = valueCompensation
    }

    struct RepairCompensation: Codable, Equatable, Hashable {
        let repairCost: MonetaryAmount

        init?(
            with data: OctopusGraphQL.FlowClaimSingleItemCheckoutCompensationFragment
                .AsFlowClaimSingleItemCheckoutRepairCompensation?
        ) {
            guard let data else {
                return nil
            }
            self.repairCost = .init(fragment: data.repairCost.fragments.moneyFragment)
        }
    }

    struct ValueCompensation: Codable, Equatable, Hashable {
        let depreciation: MonetaryAmount
        let price: MonetaryAmount

        init(
            depreciation: MonetaryAmount,
            price: MonetaryAmount
        ) {
            self.depreciation = depreciation
            self.price = price
        }

        init?(
            with data: OctopusGraphQL.FlowClaimSingleItemCheckoutCompensationFragment
                .AsFlowClaimSingleItemCheckoutValueCompensation?
        ) {
            guard let data else {
                return nil
            }
            self.depreciation = .init(fragment: data.depreciation.fragments.moneyFragment)
            self.price = .init(fragment: data.price.fragments.moneyFragment)
        }
    }
}
