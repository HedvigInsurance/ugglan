import Foundation
import Presentation
import hCore

public struct OTPState: StateProtocol {
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
    var liveQrCodeData: String? = nil
    var liveQrCodeDate: Date? = nil
    public init() {}
}

public struct AuthenticationState: StateProtocol {
    var otpState = OTPState()

    public init() {}
}
