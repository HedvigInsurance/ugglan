import Foundation
import Presentation

public enum BankIDLoginQRResult: ActionProtocol {
    case loggedIn
    case emailLogin
}

public enum AuthenticationNavigationAction: ActionProtocol {
    case otpCode
    case authSuccess
    case impersonation
}

enum LoginError: Error {
    case failed
}

public enum AuthenticationAction: ActionProtocol {
    case cancel
    case logout
    case logoutSuccess
    case logoutFailure
    case loginFailure(message: String?)
    case navigationAction(action: AuthenticationNavigationAction)
    case bankIdQrResultAction(action: BankIDLoginQRResult)
}
