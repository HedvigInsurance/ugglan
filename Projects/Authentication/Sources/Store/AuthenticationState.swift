import Foundation
import Presentation
import hCore

struct OTPState: StateProtocol {
    var isLoading = false
    var isResending = false
    var resendUrl: URL? = nil
    var verifyUrl: URL? = nil
    var code: String = ""
    var codeErrorMessage: String? = nil
    var emailErrorMessage: String? = nil
    var email: String = ""
    var canResendAt: Date? = nil

    public init() {}
}

struct SEBankIDState: StateProtocol {
    var autoStartToken: String? = nil
    public init() {}
}

struct ZignsecState: StateProtocol {
    var isLoading: Bool = false
    var personalNumber: String = ""
    var webviewUrl: URL? = nil
    var credentialError: Bool = false

    public init() {}
}

public struct AuthenticationState: StateProtocol {
    var statusText: String? = nil
    var otpState = OTPState()
    @Transient(defaultValue: SEBankIDState()) var seBankIDState
    var zignsecState = ZignsecState()
    @Transient(defaultValue: false) var loginHasFailed: Bool

    public init() {}
}
