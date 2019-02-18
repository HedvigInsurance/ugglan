//
//  MyPaymentQuery+isSwitching.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-02-18.
//

import Foundation

extension MyPaymentQuery.Data {
    func isSwitchingBankAccount() -> Bool {
        switch registerAccountProcessingStatus {
        case .inProgress:
            return true
        case .initiated:
            return true
        case .requested:
            return true
        default:
            return false
        }
    }
}
