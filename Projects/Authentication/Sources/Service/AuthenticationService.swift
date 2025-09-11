import Foundation
import hCore

@MainActor
public class AuthenticationService {
    @Inject var client: AuthenticationClient

    public init() {}

    func submit(otpState: OTPState) async throws -> String {
        log.info("AuthenticationService: submit", error: nil, attributes: nil)
        return try await client.submit(otpState: otpState)
    }

    func start(with otpState: OTPState) async throws -> (verifyUrl: URL, resendUrl: URL, maskedEmail: String?) {
        log.info("AuthenticationService: start", error: nil, attributes: nil)
        return try await client.start(with: otpState)
    }

    func resend(otp otpState: OTPState) async throws {
        log.info("AuthenticationService: resend", error: nil, attributes: nil)
        try await client.resend(otp: otpState)
    }

    func startSeBankId(updateStatusTo: @escaping (_: ObserveStatusResponseType) -> Void) async throws {
        log.info("AuthenticationService: startSeBankId", error: nil, attributes: nil)
        return try await client.startSeBankId(updateStatusTo: updateStatusTo)
    }

    public func logout() async throws {
        log.info("AuthenticationService: logout", error: nil, attributes: nil)
        try await client.logout()
    }

    public func exchange(code: String) async throws {
        log.info("AuthenticationService: exchange code", error: nil, attributes: nil)
        try await client.exchange(code: code)
    }

    public func exchange(refreshToken: String) async throws {
        log.info("AuthenticationService: exchange refresh token", error: nil, attributes: nil)
        try await client.exchange(refreshToken: refreshToken)
    }

    public static var logAuthResourceStart: ((_ key: String, _ URL: URL) -> Void) = { _, _ in }
    public static var logAuthResourceStop: ((_ key: String, _ response: URLResponse) -> Void) = { _, _ in }
}
