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
            return L10n.myInfoPhoneNumberEmptyError
        case .phoneNumberMalformed:
            return L10n.myInfoPhoneNumberMalformedError
        case .emailEmpty:
            return L10n.myInfoEmailEmptyError
        case .emailMalformed:
            return L10n.myInfoEmailMalformedError
        }
    }
}
