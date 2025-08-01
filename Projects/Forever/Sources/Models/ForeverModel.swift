import Foundation
import hCore
import hCoreUI

public struct Referral: Hashable, Codable, Sendable {
    let name: String
    let activeDiscount: MonetaryAmount?
    let status: State

    public init(
        name: String,
        activeDiscount: MonetaryAmount? = nil,
        status: State
    ) {
        self.name = name
        self.activeDiscount = activeDiscount
        self.status = status
    }

    var discountLabelText: String {
        switch status {
        case .active:
            return activeDiscount?.negative.formattedAmount ?? ""
        case .pending:
            return L10n.referralPendingStatusLabel
        case .terminated:
            return L10n.referralTerminatedStatusLabel
        }
    }

    @MainActor
    public enum State: String, Codable, Sendable {
        case terminated
        case pending
        case active

        @hColorBuilder var discountLabelColor: some hColor {
            switch self {
            case .active:
                hTextColor.Opaque.secondary
            case .pending, .terminated:
                hTextColor.Opaque.tertiary
            }
        }

        @hColorBuilder var invitedByOtherLabelColor: some hColor {
            switch self {
            case .active, .pending:
                hTextColor.Opaque.tertiary
            case .terminated:
                hTextColor.Opaque.tertiary
            }
        }

        @hColorBuilder var statusColor: some hColor {
            switch self {
            case .active:
                hSignalColor.Green.element
            case .pending:
                hSignalColor.Amber.element
            case .terminated:
                hSignalColor.Red.element
            }
        }
    }
}

public struct ForeverData: Codable, Equatable, Sendable {
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
