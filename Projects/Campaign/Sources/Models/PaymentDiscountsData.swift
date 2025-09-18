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
    public var discount: [Discount]

    public init(id: String, displayName: String, discount: [Discount]) {
        self.id = id
        self.displayName = displayName
        self.discount = discount
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
    let discountId: String

    public init(
        code: String,
        displayValue: String,
        description: String?,
        discountId: String,
        type: DiscountType
    ) {
        self.id = UUID().uuidString
        self.code = code
        self.displayValue = displayValue
        self.discountId = discountId
        self.description = description
        self.type = type
    }

    @MainActor
    public init(
        referral: Referral,
        nbOfReferrals: Int,
    ) {
        self.id = UUID().uuidString
        self.code = referral.code ?? referral.name
        self.displayValue = referral.activeDiscount?.formattedNegativeAmountPerMonth ?? ""
        self.description = referral.description
        self.discountId = referral.id
        self.type = .referral
    }
}

public enum DiscountType: Sendable, Codable, Hashable {
    case discount(status: DiscountStatus)
    case referral
    case paymentsDiscount
}

public enum DiscountStatus: String, Sendable, Codable, Hashable {
    case ACTIVE
    case PENDING
    case TERMINATED
}

public struct ReferralsData: Equatable, Codable, Sendable {
    let code: String
    let discountPerMember: MonetaryAmount
    let discount: MonetaryAmount
    let referrals: [Referral]

    public init(code: String, discountPerMember: MonetaryAmount, discount: MonetaryAmount, referrals: [Referral]) {
        self.code = code
        self.discountPerMember = discountPerMember
        self.discount = discount
        self.referrals = referrals
    }

    var allReferralDiscount: MonetaryAmount {
        let value = referrals.compactMap(\.activeDiscount).compactMap(\.value).reduce(0.0, +)
        return MonetaryAmount(amount: value, currency: discountPerMember.currency)
    }
}

public struct Referral: Equatable, Codable, Identifiable, Sendable {
    public let id: String
    let name: String
    let code: String?
    let description: String
    let activeDiscount: MonetaryAmount?
    let status: State
    let invitedYou: Bool

    public init(
        id: String,
        name: String,
        code: String?,
        description: String,
        activeDiscount: MonetaryAmount? = nil,
        status: State,
        invitedYou: Bool = false
    ) {
        self.id = id
        self.name = name
        self.code = code
        self.description = description
        self.activeDiscount = activeDiscount
        self.status = status
        self.invitedYou = invitedYou
    }

    public enum State: String, Codable, Sendable {
        case terminated
        case pending
        case active
        case unknown
    }
}

@MainActor
extension Referral {
    @hColorBuilder var statusColor: some hColor {
        switch status {
        case .active:
            hSignalColor.Green.element
        case .pending:
            hSignalColor.Amber.element
        case .terminated:
            hSignalColor.Red.element
        case .unknown:
            hSignalColor.Blue.element
        }
    }

    @hColorBuilder var discountLabelColor: some hColor {
        switch status {
        case .active:
            hTextColor.Opaque.secondary
        case .pending, .terminated:
            hTextColor.Opaque.tertiary
        case .unknown:
            hTextColor.Opaque.tertiary
        }
    }

    @hColorBuilder var invitedByOtherLabelColor: some hColor {
        switch status {
        case .active, .pending:
            hTextColor.Opaque.tertiary
        case .terminated:
            hTextColor.Opaque.tertiary
        case .unknown:
            hTextColor.Opaque.tertiary
        }
    }

    @MainActor
    var discountLabelText: String {
        switch status {
        case .active:
            return activeDiscount?.negative.formattedAmount ?? ""
        case .pending:
            return L10n.referralPendingStatusLabel
        case .terminated:
            return L10n.referralTerminatedStatusLabel
        case .unknown:
            return ""
        }
    }
}
