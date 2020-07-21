//
//  ForeverService.swift
//  Forever
//
//  Created by sam on 11.6.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import hCore

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
}

public struct ForeverData: Codable {
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
    
    public mutating func updateDiscountCode(_ newValue: String) {
        self.discountCode = newValue
    }
}

public enum ForeverChangeCodeError: LocalizedError {
    case nonUnique, tooLong, tooShort, exceededMaximumUpdates
    
    var localizedDescription: String {
        switch self {
        case .nonUnique:
            return L10n.ReferralsChange.Code.Sheet.Error.Claimed.code
        case .tooLong:
            return L10n.ReferralsChange.Code.Sheet.Error.Max.length
        case .tooShort:
            return L10n.ReferralsChange.Code.Sheet.General.error
        case .exceededMaximumUpdates:
            return L10n.ReferralsChange.Code.Sheet.General.error
        }
    }
}

public protocol ForeverService {
    var dataSignal: ReadSignal<ForeverData?> { get }
    func refetch()
    func changeDiscountCode(_ value: String) -> Signal<Either<Void, ForeverChangeCodeError>>
}
