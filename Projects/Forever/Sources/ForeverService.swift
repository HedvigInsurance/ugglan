import Flow
import Foundation
import hCore
import hGraphQL

public struct Referral: Hashable, Codable {
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
        monthlyDiscountPerReferral: MonetaryAmount
    ) {
        self.grossAmount = grossAmount
        self.netAmount = netAmount
        self.otherDiscounts = otherDiscounts
        self.discountCode = discountCode
        self.monthlyDiscount = monthlyDiscount
        self.monthlyDiscountPerReferral = monthlyDiscountPerReferral
        self.referrals = referrals
    }
    
    let grossAmount: MonetaryAmount
    let netAmount: MonetaryAmount
    let monthlyDiscount: MonetaryAmount
    let otherDiscounts: MonetaryAmount?
    var discountCode: String
    let referrals: [Referral]
    let monthlyDiscountPerReferral: MonetaryAmount
    
    public mutating func updateDiscountCode(_ newValue: String) { discountCode = newValue }
}

//public enum ForeverChangeCodeError: Error, LocalizedError, Equatable {
//    case nonUnique, tooLong, tooShort
//    case exceededMaximumUpdates
//    case unknown
//
//    public var errorDescription: String? {
//        switch self {
//        case .nonUnique: return L10n.ReferralsChange.Code.Sheet.Error.Claimed.code
//        case .tooLong: return L10n.ReferralsChange.Code.Sheet.Error.Max.length
//        case .tooShort: return L10n.ReferralsChange.Code.Sheet.General.error
//        case .exceededMaximumUpdates: return "" //L10n.ReferralsChange.Code.Sheet.Error.Change.Limit.reached(amount)
//        case .unknown: return L10n.ReferralsChange.Code.Sheet.General.error
//        }
//    }
//    var localizedDescription: String {
//        switch self {
//        case .nonUnique: return L10n.ReferralsChange.Code.Sheet.Error.Claimed.code
//        case .tooLong: return L10n.ReferralsChange.Code.Sheet.Error.Max.length
//        case .tooShort: return L10n.ReferralsChange.Code.Sheet.General.error
//        case .exceededMaximumUpdates: return "" //L10n.ReferralsChange.Code.Sheet.Error.Change.Limit.reached(amount)
//        case .unknown: return L10n.ReferralsChange.Code.Sheet.General.error
//        }
//    }
//}

public protocol ForeverService {
    var dataSignal: ReadSignal<ForeverData?> { get }
    func refetch()
    func changeDiscountCode(_ value: String) -> Signal<Either<Void, String>>
}

extension ForeverData {
    static func mock() -> ForeverData {
        
        let foreverData = ForeverData(
            grossAmount: .sek(100),
            netAmount: .sek(60),
            otherDiscounts: .sek(10),
            discountCode: "CODE",
            monthlyDiscount: .sek(20),
            referrals: [
                .init(name: "First", activeDiscount: .sek(10), status: .active),
                .init(name: "Second", activeDiscount: .sek(10), status: .pending),
                .init(name: "Third", activeDiscount: .sek(10), status: .terminated)
            ],
            monthlyDiscountPerReferral: .sek(10)
        )
        return foreverData
    }
}
