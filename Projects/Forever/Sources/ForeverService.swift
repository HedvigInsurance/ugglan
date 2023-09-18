import Flow
import Foundation
import hCore
import hGraphQL

public struct ForeverInvitation: Hashable, Codable {
    let name: String
    let state: State
    let discount: MonetaryAmount?
    let invitedByOther: Bool

    public enum State: String, Codable {
        case terminated
        case pending
        case active
    }

    public init(
        name: String,
        state: State,
        discount: MonetaryAmount? = nil,
        invitedByOther: Bool
    ) {
        self.name = name
        self.state = state
        self.discount = discount
        self.invitedByOther = invitedByOther
    }
}

public struct ForeverData: Codable, Equatable {
    public init(
        grossAmount: MonetaryAmount,
        netAmount: MonetaryAmount,
//        potentialDiscountAmount: MonetaryAmount,
        otherDiscounts: MonetaryAmount?,
        discountCode: String,
//        invitations: [ForeverInvitation]
        
        monthlyDiscount: MonetaryAmount,
        referrals: [Referral],
//        monthlyDiscountExcludingReferrals: MonetaryAmount,// == otherDiscount
        monthlyDiscountPerReferral: MonetaryAmount
//        discountCode: String
        
        
    ) {
        self.grossAmount = grossAmount
        self.netAmount = netAmount
        self.otherDiscounts = otherDiscounts
        self.discountCode = discountCode
//        self.potentialDiscountAmount = potentialDiscountAmount
//        self.invitations = invitations
        
        self.monthlyDiscount = monthlyDiscount
        self.monthlyDiscountPerReferral = monthlyDiscountPerReferral
//        self.otherDiscounts = monthlyDiscountExcludingReferrals
        self.referrals = referrals
//        self.discountCode = discountCode
    }

    let grossAmount: MonetaryAmount
    let netAmount: MonetaryAmount
    let monthlyDiscount: MonetaryAmount
//    let potentialDiscountAmount: MonetaryAmount
    let otherDiscounts: MonetaryAmount?
    var discountCode: String
//    let invitations: [ForeverInvitation]
    let referrals: [Referral]
    let monthlyDiscountPerReferral: MonetaryAmount

    public mutating func updateDiscountCode(_ newValue: String) { discountCode = newValue }
}

public enum ForeverChangeCodeError: Error, LocalizedError, Equatable {
    case nonUnique, tooLong, tooShort
    case exceededMaximumUpdates(amount: Int)
    case unknown

    public var errorDescription: String? {
        switch self {
        case .nonUnique: return L10n.ReferralsChange.Code.Sheet.Error.Claimed.code
        case .tooLong: return L10n.ReferralsChange.Code.Sheet.Error.Max.length
        case .tooShort: return L10n.ReferralsChange.Code.Sheet.General.error
        case let .exceededMaximumUpdates(amount):
            return L10n.ReferralsChange.Code.Sheet.Error.Change.Limit.reached(amount)
        case .unknown: return L10n.ReferralsChange.Code.Sheet.General.error
        }
    }
    var localizedDescription: String {
        switch self {
        case .nonUnique: return L10n.ReferralsChange.Code.Sheet.Error.Claimed.code
        case .tooLong: return L10n.ReferralsChange.Code.Sheet.Error.Max.length
        case .tooShort: return L10n.ReferralsChange.Code.Sheet.General.error
        case let .exceededMaximumUpdates(amount):
            return L10n.ReferralsChange.Code.Sheet.Error.Change.Limit.reached(amount)
        case .unknown: return L10n.ReferralsChange.Code.Sheet.General.error
        }
    }
}

public protocol ForeverService {
    var dataSignal: ReadSignal<ForeverData?> { get }
    func refetch()
    func changeDiscountCode(_ value: String) -> Signal<Either<Void, ForeverChangeCodeError>>
}

extension ForeverData {
    static func mock() -> ForeverData {
//        let foreverData = ForeverData(
//            grossAmount: .sek(100),
//            netAmount: .sek(60),
//            potentialDiscountAmount: .sek(10),
//            otherDiscounts: .sek(20),
//            discountCode: "CODE",
//            invitations: [
//                .init(name: "First", state: .active, discount: .sek(10), invitedByOther: false),
//                .init(name: "Second", state: .pending, invitedByOther: false),
//                .init(name: "Third", state: .terminated, invitedByOther: false),
//                .init(name: "Forth", state: .active, discount: .sek(10), invitedByOther: true),
//                .init(name: "Fifth", state: .pending, invitedByOther: true),
//                .init(name: "Sixth", state: .terminated, invitedByOther: true),
//            ]
//        )
        let foreverData = ForeverData(
            grossAmount: .sek(100),
            netAmount: .sek(60),
            otherDiscounts: .sek(10),
            //            potentialDiscountAmount: .sek(10),
            discountCode: "CODE",
            monthlyDiscount: .sek(20),
            referrals: [],
            monthlyDiscountPerReferral: .sek(10)
//            invitations: [
//                .init(name: "First", state: .active, discount: .sek(10), invitedByOther: false),
//                .init(name: "Second", state: .pending, invitedByOther: false),
//                .init(name: "Third", state: .terminated, invitedByOther: false),
//                .init(name: "Forth", state: .active, discount: .sek(10), invitedByOther: true),
//                .init(name: "Fifth", state: .pending, invitedByOther: true),
//                .init(name: "Sixth", state: .terminated, invitedByOther: true),
//            ]
        )
        return foreverData
    }
}

//public struct ForeverDataNew: Codable, Equatable {
//
//    public init(
//        grossAmount: MonetaryAmount,
//        netAmount: MonetaryAmount,
//        monthlyDiscount: MonetaryAmount,
//        referrals: [Referral],
//        monthlyDiscountExcludingReferrals: MonetaryAmount,// == otherDiscount
//        monthlyDiscountPerReferral: MonetaryAmount,
//        discountCode: String
//    ) {
//        self.grossAmount = grossAmount
//        self.netAmount = netAmount
//        self.monthlyDiscount = monthlyDiscount
//        self.otherDiscounts = monthlyDiscountExcludingReferrals
//        self.referrals = referrals
//        self.discountCode = discountCode
//        self.monthlyDiscountPerReferral = monthlyDiscountPerReferral
//    }
//
//    let grossAmount: MonetaryAmount
//    let netAmount: MonetaryAmount
//    let monthlyDiscount: MonetaryAmount
//    let otherDiscounts: MonetaryAmount
//    let referrals: [Referral]
//    let discountCode: String
//    let monthlyDiscountPerReferral: MonetaryAmount
//
//    public mutating func updateDiscountCode(_ newValue: String) { discountCode = newValue }
//}

public struct Referral: Hashable, Codable {
    let name: String
    let activeDiscounts: MonetaryAmount
    let status: State
    
    public enum State: String, Codable {
        case terminated
        case pending
        case active
    }
}
