import Foundation
import hCore
import hCoreUI

public struct PaymentDiscountsData: Codable, Equatable, Sendable {
    let discountsData: [DiscountsDataForInsurance]
    let referralsData: ReferralsData

    public init(discountsData: [DiscountsDataForInsurance], referralsData: ReferralsData) {
        self.discountsData = discountsData
        self.referralsData = referralsData
    }
}

public struct DiscountsDataForInsurance: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    let displayName: String
    let info: String?
    public var discounts: [Discount]

    public init(
        id: String,
        displayName: String,
        info: String?,
        discounts: [Discount]
    ) {
        self.id = id
        self.displayName = displayName
        self.info = info
        self.discounts = discounts
    }
}

public struct Discount: Codable, Equatable, Identifiable, Hashable, Sendable {
    public static func == (lhs: Discount, rhs: Discount) -> Bool {
        lhs.id == rhs.id
    }
    public let id: String
    public let code: String
    public let displayValue: String
    public let description: String?
    public let type: DiscountType

    public init(
        code: String,
        displayValue: String,
        description: String?,
        type: DiscountType
    ) {
        self.id = UUID().uuidString
        self.code = code
        self.displayValue = displayValue
        self.description = description
        self.type = type
    }

    @MainActor
    public init(
        referral: Referral
    ) {
        self.id = UUID().uuidString
        self.code = referral.code ?? referral.name
        self.displayValue = referral.activeDiscount?.formattedNegativeAmountPerMonth ?? ""
        self.description = referral.description
        self.type = .referral
    }
}

public enum DiscountType: Sendable, Codable, Hashable {
    case discount(status: DiscountStatus)
    case referral
    case paymentsDiscount
}

public enum DiscountStatus: String, Sendable, Codable, Hashable {
    case active
    case pending
    case terminated
}

public struct ReferralsData: Equatable, Codable, Sendable {
    let discountPerMember: MonetaryAmount
    let referrals: [Referral]

    public init(code: String, discountPerMember: MonetaryAmount, referrals: [Referral]) {
        self.discountPerMember = discountPerMember
        self.referrals = referrals
    }
}

public struct Referral: Equatable, Codable, Identifiable, Sendable {
    public let id: String
    let name: String
    let code: String?
    let description: String
    let activeDiscount: MonetaryAmount?
    //    let status: State
    let invitedYou: Bool

    public init(
        id: String,
        name: String,
        code: String?,
        description: String,
        activeDiscount: MonetaryAmount? = nil,
        invitedYou: Bool = false
    ) {
        self.id = id
        self.name = name
        self.code = code
        self.description = description
        self.activeDiscount = activeDiscount
        self.invitedYou = invitedYou
    }
}
