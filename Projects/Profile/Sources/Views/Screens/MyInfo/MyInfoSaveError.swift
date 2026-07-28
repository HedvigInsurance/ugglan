import Foundation
import hCore

public enum MyInfoSaveError {
    case emailEmpty
    case emailMalformed
    case phoneNumberEmpty
    case phoneNumberMalformed
    case error(message: String)
}

extension MyInfoSaveError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .phoneNumberEmpty: return L10n.myInfoPhoneNumberEmptyError
        case .phoneNumberMalformed: return L10n.myInfoPhoneNumberMalformedError
        case .emailEmpty: return L10n.myInfoEmailEmptyError
        case .emailMalformed: return L10n.myInfoEmailMalformedError
        case let .error(message): return message
        }
    }
}
