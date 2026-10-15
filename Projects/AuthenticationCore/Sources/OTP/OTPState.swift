import Foundation
import Observation

@Observable
public class OTPState {
    public var isLoading = false
    public var isResending = false
    public var resendUrl: URL? = nil
    public var verifyUrl: URL? = nil
    public var code: String
    public var codeErrorMessage: String? = nil
    public var otpInputErrorMessage: String? = nil
    public var input: String
    public var maskedEmail: String? = nil
    public var canResendAt: Date? = nil

    public init(
        isLoading: Bool = false,
        isResending: Bool = false,
        resendUrl: URL? = nil,
        verifyUrl: URL? = nil,
        code: String = "",
        codeErrorMessage: String? = nil,
        otpInputErrorMessage: String? = nil,
        input: String = "",
        maskedEmail: String? = nil,
        canResendAt: Date? = nil
    ) {
        self.isLoading = isLoading
        self.isResending = isResending
        self.resendUrl = resendUrl
        self.verifyUrl = verifyUrl
        self.code = code
        self.codeErrorMessage = codeErrorMessage
        self.otpInputErrorMessage = otpInputErrorMessage
        self.input = input
        self.maskedEmail = maskedEmail
        self.canResendAt = canResendAt
    }
}
