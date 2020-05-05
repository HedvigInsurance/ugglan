//
//  MyInfoSaveError.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-02-16.
//

import Foundation

enum MyInfoSaveError {
    case emailEmpty, emailMalformed, phoneNumberEmpty, phoneNumberMalformed
}

extension MyInfoSaveError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .phoneNumberEmpty:
            return String(key: .MY_INFO_PHONE_NUMBER_EMPTY_ERROR)
        case .phoneNumberMalformed:
            return String(key: .MY_INFO_PHONE_NUMBER_MALFORMED_ERROR)
        case .emailEmpty:
            return String(key: .MY_INFO_EMAIL_EMPTY_ERROR)
        case .emailMalformed:
            return String(key: .MY_INFO_EMAIL_MALFORMED_ERROR)
        }
    }
}
