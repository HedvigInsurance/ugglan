import Foundation
import hCore
import hCoreUI
import hGraphQL

public struct PaymentDiscountsData: Codable, Equatable {
    let discounts: [Discount]
    let referralsData: ReferralsData
}

public struct ReferralsData: Equatable, Codable {
    let code: String
    let discountPerMember: MonetaryAmount
    let discount: MonetaryAmount
    let referrals: [Referral]

    var allReferralDiscount: MonetaryAmount {
        let value = referrals.compactMap({ $0.activeDiscount }).compactMap({ $0.value }).reduce(0.0, +)
        return MonetaryAmount(amount: value, currency: discountPerMember.currency)
    }

}
public struct Referral: Equatable, Codable, Identifiable {
    public let id: String
    let name: String
    let activeDiscount: MonetaryAmount?
    let status: State
    let invitedYou: Bool

    public init(
        id: String,
        name: String,
        activeDiscount: MonetaryAmount? = nil,
        status: State,
        invitedYou: Bool = false
    ) {
        self.id = id
        self.name = name
        self.activeDiscount = activeDiscount
        self.status = status
        self.invitedYou = invitedYou
    }

    public enum State: String, Codable {
        case terminated
        case pending
        case active
        case unknown
    }
}

extension Referral {
    @hColorBuilder var statusColor: some hColor {
        switch self.status {
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
        switch self.status {
        case .active:
            hTextColor.Opaque.secondary
        case .pending, .terminated:
            hTextColor.Opaque.tertiary
        case .unknown:
            hTextColor.Opaque.tertiary
        }
    }

    @hColorBuilder var invitedByOtherLabelColor: some hColor {
        switch self.status {
        case .active, .pending:
            hTextColor.Opaque.tertiary
        case .terminated:
            hTextColor.Opaque.tertiary
        case .unknown:
            hTextColor.Opaque.tertiary
        }
    }

    var discountLabelText: String {
        switch self.status {
        case .active:
            return self.activeDiscount?.negative.formattedAmount ?? ""
        case .pending:
            return L10n.referralPendingStatusLabel
        case .terminated:
            return L10n.referralTerminatedStatusLabel
        case .unknown:
            return ""
        }
    }
}
