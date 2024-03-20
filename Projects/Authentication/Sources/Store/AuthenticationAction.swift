import Foundation
import Presentation

public enum BankIDLoginSwedenResult: ActionProtocol {
    case qrCode
    case emailLogin
    case loggedIn
    case close
}

public enum BankIDLoginQRResult: ActionProtocol {
    case loggedIn
    case emailLogin
    case close
}

public enum AuthenticationNavigationAction: ActionProtocol {
    case otpCode
    case authSuccess
    case impersonation
    case zignsecWebview(url: URL)
}

enum LoginError: Error {
    case failed
}

public enum AuthenticationAction: ActionProtocol {
    case exchange(code: String)
    case impersonate(code: String)
    case cancel
    case logout
    case logoutSuccess
    case logoutFailure
    case loginFailure(message: String?)
    case navigationAction(action: AuthenticationNavigationAction)
    case bankIdQrResultAction(action: BankIDLoginQRResult)
}
