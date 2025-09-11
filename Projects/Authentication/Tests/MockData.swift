import Foundation
import hCore

@testable import Authentication

@MainActor
struct MockData {
    static func createAuthenticationService(
        submitAuth: @escaping Submit = { otpState in
            otpState.code
        },
        startAuth: @escaping Start = { otpState in
            if let verifyUrl = otpState.verifyUrl, let resendUrl = otpState.resendUrl {
                return (verifyUrl, resendUrl, otpState.maskedEmail)
            }
            throw AuthenticationError.otpInputError
        },
        resendAuth: @escaping Resend = { _ in },
        startSeBankIdAuth: @escaping StartSeBankId = { _ in },
        logoutAuth: @escaping Logout = {},
        exchangeCode: @escaping ExchangeCode = { _ in },
        exchangeToken: @escaping ExchangeToken = { _ in }
    ) -> MockAuthenticationService {
        let service = MockAuthenticationService(
            submitAuth: submitAuth,
            startAuth: startAuth,
            resendAuth: resendAuth,
            startSeBankIdAuth: startSeBankIdAuth,
            logoutAuth: logoutAuth,
            exchangeCode: exchangeCode,
            exchangeToken: exchangeToken
        )
        Dependencies.shared.add(module: Module { () -> AuthenticationClient in service })
        return service
    }
}

enum AuthenticationError: Error {
    case otpInputError
}

typealias Submit = (Authentication.OTPState) async throws -> String
typealias Start = (Authentication.OTPState) async throws -> (URL, URL, String?)
typealias Resend = (Authentication.OTPState) async throws -> Void
typealias StartSeBankId = (@escaping (Authentication.ObserveStatusResponseType) -> Void) async throws -> Void
typealias Logout = () async throws -> Void
typealias ExchangeCode = (String) async throws -> Void
typealias ExchangeToken = (String) async throws -> Void

class MockAuthenticationService: AuthenticationClient {
    var events = [Event]()

    var submitAuth: Submit
    var startAuth: Start
    var resendAuth: Resend
    var startSeBankIdAuth: StartSeBankId
    var logoutAuth: Logout
    var exchangeCode: ExchangeCode
    var exchangeToken: ExchangeToken

    enum Event {
        case submit
        case start
        case resend
        case startSeBankId
        case logout
        case exchangeCode
        case exchangeToken
    }

    init(
        submitAuth: @escaping Submit,
        startAuth: @escaping Start,
        resendAuth: @escaping Resend,
        startSeBankIdAuth: @escaping StartSeBankId,
        logoutAuth: @escaping Logout,
        exchangeCode: @escaping ExchangeCode,
        exchangeToken: @escaping ExchangeToken
    ) {
        self.submitAuth = submitAuth
        self.startAuth = startAuth
        self.resendAuth = resendAuth
        self.startSeBankIdAuth = startSeBankIdAuth
        self.logoutAuth = logoutAuth
        self.exchangeCode = exchangeCode
        self.exchangeToken = exchangeToken
    }

    func submit(otpState: Authentication.OTPState) async throws -> String {
        events.append(.submit)
        let data = try await submitAuth(otpState)
        return data
    }

    func start(
        with otpState: Authentication.OTPState
    ) async throws -> (verifyUrl: URL, resendUrl: URL, maskedEmail: String?) {
        events.append(.start)
        let data = try await startAuth(otpState)
        return data
    }

    func resend(otp otpState: Authentication.OTPState) async throws {
        events.append(.resend)
        try await resendAuth(otpState)
    }

    func startSeBankId(updateStatusTo: @escaping (Authentication.ObserveStatusResponseType) -> Void) async throws {
        events.append(.startSeBankId)
        try await startSeBankIdAuth(updateStatusTo)
    }

    func logout() async throws {
        events.append(.logout)
        try await logoutAuth()
    }

    func exchange(code: String) async throws {
        events.append(.exchangeCode)
        try await exchangeCode(code)
    }

    func exchange(refreshToken: String) async throws {
        events.append(.exchangeToken)
        try await exchangeToken(refreshToken)
    }
}
