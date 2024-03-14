import Foundation
import hGraphQL

public struct Referral: Hashable, Codable {
    let name: String
    let activeDiscount: MonetaryAmount?
    let status: State

    public init(
        from data: OctopusGraphQL.MemberReferralInformationQuery.Data.CurrentMember.ReferralInformation.Referral
    ) {
        self.name = data.name
        if let activeDiscount = data.activeDiscount?.fragments.moneyFragment {
            self.activeDiscount = MonetaryAmount(fragment: activeDiscount)
        } else {
            activeDiscount = MonetaryAmount(amount: "", currency: "")
        }
        if data.status == .active {
            self.status = .active
        } else if data.status == .pending {
            self.status = .pending
        } else if data.status == .terminated {
            self.status = .terminated
        } else {
            self.status = .pending
        }
    }

    public init(
        from data: OctopusGraphQL.MemberReferralInformationQuery.Data.CurrentMember.ReferralInformation.ReferredBy
    ) {
        self.name = data.name
        if let activeDiscount = data.activeDiscount?.fragments.moneyFragment {
            self.activeDiscount = MonetaryAmount(fragment: activeDiscount)
        } else {
            activeDiscount = MonetaryAmount(amount: "", currency: "")
        }

        if data.status == .active {
            self.status = .active
        } else if data.status == .pending {
            self.status = .pending
        } else if data.status == .terminated {
            self.status = .terminated
        } else {
            self.status = .pending
        }
    }

    public init(
        name: String,
        activeDiscount: MonetaryAmount? = nil,
        status: State
    ) {
        self.name = name
        self.activeDiscount = activeDiscount
        self.status = status
    }

    public enum State: String, Codable {
        case terminated
        case pending
        case active
    }
}

public struct ForeverData: Codable, Equatable {
    public init(
        grossAmount: MonetaryAmount,
        netAmount: MonetaryAmount,
        otherDiscounts: MonetaryAmount?,
        discountCode: String,
        monthlyDiscount: MonetaryAmount,
        referrals: [Referral],
        referredBy: Referral?,
        monthlyDiscountPerReferral: MonetaryAmount
    ) {
        self.grossAmount = grossAmount
        self.netAmount = netAmount
        self.otherDiscounts = otherDiscounts
        self.discountCode = discountCode
        self.monthlyDiscount = monthlyDiscount
        self.monthlyDiscountPerReferral = monthlyDiscountPerReferral
        self.referrals = referrals
        self.referredBy = referredBy
    }

    let grossAmount: MonetaryAmount
    let netAmount: MonetaryAmount
    let monthlyDiscount: MonetaryAmount
    let otherDiscounts: MonetaryAmount?
    var discountCode: String
    let referrals: [Referral]
    let referredBy: Referral?
    let monthlyDiscountPerReferral: MonetaryAmount

    public mutating func updateDiscountCode(_ newValue: String) { discountCode = newValue }
}

public enum ForeverChangeCodeError: Error, LocalizedError, Equatable {
    case errorMessage(message: String)

    public var errorDescription: String? {
        switch self {
        case let .errorMessage(message):
            return message
        }
    }
}
