import Foundation
import Presentation

public enum OTPStateAction: ActionProtocol {
    case setCode(code: String)
    case verifyCode
    case setLoading(isLoading: Bool)
    case setCodeError(message: String?)
    case setEmailError(message: String?)
    case setEmail(email: String)
    case startSession(verifyUrl: URL, resendUrl: URL)
    case submitEmail
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

public enum SEBankIDStateAction: ActionProtocol {
    case startSession
    case updateWith(autoStartToken: String)
}

public enum ZignsecStateAction: ActionProtocol {
    case reset
    case setIsLoading(isLoading: Bool)
    case setPersonalNumber(personalNumber: String)
    case setWebviewUrl(url: URL)
    case startSession(personalNumber: String)
    case setCredentialError(error: Bool)
}

enum LoginError: Error {
    case failed
}

public enum AuthenticationAction: ActionProtocol {
    case setStatus(text: String?)
    case exchange(code: String)
    case impersonate(code: String)
    case cancel
    case logout
    case logoutSuccess
    case logoutFailure
    case loginFailure(message: String?)
    case observeLoginStatus(url: URL)
    case otpStateAction(action: OTPStateAction)
    case seBankIDStateAction(action: SEBankIDStateAction)
    case zignsecStateAction(action: ZignsecStateAction)
    case navigationAction(action: AuthenticationNavigationAction)
    case bankIdQrResultAction(action: BankIDLoginQRResult)
}
