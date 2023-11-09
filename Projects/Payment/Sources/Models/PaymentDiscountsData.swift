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
            hSignalColor.greenElement
        case .pending:
            hSignalColor.amberElement
        case .terminated:
            hSignalColor.redElement
        case .unknown:
            hSignalColor.blueElement
        }
    }

    @hColorBuilder var discountLabelColor: some hColor {
        switch self.status {
        case .active:
            hTextColor.secondary
        case .pending, .terminated:
            hTextColor.tertiary
        case .unknown:
            hTextColor.tertiary
        }
    }

    @hColorBuilder var invitedByOtherLabelColor: some hColor {
        switch self.status {
        case .active, .pending:
            hTextColor.tertiary
        case .terminated:
            hTextColor.tertiary
        case .unknown:
            hTextColor.tertiary
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
