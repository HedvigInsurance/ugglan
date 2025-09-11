import Foundation

public class OTPState: ObservableObject {
    @Published var isLoading = false
    @Published var isResending = false
    @Published public internal(set) var resendUrl: URL? = nil
    @Published public internal(set) var verifyUrl: URL? = nil
    @Published public internal(set) var code: String
    @Published var codeErrorMessage: String? = nil
    @Published var otpInputErrorMessage: String? = nil
    @Published public internal(set) var input: String
    @Published var maskedEmail: String? = nil
    @Published var canResendAt: Date? = nil

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

    func reset() {
        isLoading = false
        isResending = false
        resendUrl = nil
        verifyUrl = nil
        code = ""
        codeErrorMessage = nil
        otpInputErrorMessage = nil
        input = ""
        maskedEmail = nil
        canResendAt = nil
    }
}
