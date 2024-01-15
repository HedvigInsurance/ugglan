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
    var otpInputErrorMessage: String? = nil
    var email: String? = nil
    var personalNumber: String? = nil
    var canResendAt: Date? = nil

    public init() {}
}

struct SEBankIDState: StateProtocol {
    var autoStartToken: String? = nil
    public init() {}
}

public struct AuthenticationState: StateProtocol {
    var statusText: String? = nil
    var otpState = OTPState()
    @Transient(defaultValue: SEBankIDState()) var seBankIDState
    @Transient(defaultValue: false) var loginHasFailed: Bool

    public init() {}
}
