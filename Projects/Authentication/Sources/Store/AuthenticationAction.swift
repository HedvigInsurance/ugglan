import Foundation
import Presentation

public enum OTPStateAction: ActionProtocol {
    case setCode(code: String)
    case verifyCode
    case setLoading(isLoading: Bool)
    case setCodeError(message: String?)
    case setEmail(email: String)
    case setPersonalNumber(personalNumber: String)
    case setOtpInputError(message: String?)
    case startSession(verifyUrl: URL, resendUrl: URL)
    case submitOtpData
    case reset
    case resendCode
    case showResentToast
}

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
    case otpStateAction(action: OTPStateAction)
    case navigationAction(action: AuthenticationNavigationAction)
    case bankIdQrResultAction(action: BankIDLoginQRResult)
}
