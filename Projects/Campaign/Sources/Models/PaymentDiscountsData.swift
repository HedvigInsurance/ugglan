import Foundation
import hCore
import hCoreUI

public struct PaymentDiscountsData: Codable, Equatable, Sendable {
    let discounts: [Discount]
    let referralsData: ReferralsData

    public init(discounts: [Discount], referralsData: ReferralsData) {
        self.discounts = discounts
        self.referralsData = referralsData
    }
}

public struct Discount: Codable, Equatable, Identifiable, Hashable, Sendable {
    public let id: String
    public let code: String
    public let amount: MonetaryAmount?
    let title: String?
    let listOfAffectedInsurances: [AffectedInsurance]
    let validUntil: ServerBasedDate?
    let canBeDeleted: Bool
    let discountId: String

    public init(
        code: String,
        amount: MonetaryAmount?,
        title: String?,
        listOfAffectedInsurances: [AffectedInsurance],
        validUntil: ServerBasedDate?,
        canBeDeleted: Bool,
        discountId: String
    ) {
        self.id = UUID().uuidString
        self.code = code
        self.amount = amount
        self.title = title
        self.listOfAffectedInsurances = listOfAffectedInsurances
        self.validUntil = validUntil
        self.canBeDeleted = canBeDeleted
        self.discountId = discountId
    }

    @MainActor
    public init(
        referral: Referral,
        nbOfReferrals: Int
    ) {
        self.id = UUID().uuidString
        self.code = referral.code ?? referral.name
        self.amount = referral.activeDiscount
        self.title = referral.description
        self.listOfAffectedInsurances = []
        self.validUntil = nil
        self.canBeDeleted = true
        self.discountId = referral.id
    }

    @MainActor
    var isValid: Bool {
        if let validUntil = validUntil?.localDateToDate {
            let components = Calendar.current.dateComponents(
                [.day],
                from: Date(),
                to: validUntil
            )
            let isValid = components.day ?? 0 >= 0
            return isValid
        }
        return true
    }
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
        let value = referrals.compactMap({ $0.activeDiscount }).compactMap({ $0.value }).reduce(0.0, +)
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

    @MainActor
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

public struct AffectedInsurance: Codable, Equatable, Identifiable, Hashable, Sendable {
    public let id: String
    let displayName: String

    public init(
        id: String,
        displayName: String
    ) {
        self.id = id
        self.displayName = displayName
    }
}

public struct DiscountsData: Identifiable, Hashable {
    public let id = UUID().uuidString
    let insurance: AffectedInsurance
    let discount: [Discount]
}
