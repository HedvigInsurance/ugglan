import Foundation
import hCore

public struct FlowClaimSingleItemCheckoutStepModel: FlowClaimStepModel {
    public let compensation: Compensation
    let payoutMethods: [AvailableCheckoutMethod]
    public var selectedPayoutMethod: AvailableCheckoutMethod?
    let singleItemModel: FlowClaimSingleItemStepModel?

    public init(
        payoutMethods: [AvailableCheckoutMethod],
        selectedPayoutMethod: AvailableCheckoutMethod? = nil,
        compensation: Compensation,
        singleItemModel: FlowClaimSingleItemStepModel?
    ) {
        self.payoutMethods = payoutMethods
        self.selectedPayoutMethod = selectedPayoutMethod
        self.compensation = compensation
        self.singleItemModel = singleItemModel
    }
}

public struct AvailableCheckoutMethod: Codable, Equatable, Hashable, Sendable {
    var id: String
    public internal(set) var autogiro: ClaimAutomaticAutogiroPayoutModel?

    public init(
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
}

public struct ClaimAutomaticAutogiroPayoutModel: Codable, Equatable, Hashable, Sendable {
    let displayName: String

    public init(
        displayName: String
    ) {
        self.displayName = displayName
    }
}

public struct Compensation: Codable, Equatable, Hashable, Sendable {
    let deductible: MonetaryAmount
    public let payoutAmount: MonetaryAmount
    let repairCompensation: RepairCompensation?
    let valueCompensation: ValueCompensation?

    public init(
        deductible: MonetaryAmount,
        payoutAmount: MonetaryAmount,
        repairCompensation: RepairCompensation?,
        valueCompensation: ValueCompensation?
    ) {
        self.deductible = deductible
        self.payoutAmount = payoutAmount
        self.repairCompensation = repairCompensation
        self.valueCompensation = valueCompensation
    }

    public struct RepairCompensation: Codable, Equatable, Hashable, Sendable {
        let repairCost: MonetaryAmount

        public init(repairCost: MonetaryAmount) {
            self.repairCost = repairCost
        }
    }

    public struct ValueCompensation: Codable, Equatable, Hashable, Sendable {
        let depreciation: MonetaryAmount
        let price: MonetaryAmount

        public init(
            depreciation: MonetaryAmount,
            price: MonetaryAmount
        ) {
            self.depreciation = depreciation
            self.price = price
        }
    }
}
