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
        potentialDiscountAmount: MonetaryAmount,
        discountCode: String,
        invitations: [ForeverInvitation]
    ) {
        self.grossAmount = grossAmount
        self.netAmount = netAmount
        self.discountCode = discountCode
        self.potentialDiscountAmount = potentialDiscountAmount
        self.invitations = invitations
    }

    let grossAmount: MonetaryAmount
    let netAmount: MonetaryAmount
    let potentialDiscountAmount: MonetaryAmount
    var discountCode: String
    let invitations: [ForeverInvitation]

    public mutating func updateDiscountCode(_ newValue: String) { discountCode = newValue }
}

public enum ForeverChangeCodeError: LocalizedError, Equatable {
    case nonUnique, tooLong, tooShort
    case exceededMaximumUpdates(amount: Int)
    case unknown

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
        let foreverData = ForeverData(
            grossAmount: .sek(100),
            netAmount: .sek(80),
            potentialDiscountAmount: .sek(10),
            discountCode: "CODE",
            invitations: [
                .init(name: "First", state: .active, invitedByOther: false),
                .init(name: "Second", state: .pending, invitedByOther: false),
                .init(name: "Third", state: .terminated, invitedByOther: false),
                .init(name: "Third", state: .active, invitedByOther: true),
                .init(name: "Forth", state: .pending, invitedByOther: true),
                .init(name: "Fifth", state: .terminated, invitedByOther: true),
            ]
        )
        return foreverData
    }
}
