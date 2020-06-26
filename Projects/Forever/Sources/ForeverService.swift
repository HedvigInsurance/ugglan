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
    let discountCode: String
    let invitations: [ForeverInvitation]
}

public protocol ForeverService {
    var dataSignal: ReadSignal<ForeverData?> { get }
    func refetch()
}
