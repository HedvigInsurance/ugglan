import AutomaticLog
import Foundation
import hCore

@MainActor
public class AuthenticationService {
    @Inject var client: AuthenticationClient

    public init() {}

    @Log(.error, masked: ["otpState"])
    public func submit(otpState: OTPState) async throws -> String {
        try await client.submit(otpState: otpState)
    }

    @Log(.error, masked: ["otpState"])
    public func start(
        with otpState: OTPState
    ) async throws -> (verifyUrl: URL, resendUrl: URL, maskedEmail: String?) {
        try await client.start(with: otpState)
    }

    @Log(.error, masked: ["otpState"])
    public func resend(otp otpState: OTPState) async throws {
        try await client.resend(otp: otpState)
    }

    @Log(.error)
    public func startSeBankId(updateStatusTo: @escaping (_: ObserveStatusResponseType) -> Void) async throws {
        try await client.startSeBankId(updateStatusTo: updateStatusTo)
    }

    @Log(.error)
    public func logout() async throws {
        try await client.logout()
    }

    @Log(.error, masked: ["code"])
    public func exchange(code: String) async throws {
        try await client.exchange(code: code)
    }

    @Log(.error, masked: ["refreshToken"])
    public func exchange(refreshToken: String) async throws {
        try await client.exchange(refreshToken: refreshToken)
    }

    public static var logAuthResourceStart: ((_ key: String, _ URL: URL) -> Void) = { _, _ in }
    public static var logAuthResourceStop: ((_ key: String, _ response: URLResponse) -> Void) = { _, _ in }
}
