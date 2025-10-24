import Foundation

@MainActor
public protocol AuthenticationClient {
    func submit(otpState: OTPState) async throws -> String
    func start(with otpState: OTPState) async throws -> (verifyUrl: URL, resendUrl: URL, maskedEmail: String?)
    func resend(otp otpState: OTPState) async throws
    func startSeBankId(updateStatusTo: @escaping (_: ObserveStatusResponseType) -> Void) async throws
    func logout() async throws
    func exchange(code: String) async throws
    func exchange(refreshToken: String) async throws
}

public enum ObserveStatusResponseType {
    case started(code: String)
    case pending(qrCode: String?)
    case completed
}
