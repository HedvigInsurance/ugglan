import Foundation

public class OTPState: ObservableObject {
    @Published public var isLoading = false
    @Published public var isResending = false
    @Published public var resendUrl: URL? = nil
    @Published public var verifyUrl: URL? = nil
    @Published public var code: String
    @Published public var codeErrorMessage: String? = nil
    @Published public var otpInputErrorMessage: String? = nil
    @Published public var input: String
    @Published public var maskedEmail: String? = nil
    @Published public var canResendAt: Date? = nil

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
